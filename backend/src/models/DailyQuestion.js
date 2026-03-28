import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const DailyQuestion = sequelize.define('DailyQuestion', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    // the chatroom the question is sent to
    chatId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: { model: "chatroom", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    // id of the sent question
    questionId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: { model: 'question', key: 'id' },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    // date the question was sent
    date: {
        type: DataTypes.DATEONLY, // one question per day, so only date is needed 
        allowNull: false,
    },
    // checks room activity
    answeredCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        allowNull: false,
    },
    // tracks if the question sending was successful for retries
    wasDelivered: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: false,
    },
}, {
    tableName: 'dailyquestion',
    timestamps: true,
    indexes: [
        // enforce one question per room per day
        { unique: true, fields: ['chatId', 'date'] }
    ]
});

export default DailyQuestion;