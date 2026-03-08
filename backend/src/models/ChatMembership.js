import { DataTypes } from "sequelize";
import { sequelize } from "../db/sequelize.js";

const ChatMembership = sequelize.define('ChatMembership', {
    // (userId, chatId) make up the composite primary key
    userId: {
        type: DataTypes.UUID,
        primaryKey: true,
        allowNull: false,
        // references the user model
        references: { model: "user", key: "uid" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    chatId: {
        type: DataTypes.UUID,
        primaryKey: true,
        allowNull: false,
        // references the chat room model
        references: { model: "chatroom", key: "id" },
        onDelete: "CASCADE",
        onUpdate: "CASCADE",
    },
    // pinned is stored here because it's per user per chatroom
    pinned: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: false,
    },
    role: {
        // TODO: determine if admin is needed
        type: DataTypes.ENUM('owner','admin','member'),
        defaultValue: 'member',
    },
    joinedAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    tableName: 'chatmembership',
    timestamps: true,
    // a user can only be a member of one chatroom once, so the composite key must be unique
    indexes: [
        { unique: true, fields: ["userId", "chatId"] }
    ]
});

export default ChatMembership;