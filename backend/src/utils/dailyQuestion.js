import { Op } from "sequelize";
import DailyQuestion from "../models/DailyQuestion.js";
import Question from "../models/Question.js"
import UserDailyAnswer from "../models/UserDailyAnswer.js";
import ChatRoom from "../models/ChatRoom.js";
import AppError from "./errors/AppError.js";
import ChatSettings from "../models/ChatSettings.js";

// helper to return today's date as yyyy-mm-dd
export function today() {
    return new Date().toISOString().split('T')[0];
}

// helper for yesterday's date as yyyy-mm-dd
export function yesterday() {
    const d = new Date();
    d.setDate(d.getDate()-1);
    return d.toISOString().split('T')[0];
}

export async function notifyRoom(chatId, question) {
    // TODO: push notification
    console.log(`[questionScheduler] notify room ${chatId}: ${question}`);
}

// pick a question for a room that hasn't been used in the last 30 days based on preferences (stub)
export async function pickQuestionForRoom(chatId) {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate()-30);

    const settings = await ChatSettings.findOne({ where: { chatId } });

    // find questionIds already used in this room within the thirty day window
    const recentlyUsed = await DailyQuestion.findAll({
        where: {
            chatId,
            date: { [Op.gte]: thirtyDaysAgo },
        },
        attributes: ['questionId'],
    });
    const excludedIds = recentlyUsed.map(dq => dq.questionId);

    const preferenceFilter = {
        ...(settings?.relationshipType ? { relationshipType: settings.relationshipType } : {}),
        ...(settings?.allowedTopics?.length ? { topics: { [Op.overlap]: settings.allowedTopics } } : {}),
        ...(settings?.allowedTypes?.length ? { questionType: { [Op.in]: settings.allowedTypes } } : {}),
    };

    // collect all questions that match the thirty day and preference criteria
    const eligible = await Question.findAll({
        where: {
            ...preferenceFilter,
            ...(excludedIds.length ? { id: { [Op.notIn]: excludedIds } } : {}),
        },
    });

    // if all question options have been exhausted, ignore the 30-day window
    if (!eligible.length) {
        console.log(`[dailyQuestion] dq pool exhausted for room ${chatId}, using LRU`);

        // find least recently used fallback question
        const fallback = await DailyQuestion.findOne({
            where: { chatId },
            order: [['date', 'ASC']], // oldest first = lru
            include: [{ model: Question, as: 'question', where: preferenceFilter }],
        });

        console.log('[pickQuestion] settings:', settings?.relationshipType);
        console.log('[pickQuestion] preferenceFilter:', preferenceFilter);
        console.log('[pickQuestion] eligible count:', eligible.length);
        
        if (!fallback) { // no eligible questions
            console.log(`[dailyQuestion] no eligible questions for chatroom ${chatId} found`);
            return null;   
        }
        return fallback.question;
    }
    return eligible[Math.floor(Math.random() * eligible.length)];
}

// get today's question, returns the question and info about user answers
export async function getTodaysQuestion(chatId, userId) {
    // fetch the most recent sent question
    const dailyQuestion = await DailyQuestion.findOne({
        where: { chatId },
        order: [['date', 'DESC']],
        limit: 1,
        include: [{ model: Question, as: 'question' }],
    });
    // if null, no question has been dispatched today yet
    if (!dailyQuestion) return null;

    const userAnswer = await UserDailyAnswer.findOne({
        where: { dailyQuestionId: dailyQuestion.id, userId },
    });

    return {
        dailyQuestionId: dailyQuestion.id,
        question: dailyQuestion.question.question, // the actual question text
        date: dailyQuestion.date,
        answeredCount: dailyQuestion.answeredCount, // how many users have answered
        hasAnswered: !!userAnswer,
        answerText: userAnswer?.answerText ?? null, // the user's question response
    };
}

// submit an answer
export async function submitAnswer(dailyQuestionId, userId, answerText) {
    const dailyQuestion = await DailyQuestion.findByPk(dailyQuestionId);
    if (!dailyQuestion) {
        throw AppError.notFound('Daily question not found');
    }

    // check if a response for today's question already exists from this user
    const existing = await UserDailyAnswer.findOne({
        where: { dailyQuestionId, userId },
    });
    if (existing) {
        throw AppError.badRequest("You have already answered today's question");
    }

    // submit the answer to the database
    const answer = await UserDailyAnswer.create({
        dailyQuestionId,
        userId,
        answerText,
    });

    // mark the question as answered
    await dailyQuestion.increment('answeredCount');
    // which also considers the chatroom to be active
    await ChatRoom.update({ isActive: true }, { where: { id: dailyQuestion.chatId } });

    console.log(`[dailyQuestion] user ${userId} successfully submitted a dailyq answer`);
    return {
        dailyQuestionId,
        chatId: dailyQuestion.chatId,
        answeredAt: answer.answeredAt,
    };
}