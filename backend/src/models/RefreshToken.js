import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const RefreshToken = sequelize.define('RefreshToken', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    userId: {
        type: DataTypes.UUID, // assuming id for user is uuid
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
    revokedAt: {
        type: DataTypes.DATE,
        allowNull: true,
    },
}, {
    tableName: 'refreshtoken',
    timestamps: true,
    indexes: [
        { fields: ["userId"] },
        { fields: ["expiresAt"] },
        { fields: ["revokedAt"] },
    ],
});

export default RefreshToken;