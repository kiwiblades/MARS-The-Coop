/* This defines the table schema. Use ownerId and subjectId as foreign keys to the Users table. */

import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

export const Journal = sequelize.define('Journal', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  ownerId: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'The user who wrote the journal entry'
  },
  subjectId: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'The user the journal entry is about'
  },
  // entries stored per array
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
  }
}, {
  timestamps: true, // Automatically creates createdAt and updatedAt
  tableName: 'journals'
});