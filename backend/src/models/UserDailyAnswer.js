import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const UserDailyAnswer = sequelize.define('UserDailyAnswer', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    dailyQuestionId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: { model: 'dailyquestion', key: 'id' },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: { model: 'user', key: 'uid' },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    answerText: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    answeredAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
        allowNull: false,
    },
}, {
    tableName: 'userdailyanswer',
    timestamps: true,
    indexes: [
        // one answer per room per day
        { unique: true, fields: ['dailyQuestionId', 'userId'] }
    ]
});

export default UserDailyAnswer;