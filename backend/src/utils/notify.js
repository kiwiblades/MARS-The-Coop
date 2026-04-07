import admin from 'firebase-admin';
import User from '../models/userModel.js';

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