import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

const ChatSettings = sequelize.define('ChatSettings', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  chatId: {
    type: DataTypes.UUID,
    allowNull: false,
    unique: true // One settings object per chatroom
  },
  relationshipType: {
    type: DataTypes.ENUM('Family', 'Romantic', 'Acquaintance', 'Friends'),
    defaultValue: 'Friends'
  },
  // Manual overrides for specific topics stored as a JSON array
  allowedTopics: {
    type: DataTypes.JSON, 
    defaultValue: [] 
  },
}, {
  timestamps: true
});

export default ChatSettings;