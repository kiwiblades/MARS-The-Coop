import { ChatRoom, ChatSettings } from '../models/index.js';

export const updateSettings = async (req, res, next) => {
  const { name, relationshipType, allowedTopics, difficulty } = req.body;
  const chatId = req.params.id;

  try {
    // Update Room Name (ChatRoom Table)
    if (name) {
      await ChatRoom.update({ name }, { where: { id: chatId } });
    }

    // Update Settings (ChatSettings Table) 
    // Using findOrCreate + update to ensure the row exists
    const [settings] = await ChatSettings.findOrCreate({
      where: { chatId }
    });

    await settings.update({ 
      relationshipType, 
      allowedTopics, 
      difficulty 
    });

    res.status(200).json({ 
      message: 'Settings updated successfully',
      settings 
    });
  } catch (error) {
    next(error);
  }
};