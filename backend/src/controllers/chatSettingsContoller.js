import { ChatRoom, ChatSettings } from '../models/index.js';

export const updateSettings = async (req, res, next) => {
  const { name, relationshipType, allowedTopics } = req.body;

  // Update Room Name
  if (name) {
    await ChatRoom.update({ name }, { where: { id: req.params.id } });
  }

  // Update Settings - AC 5
  await ChatSettings.update(
    { relationshipType, allowedTopics },
    { where: { chatId: req.params.id } }
  );

  res.status(200).json({ message: 'Settings updated successfully' });
};