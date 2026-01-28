/*
  This model is a small table used to verify Sequelize can connect and perform basic queries.
*/

import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

const Healthcheck = sequelize.define('Healthcheck', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
}, {
  tableName: 'healthchecks',
  timestamps: true, // adds createdAt
  updatedAt: false,
});

export default Healthcheck;