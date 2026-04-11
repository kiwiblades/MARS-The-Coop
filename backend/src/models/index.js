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
import GlobalQuestion from "./GlobalQuestion.js";

// define associations after all models are imported
export function initModels() {
    // Auth Tokens 
    User.hasMany(RefreshToken, { foreignKey: "userId" });
    RefreshToken.belongsTo(User, { foreignKey: "userId" });

    User.hasMany(EmailVerificationToken, { foreignKey: "userId" });
    EmailVerificationToken.belongsTo(User, { foreignKey: "userId" });

    // ChatRoom & Memberships (Many-to-Many) 
    // This allows: user.getChatrooms() and chatroom.getParticipants()
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

    // Direct Membership Links (For querying roles/pins)
    // Essential for: ChatMembership.findAll({ where: { userId } })
    ChatRoom.hasMany(ChatMembership, { foreignKey: "chatId", onDelete: "CASCADE" });
    ChatMembership.belongsTo(ChatRoom, { foreignKey: "chatId" });

    User.hasMany(ChatMembership, { foreignKey: "userId", onDelete: "CASCADE" });
    ChatMembership.belongsTo(User, { foreignKey: "userId" });

    // Chat Settings (One-to-One) 
    // Persists relationshipType and allowedTopics
    ChatRoom.hasOne(ChatSettings, { 
        foreignKey: "chatId", 
        as: "settings",
        onDelete: "CASCADE" 
    });
    ChatSettings.belongsTo(ChatRoom, { foreignKey: "chatId" });

    // Messages & History 
    // foreignKey "chat_id" to match Message.js
    ChatRoom.hasMany(Message, { foreignKey: "chat_id", onDelete: "CASCADE" });
    Message.belongsTo(ChatRoom, { foreignKey: "chat_id" });

    User.hasMany(Message, { foreignKey: "sender_id" });
    Message.belongsTo(User, { foreignKey: "sender_id", as: 'sender' });

    // a user has many daily answers (over many days)
    User.hasMany(UserDailyAnswer, { foreignKey: 'userId', as: 'dailyAnswers' });
    UserDailyAnswer.belongsTo(User, { foreignKey: 'userId', as: 'user' });

    // models/index.js
    User.hasMany(Journal, { foreignKey: 'ownerId', as: 'WrittenJournals' });
    Journal.belongsTo(User, { foreignKey: 'subjectId', as: 'SubjectProfile' });
}


