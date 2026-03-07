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
app.use('/chat', messageRoutes);   // Handles /chat/:id/messages
app.use('/chat', chatroomRoutes);  // Handles /chat/:id and /chat/:id/leave

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

    User.hasMany(Message, { foreignKey: "sender_id" });
    Message.belongsTo(User, { foreignKey: "sender_id", as: 'sender' });
}

