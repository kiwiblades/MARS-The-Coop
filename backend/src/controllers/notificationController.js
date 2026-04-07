import AppError from "../utils/errors/AppError.js";
import { Op } from 'sequelize'; 
import User from "../models/userModel.js";
import ChatMembership from "../models/ChatMembership.js";

export async function updateFcmToken(req, res) {
    const { fcmToken } = req.body;
    if (!fcmToken) {
        throw AppError.badRequest("fcmToken is required for update");
    }

    
    await User.update(
        { fcmToken },
        { where: { uid: req.user.uid } }
    );

    return res.status(204).end(); // success w/ no return content
}

export async function markChatRead(req, res) {
    await ChatMembership.update(
        { unreadCount: 0 },
        { where: { chatId: req.params.chatId, userId: req.user.uid } }
    );

    return res.status(204).end();
}

// get unread counts and question status for all user's chats
export async function getNotificationSummary(req, res) {
    const memberships = await ChatMembership.findAll({
        where: { userId: req.user.uid },
        attributes: ['chatId', 'unreadCount', 'hasPendingQuestion'],
    });

    return res.status(200).json({ memberships });
}