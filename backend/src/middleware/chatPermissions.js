import ChatMembership from '../models/ChatMembership.js';
import AppError from '../utils/errors/AppError.js';

export const verifyOwner = async (req, res, next) => {
  try {
    // Check both params and body to be flexible
    const chatId = req.params.id || req.body.chatId || req.params.chatId;
    
    if (!chatId) {
      return next(AppError.badRequest("Chat ID is required to verify ownership"));
    }

    const membership = await ChatMembership.findOne({
      where: { chatId, userId: req.user.uid }
    });

    // Must return 403 Forbidden for unauthorized members
    if (!membership || membership.role !== 'owner') {
      // Use the AppError.forbidden helper if it exists, otherwise:
      throw AppError.forbidden('Only the chat owner can perform this action.', { code: 'FORBIDDEN_OWNER_ONLY' });
    }

    next();
  } catch (error) {
    next(error); // Pass to global errorHandler
  }
};