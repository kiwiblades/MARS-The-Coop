import ChatMembership from '../models/ChatMembership.js';
import AppError from '../utils/errors/AppError.js';

export const verifyOwner = async (req, res, next) => {
  const chatId = req.params.id || req.body.chatId;
  
  const membership = await ChatMembership.findOne({
    where: { chatId, userId: req.user.uid }
  });

  if (!membership || membership.role !== 'owner') {
    return next(new AppError('Only the chat owner can perform this action.', 403));
  }
  next();
};