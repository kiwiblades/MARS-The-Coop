import {
    incrementUnread,
    clearUnread,
    setPendingQuestion,
    clearPendingQuestion,
} from "../utils/notify.js";

export const registerNotificationHandlers = (io, socket) => {
    // when the user opens a chat room, clear their unread count
    socket.on('mark_chat_read', async ({ chatId, userId }) => {
        try {
            await clearUnread(chatId, userId);
            // confirm to client that unread count is cleared
            socket.emit('chat_marked_read', { chatId });
        } catch(e) {
            console.error('[notifications] error marking chat read:', e.message);
            socket.emit('notification_error', { message: e.message });
        }
    });

    // // when dq is dispatched, mark all room members as having a pending question
    // socket.on('notify_daily_question', async ({ chatId }) => {
    //     try {
    //         await setPendingQuestion(chatId, true);
    //         io.to(chatId).emit('pending_question_update', {
    //             chatId,
    //             hasPendingQuestion: true,
    //         });
    //     } catch(e) {
    //         console.error('[notifications] error setting pending question:', e.message);
    //         socket.emit('notification_error', { message: e.message });
    //     }
    // });

    // when a user answers the dq, clear their pending status
    // socket.on('notify_answer_submitted', async ({ chatId, userId }) => {
    //     try {
    //         await clearPendingQuestion(chatId, userId);
    //         // only emit back to this user
    //         socket.emit('pending_question_update', {
    //             chatId,
    //             hasPendingQuestion: false,
    //         });
    //     } catch(e) {
    //         console.error('[notifications] error clearing pending question:', e.message);
    //         socket.emit('notification_error', { message: e.message });
    //     }
    // });
}