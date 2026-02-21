import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const RefreshToken = sequelize.define('RefreshToken', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    // the user assigned to the token
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
        references: { model: "user", key: "uid" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    // the actual token value is stored as a hash rather than plaintext
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