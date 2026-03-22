import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

const Question = sequelize.define('Question', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    // the actual question/prompt text, used as unique key when checking sheets for new additions
    question: {
        type: DataTypes.TEXT,
        allowNull: false,
        unique: true,
    },
    // Friends, Family, etc
    relationshipType: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    // Favorites, Would you rather, etc
    questionType: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    // all topics are stored in an array like ["Personal", "Religion", ...]
    topics: {
        type: DataTypes.ARRAY(DataTypes.STRING),
        allowNull: true,
        defaultValue: [],
    },
    // tracks when the row was last synced from the sheet
    syncedAt: {
        type: DataTypes.DATE,
        allowNull: true,
    },
}, {
    tableName: 'question',
    timestamps: true,
});

export default Question;