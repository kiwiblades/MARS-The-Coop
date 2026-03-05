import Message from '../models/Message.js';
import AppError from '../utils/errors/AppError.js';

export const sendMessage = async (req, res, next) => {
    try {
        const { content, chat_id } = req.body;
        const sender_id = req.user.uid; // From authMiddleware

        // // Validate sender membership before saving
        // // Note: Replace 'ChatMember' with your actual membership model name
        // const isMember = await req.models.ChatMember.findOne({ 
        //     where: { user_id: sender_id, chat_id } 
        // });

        // if (!isMember) {
        //     throw AppError.forbidden('You are not a member of this chat');
        // }

        // Save to database
        const newMessage = await Message.create({ content, sender_id, chat_id });

        // Real-time broadcast via Socket.io
        const io = req.app.get('io');
        io.to(chat_id).emit('receive_message', newMessage);

        // Return 201 Created
        res.status(201).json(newMessage); 
    } catch (error) {
        next(error);
    }
};

export const getChatHistory = async (req, res, next) => {
    try {
        const { id } = req.params; // chat_id from URL

        // Return array in chronological order
        const messages = await Message.findAll({
            where: { chat_id: id },
            order: [['createdAt', 'ASC']], // Oldest to newest
            include: [{ 
                model: req.models.User, 
                as: 'sender', 
                attributes: ['username'] // Include username join
            }]
        });

        res.status(200).json(messages);
    } catch (error) {
        next(error);
    }
};