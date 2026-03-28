import AppError from "../utils/errors/AppError.js";
import { getTodaysQuestion, today } from "../utils/dailyQuestion.js";
import { dispatchDailyQuestions } from "../utils/questionScheduler.js";
import DailyQuestion from "../models/DailyQuestion.js";

// for use when loading a chatroom
export async function getTodaysDailyQuestion(req, res) {
    const { roomId } = req.params;
    const userId = req.user.uid;
    if (!roomId || !userId) {
        throw AppError.badRequest('roomId is required');
    }

    const result = await getTodaysQuestion(roomId, userId);
    if (!result) {
        return res.status(404).json({ message: 'No daily question for today' });
    }

    return res.json(result);
}

// return question history
export async function getDailyQuestionHistory(req, res) {
    // TODO
}

// manually trigger daily question w/out cron for testing
export async function manualDispatch(req, res) {
    const io = req.app.get('io');
    await dispatchDailyQuestions(io);
    res.json({ message: 'dispatch complete' });
}

// manually reset today's daily questions for testing
export async function resetToday(req, res) {
    const todayStr = today();
    const deleted = await DailyQuestion.destroy({
        where: { date: todayStr },
    });
    if (!deleted) {
        throw AppError.badRequest('No questions, or questions failed to delete');
    }
    res.json({ message: `deleted ${deleted} daily question(s) for today` });
}