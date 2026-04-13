import { submitAnswer } from "../utils/dailyQuestion.js"
import { clearPendingQuestion } from "../utils/notify.js";

export const registerDailyQuestionHandlers = (io, socket) => {
    socket.on('submit_daily_answer', async ({ dailyQuestionId, userId, answerText, chatId }) => {
        try {
            const result = await submitAnswer(dailyQuestionId, userId, answerText);

            // clear pending badge for the user
            await clearPendingQuestion(chatId, userId);
            socket.emit('pending_question_update', {
                chatId,
                hasPendingQuestion: false,
            });

            // confirm success to answering user
            socket.emit('daily_answer_accepted', {
                dailyQuestionId: result.dailyQuestionId,
                answeredAt: result.answeredAt,
            });

            // notify other members that a user has answered
            io.to(chatId).emit('daily_answer_update', {
                dailyQuestionId: result.dailyQuestionId,
                userId,
                answeredAt: result.answeredAt,
            });

            console.log(`[dailyQuestion] user ${userId} answered question ${dailyQuestionId} in room ${chatId}`);
        } catch(e) {
            console.error('[dailyQuestion] error submitting answer:', e.message);
            socket.emit('daily_question_error', { message: e.message });
        }
    });
};