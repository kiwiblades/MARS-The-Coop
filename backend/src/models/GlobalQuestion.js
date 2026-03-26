const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const GlobalQuestion = sequelize.define('GlobalQuestion', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  text: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  // The topic tag (e.g., 'Nostalgia', 'Values')
  topic: {
    type: DataTypes.STRING,
    allowNull: false
  },
  // Used to map to RelationshipType (e.g., 'Family' or 'Professional')
  suggestedFor: {
    type: DataTypes.JSON, // Stores an array like ['Family', 'Friendship']
    defaultValue: []
  }
}, {
  timestamps: true
});

module.exports = GlobalQuestion;