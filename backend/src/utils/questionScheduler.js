import { config } from '../config.js';
import { Op } from 'sequelize';
import cron from 'node-cron';
import DailyQuestion from "../models/DailyQuestion.js";
import ChatRoom from "../models/ChatRoom.js";
import {
    pickQuestionForRoom,
    today,
    yesterday,
    notifyRoom,
} from './dailyQuestion.js';

const MAX_RETRIES = 3; // how many retry attempts for resending failed daily q

// dispatch to rooms that haven't received today's question
async function dispatchNewQuestions(io, todayStr, yesterdayStr) {
    const rooms = await ChatRoom.findAll();
    console.log(`[questionScheduler] checking ${rooms.length} rooms`);

    for (const room of rooms) {
        try {
            // skip if already dispatched today, including failed attempts
            const alreadySent = await DailyQuestion.findOne({
                where: { chatId: room.id, date: todayStr },
            });
            if (alreadySent) continue;

            // skip inactive rooms, new rooms with no history are treated as active
            const yesterdaysQuestion = await DailyQuestion.findOne({
                where: { chatId: room.id, date: yesterdayStr },
            });
            if (yesterdaysQuestion && yesterdaysQuestion.answeredCount < 1) {
                await ChatRoom.update({ isActive: false }, { where: { id: room.id } });
                console.log(`[questionScheduler] room ${room.id} inactive, skipping...`);
                continue;
            }
            
            const question = await pickQuestionForRoom(room.id);
            if (!question) {
                console.warn(`[questionScheduler] no question available for room ${room.id}, skipping...`);
                continue;
            }
            
            // save record first, then attempt delivery
            const dailyQuestion = await DailyQuestion.create({
                chatId: room.id,
                questionId: question.id,
                date: todayStr,
                wasDelivered: false,
                deliveryAttempts: 0,
                lastAttemptedAt: new Date(),
            });

            await attemptDelivery(io, dailyQuestion, question);
        } catch(e) {
        console.error(`[questionScheduler] error on room ${room.id}:`, e.message);
        }   
    }
}

// retry any failed deliveries
async function retryFailedDeliveries(io, todayStr) {
    const failed = await DailyQuestion.findAll({
        where: {
            date: todayStr,
            wasDelivered: false,
            deliveryAttempts: { [Op.lt]: MAX_RETRIES },
        },
        include: [{ association: 'question' }],
    });

    // log the rooms that hit max retries and are being skipped
    const maxed = await DailyQuestion.findAll({
        where: {
            date: todayStr,
            wasDelivered: false,
            deliveryAttempts: { [Op.gte]: MAX_RETRIES },
        }
    });
    if (maxed.length) {
        console.log(`[questionScheduler] ${maxed.length} room(s) have hit MAX_RETRIES, skipping...`);
        for (const dq of maxed) {
            console.log(`[questionScheduler] room ${dq.chatId} - attempts: ${dq.deliveryAttempts}/${MAX_RETRIES}`);
        }
    }

    if (!failed.length) return; // no failed deliveries

    for (const dailyQuestion of failed) {
        try {
            await attemptDelivery(io, dailyQuestion, dailyQuestion.question);
        } catch(e) {
            console.error(`[questionScheduler] retry error on DailyQuestion ${dailyQuestion.id}:`, e.message);
        }
    }
}

// base delivery logic
async function attemptDelivery(io, dailyQuestion, question) {
    // always increment attempts and record the time, regardless of if it was successful
    await dailyQuestion.update({
        deliveryAttempts: dailyQuestion.deliveryAttempts+1,
        lastAttemptedAt: new Date(),
    });

    // simulate failure for testing
    console.log(`[questionScheduler] simulated failure for room ${dailyQuestion.chatId}`);
    throw new Error('Simulated delivery failure');

    console.log(`[questionScheduler] emitting to room: "${dailyQuestion.chatId}"`);
    io.to(dailyQuestion.chatId).emit('daily_question', {
        dailyQuestionId: dailyQuestion.id,
        question: question.question,
        date: dailyQuestion.date,
    });
    console.log(`[questionScheduler] emit fired`);

    await dailyQuestion.update({ wasDelivered: true });
    await notifyRoom(dailyQuestion.chatId, question);

    console.log(`[questionScheduler] delivered to room ${dailyQuestion.chatId}: "${question.question}"`);
}

// pick and send a daily question to every active room, main dispatch
export async function dispatchDailyQuestions(io) {
    console.log(`[questionScheduler] tick at ${new Date().toISOString()}`);
    const todayStr = today();
    const yesterdayStr = yesterday();

    // new dispatches
    await dispatchNewQuestions(io, todayStr, yesterdayStr);

    // retry failures
    await retryFailedDeliveries(io, todayStr);

    console.log(`[questionScheduler] tick complete`);
}

// cron job, retry to catch per-room scheduled times (TODO) and retry failed deliveries
export function startQuestionScheduler(io) {
    const cronTime = config.dailyQuestion.cronTime;
    console.log(`[questionScheduler] scheduler started, running at ${cronTime}`);
    cron.schedule(cronTime, () => {
        // initial dispatch at default time (5am)
        dispatchDailyQuestions(io);

        // retry pass 3 times (for testing, do every 15 secs, TODO: repeat every 15 mins indefinitely)
        setTimeout(() => retryFailedDeliveries(io, today()), 15*1000);
        setTimeout(() => retryFailedDeliveries(io, today()), 30*1000);
        setTimeout(() => retryFailedDeliveries(io, today()), 45*1000);
    }, {
        timezone: config.dailyQuestion.timezone,
    });
}