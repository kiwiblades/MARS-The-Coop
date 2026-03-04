import { DataTypes } from 'sequelize';
import { sequelize } from '../db/sequelize.js';

// Define the Messages table with required fields
const Message = sequelize.define('Message', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    content: {
        type: DataTypes.TEXT,
        allowNull: false // Saves message text
    },
    sender_id: {
        type: DataTypes.UUID,
        allowNull: false // Links to the sender
    },
    chat_id: {
        type: DataTypes.UUID,
        allowNull: false // Links to the chat room
    }
}, {
    timestamps: true, // Generates the server timestamp automatically
    updatedAt: false  // We only need createdAt for chat history
});

// Define association to Join with User table for usernames
export const associateMessages = (models) => {
    Message.belongsTo(models.User, { foreignKey: 'sender_id', as: 'sender' });
};

export default Message;