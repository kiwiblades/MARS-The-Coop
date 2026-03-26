/*
    Sequelize associations describe multiplicity/relationships between tables
    so Sequelize can generate joins automatically and provide helper methods.

    It's only a convenience, referential integrity must still be enforced through
    foreign key constraints.
*/

import User from "./userModel.js";
import RefreshToken from "./RefreshToken.js";
import EmailVerificationToken from "./EmailVerificationToken.js";
import ChatRoom from "./ChatRoom.js";
import ChatMembership from "./ChatMembership.js";
import Message from "./Message.js";
import ChatSettings from "./ChatSettings.js";
import BannedUser from "./BannedUser.js";
import GlobalQuestion from "./GlobalQuestion.js";

// define associations after all models are imported
export function initModels() {
    User.hasMany(RefreshToken, { foreignKey: "userId" });
    RefreshToken.belongsTo(User, { foreignKey: "userId" });

    User.hasMany(EmailVerificationToken, { foreignKey: "userId" });
    EmailVerificationToken.belongsTo(User, { foreignKey: "userId" });

    // User <-> ChatRoom is many-to-many, so ChatMembership is the junction table
    User.belongsToMany(ChatRoom, {
        through: ChatMembership,
        foreignKey: "userId",
        otherKey: "chatId",
        as: 'chatrooms'
    });
  
    ChatRoom.belongsToMany(User, {
        through: ChatMembership,
        foreignKey: "chatId",
        otherKey: "userId",
        as: 'participants',
    });

    ChatRoom.hasMany(ChatMembership, {
        foreignKey: "chatId",
    });
  
    ChatMembership.belongsTo(ChatRoom, {
        foreignKey: "chatId",
    });

    User.hasMany(ChatMembership, {
        foreignKey: "userId",
    });
  
    ChatMembership.belongsTo(User, {
        foreignKey: "userId",
    });

    // --- Chat Settings & Persistence ( ---
    // One-to-One: Every ChatRoom has exactly one Settings row.
    // onDelete: "CASCADE" ensures when the room is deleted, settings vanish too.
    ChatRoom.hasOne(ChatSettings, { 
        foreignKey: "chatId", 
        as: "settings",
        onDelete: "CASCADE" 
    });
    ChatSettings.belongsTo(ChatRoom, { foreignKey: "chatId" });

    // --- Ban Management ---
    // A room has many banned users.
    ChatRoom.hasMany(BannedUser, { 
        foreignKey: "chatId", 
        as: "bannedUsers",
        onDelete: "CASCADE" 
    });
    BannedUser.belongsTo(ChatRoom, { foreignKey: "chatId" });

    // A user can be banned from many rooms.
    User.hasMany(BannedUser, { foreignKey: "userId" });
    BannedUser.belongsTo(User, { foreignKey: "userId" });

    // --- Cascade Logic for Members/Messages ---
    // Ensure that when a room is deleted, all member records and messages are purged.
    ChatRoom.hasMany(ChatMembership, { foreignKey: "chatId", onDelete: "CASCADE" });
    ChatMembership.belongsTo(ChatRoom, { foreignKey: "chatId" });

    ChatRoom.hasMany(Message, { foreignKey: "chatId", onDelete: "CASCADE" });
    Message.belongsTo(ChatRoom, { foreignKey: "chatId" });

    // --- Existing User/Member/Message logic ---
    User.hasMany(ChatMembership, { foreignKey: "userId" });
    ChatMembership.belongsTo(User, { foreignKey: "userId" });

    User.hasMany(Message, { foreignKey: "sender_id" });
    Message.belongsTo(User, { foreignKey: "sender_id", as: 'sender' });
}

