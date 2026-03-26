const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

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
    type: DataTypes.ENUM('Family', 'Romantic', 'Professional', 'Friendship', 'Custom'),
    defaultValue: 'Friendship'
  },
  // Manual overrides for specific topics stored as a JSON array
  allowedTopics: {
    type: DataTypes.JSON, 
    defaultValue: [] 
  },
  difficulty: {
    type: DataTypes.ENUM('Casual', 'Deep', 'Intimate'),
    defaultValue: 'Casual'
  }
}, {
  timestamps: true
});

export default ChatSettings;