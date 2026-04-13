import AppError from "../utils/errors/AppError.js";
import { getTodaysQuestion, today } from "../utils/dailyQuestion.js";
import { dispatchDailyQuestions } from "../utils/questionScheduler.js";
import DailyQuestion from "../models/DailyQuestion.js";
import UserDailyAnswer from "../models/UserDailyAnswer.js";
import User from "../models/userModel.js";
import Question from "../models/Question.js";
import ChatMembership from "../models/ChatMembership.js";

// for use when loading a chatroom
export async function getTodaysDailyQuestion(req, res) {
    const { chatId } = req.params;
    const userId = req.user.uid;
    if (!chatId || !userId) {
        throw AppError.badRequest('chatId is required');
    }

    const result = await getTodaysQuestion(chatId, userId);
    if (!result) {
        return res.status(404).json({ message: 'No daily question for today' });
    }

    return res.json(result);
}

// fetch all current answers for today's question
export async function getDailyQuestionAnswers(req, res) {
    const { chatId } = req.params;
    const todayStr = new Date().toISOString().split('T')[0];
    console.log('[DailyQuestion] getAnswers - chatId:', chatId, 'date:', todayStr);

    const dailyQuestion = await DailyQuestion.findOne({
        where: { chatId },
        order: [['date', 'DESC']],
        limit: 1,
        include: [{ model: Question, as: 'question' }],
    });
    console.log('[DailyQuestion] found dailyQuestion:', dailyQuestion?.id ?? 'null');
    if (!dailyQuestion) return res.json([]); // no question yet

    const answers = await UserDailyAnswer.findAll({
        where: { dailyQuestionId: dailyQuestion.id },
        include: [{
            model: User,
            as: 'user',
            attributes: ['username', 'pigeonId'],
        }],
        order: [['answeredAt', 'ASC']],
    });

    res.json(answers.map(a => ({
        id: a.id,
        dailyQuestionId: a.dailyQuestionId,
        userId: a.userId,
        username: a.user?.username ?? 'Unknown',
        pigeonId: a.user?.pigeonId ?? null,
        answerText: a.answerText,
        answeredAt: a.answeredAt,
    })));
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

// manually clear pending dq status
export async function clearPending(req, res) {
    await ChatMembership.update(
        { hasPendingQuestion: false },
        { where: {} } // clears all
    );
    res.json({ message: 'pending question statuses cleared' });
}

