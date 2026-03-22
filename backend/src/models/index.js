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
import DailyQuestion from "./DailyQuestion.js";
import UserDailyAnswer from "./UserDailyAnswer.js";
import Question from "./Question.js";

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

    // one chatroom has many daily questions (over many days)
    ChatRoom.hasMany(DailyQuestion, { foreignKey: 'chatId', as: 'dailyQuestions' });
    DailyQuestion.belongsTo(ChatRoom, { foreignKey: 'chatId', as: 'chatRoom' });

    // a question can be used as many daily questions (across diff rooms/days)
    Question.hasMany(DailyQuestion, { foreignKey: 'questionId', as: 'dailyQuestions' });
    DailyQuestion.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

    // a daily question has many daily answers from users
    DailyQuestion.hasMany(UserDailyAnswer, { foreignKey: 'dailyQuestionId', as: 'answers' });
    UserDailyAnswer.belongsTo(DailyQuestion, { foreignKey: 'dailyQuestionId', as: 'dailyQuestion' });

    // a user has many daily answers (over many days)
    User.hasMany(UserDailyAnswer, { foreignKey: 'userId', as: 'dailyAnswers' });
    UserDailyAnswer.belongsTo(User, { foreignKey: 'userId', as: 'user' });
}