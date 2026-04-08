import { BannedUser, Membership, User } from '../models/index.js';

// AC 1: Ban a user and kick them out
export const banUser = async (req, res, next) => {
    const { id: chatroomId } = req.params; // Chat ID from URL
    const { userIdToBan } = req.body;      // User to ban from Body

    try {
        // 1. Add to BannedUsers table
        await BannedUser.findOrCreate({
            where: { chatroomId, userId: userIdToBan }
        });

        // 2. Kick them from the chat (Delete their membership)
        await Membership.destroy({
            where: { chatroomId, userId: userIdToBan }
        });

        res.status(200).json({ message: 'User banned and removed from chat.' });
    } catch (error) {
        next(error);
    }
};

// AC 1: Unban a user
export const unbanUser = async (req, res, next) => {
    const { id: chatroomId } = req.params;
    const { userIdToUnban } = req.body;

    try {
        await BannedUser.destroy({
            where: { chatroomId, userId: userIdToUnban }
        });
        res.status(200).json({ message: 'User unbanned.' });
    } catch (error) {
        next(error);
    }
};

// Get the ban list (for the owner to see)
export const getBanList = async (req, res, next) => {
    try {
        const list = await BannedUser.findAll({
            where: { chatroomId: req.params.id },
            include: [{ model: User, attributes: ['username'] }]
        });
        res.status(200).json(list);
    } catch (error) {
        next(error);
    }
};