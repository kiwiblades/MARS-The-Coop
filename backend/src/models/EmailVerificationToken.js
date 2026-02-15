import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const EmailVerificationToken = sequelize.define('EmailVerificationToken', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    tokenHash: {
        type: DataTypes.STRING(128),
        allowNull: false,
        unique: true,
    },
    expiresAt: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    usedAt: {
        type: DataTypes.DATE,
        allowNull: true,
    },
}, {
    tableName: 'emailverificationtoken',
    timestamps: true,
    indexes: [
        { fields: ["userId"] },
        { fields: ["expiresAt"] },
    ]
});

export default EmailVerificationToken;