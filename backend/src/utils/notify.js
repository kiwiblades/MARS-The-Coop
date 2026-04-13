import admin from 'firebase-admin';
import User from '../models/userModel.js';
import ChatMembership from '../models/ChatMembership.js';
import { Op } from 'sequelize';

export async function notifyUsers(userIds, { title, body, data = {} }) {
    const users = await User.findAll({
        where: { uid: userIds, fcmToken: { [Op.ne]: null } },
        attributes: ['fcmToken'],
    });

    const tokens = users.map(u => u.fcmToken).filter(Boolean);
    if (!tokens.length) return; // none of the users have push notifs enabled

    await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        data, // extra values such as chatId for navigating to the chatroom
        android: {
            priority: 'high',
            notification: { channelId: 'default_channel' },
        },
    });
}

// increment unread counts for all members except the sender
export async function incrementUnread(chatId, senderId) {
    await ChatMembership.increment('unreadCount', {
        where: { chatId, userId: { [Op.ne]: senderId } },
    });

    // return updated rows so socket handler knows what to broadcast
    return ChatMembership.findAll({
        where: { chatId, userId: { [Op.ne]: senderId }},
        attributes: ['userId', 'unreadCount'],
    });
}

// clear unread count for a specific user in the room
export async function clearUnread(chatId, userId) {
    await ChatMembership.update(
        { unreadCount: 0 },
        { where: { chatId, userId } } 
    );
}

// set hasPendingQuestion for all members in a room
export async function setPendingQuestion(chatId, value) {
    await ChatMembership.update(
        { hasPendingQuestion: value },
        { where: { chatId } }
    );
}

export async function clearPendingQuestion(chatId, userId) {
    if (!chatId || !userId) {
        console.log('[clearPendingQuestion] missing chatId or userId');
        return;
    }
    await ChatMembership.update(
        { hasPendingQuestion: false },
        { where: { chatId, userId } }
    );
}