import { ChatRoom, ChatSettings } from '../models/index.js';

export const updateSettings = async (req, res, next) => {
  const { name, relationshipType, allowedTopics, difficulty } = req.body;
  const chatId = req.params.id;

  try {
    // Update Room Name (ChatRoom Table)
    if (name) {
      await ChatRoom.update({ name }, { where: { id: chatId } });
    

      // Broadcast name change to all participants via Socket.io
      const io = req.app.get('io');
      io.to(chatId).emit('room_name_updated', { chatId, newName: name });

    }

    // Update Settings (ChatSettings Table) 
    // Using findOrCreate + update to ensure the row exists
    const settings = await ChatSettings.findOne({ where: { chatId } });
    if (settings) {
      await settings.update({ relationshipType, allowedTopics });
    }

    res.status(200).json({ 
      message: 'Settings updated successfully',
      settings 
    });
  } catch (error) {
    next(error);
  }
};