import Message from '../models/Message.js';
import User from '../models/userModel.js';
import ChatMembership from '../models/ChatMembership.js';
import ChatRoom from '../models/ChatRoom.js';
import AppError from '../utils/errors/AppError.js';
import { Op } from 'sequelize';

export const sendMessage = async (req, res, next) => {
    try {
        const chat_id = req.params.chatId;
        const { content } = req.body;
        const sender_id = req.user.uid; // From authMiddleware

		// Membership Validation Replacement
        if (!chat_id || !sender_id || !content) {
            throw AppError.badRequest('Missing chat_id, sender identity, or message content');
        }

        // 2. membership query to check if sender is part of the chat room
        const isMember = await ChatMembership.findOne({ 
            where: { userId: sender_id, chatId: chat_id } 
        });

        if (!isMember) {
            throw AppError.forbidden('You are not a member of this chat room.');
        }

        // Save to database
        const newMessage = await Message.create({ content, sender_id, chat_id });

        await ChatRoom.update(
            { lastMsgSent: newMessage.createdAt },
            { where: { id: chat_id } }
        );

        // Real-time broadcast via Socket.io
        const io = req.app.get('io');
        const sender = await User.findByPk(sender_id, {
            attributes: ['username', 'pigeonId'],
        });
        io.to(chat_id).emit('receive_message', {
            id: newMessage.id,
            content: newMessage.content,
            sender_id: newMessage.sender_id,
            createdAt: newMessage.createdAt,
            sender: {
                username: sender?.username ?? '',
                pigeonId: sender?.pigeonId ?? null,
            },
        });

        // Return 201 Created
        res.status(201).json(newMessage); 
    } catch (error) {
        next(error);
    }
};

export const getChatHistory = async (req, res, next) => {
    try {
        const { chatId } = req.params;
        const { before, limit = 50 } = req.query; // Default to 50 if not specified

        const queryOptions = {
            where: { chat_id: chatId },
            limit: parseInt(limit),
            // fetch DESC (newest first) to get the most recent batch
            order: [['createdAt', 'DESC']], 
            include: [{ 
                model: User, 
                as: 'sender', 
                attributes: ['username', 'pigeonId'] 
            }]
        };

        // If 'before' exists, fetch messages older than this timestamp
        if (before) {
            queryOptions.where.createdAt = {
                [Op.lt]: new Date(before) 
            };
        }

        const messages = await Message.findAll(queryOptions);

        // Check if there are more messages to fetch
        const hasMore = messages.length === parseInt(limit);

        res.status(200).json({
            success: true,
            messages: messages, 
            hasMore: hasMore
        });
    } catch (error) {
        next(error);
    }
};