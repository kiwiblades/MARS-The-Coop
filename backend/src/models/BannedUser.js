import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

const BannedUser = sequelize.define('BannedUser', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  chatId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false
  },
  reason: {
    type: DataTypes.STRING,
    allowNull: true // Optional note on why they were banned
  },
  bannedBy: {
    type: DataTypes.UUID, // Should always be the ownerId
    allowNull: false
  }
}, {
  // Ensure a user can't be banned twice from the same room
  indexes: [
    {
      unique: true,
      fields: ['chatId', 'userId']
    }
  ]
});

export default BannedUser;