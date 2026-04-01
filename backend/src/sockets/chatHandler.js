/**
 * Socket.io Handler for Chat Messaging
 * This handles the real-time events.
 */

import ChatMembership from "../models/ChatMembership.js";
import ChatRoom from "../models/ChatRoom.js";
import Message from "../models/Message.js";
import User from "../models/userModel.js";

export const registerChatHandlers = (io, socket) => {
    
    // 1. Join Room Logic
    // Users must join a room based on chat_id to receive messages for that specific chat
    socket.on('join_room', (chat_id) => {
        socket.join(chat_id);
        console.log(`User ${socket.id} joined room: ${chat_id}`);
    });

    // 2. Leave Room Logic
    // Useful for cleaning up when a user switches chats
    socket.on('leave_room', (chat_id) => {
        socket.leave(chat_id);
        console.log(`User ${socket.id} left room: ${chat_id}`);
    });

    /**
     * NOTE: Message persistence (saving to DB) is handled in messageController.js.
     * After the controller saves the message, it uses req.app.get('io') 
     * to broadcast. This handler is for incoming client-side socket triggers 
     * if you choose not to use the HTTP POST for the initial send.
     */
    socket.on('send_message', async (data) => {
        const { chat_id, content, sender_id } = data;
        try {
            // verify the sender is a member
            const isMember = await ChatMembership.findOne({
                where: { userId: sender_id, chatId: chat_id }
            });
            if (!isMember) {
                socket.emit('message_error', { message: 'You are not a member of this chat' });
                return;
            }

            // save to db to get an id, timestamp, and sender info
            const message = await Message.create({ chat_id, content, sender_id });

            // update lastMsgSent
            await ChatRoom.update(
                { lastMsgSent: message.createdAt },
                { where: { id: chat_id } }
            );

            // fetch sender info to immediately update the chat screen
            const sender = await User.findByPk(sender_id, {
                attributes: ['username', 'pigeonId' ],
            });

            // Broadcast to everyone in the room (including sender)
            io.to(chat_id).emit('receive_message', {
                id: message.id,
                content: message.content,
                sender_id: message.sender_id,
                createdAt: message.createdAt,
                sender: {
                    username: sender?.username ?? '',
                    pigeonId: sender?.pigeonId ?? null,
                },
            });
        } catch(e) {
            console.error('[chatHandler] error saving message:', e.message);
            socket.emit('message_error', { message: 'Failed to send message.' });
        }
    });
        
        
    // 3. Room Settings Update
    // This allows the UI to update the name/topics instantly for all participants
    socket.on('room_update', (data) => {
        const { chatId, newName, relationshipType } = data;
        // Broadcast the changes to everyone else in the room
        socket.to(chatId).emit('room_settings_changed', { 
            newName, 
            relationshipType 
        });
    });

    // 4. Message Handling
    socket.on('send_message', (data) => {
        const { chat_id, content, sender_username } = data;
        io.to(chat_id).emit('receive_message', {
            content,
            sender_username,
            createdAt: new Date()
        });
    });

    // /**
    //  * NOTE: Message persistence (saving to DB) is handled in messageController.js.
    //  * After the controller saves the message, it uses req.app.get('io') 
    //  * to broadcast. This handler is for incoming client-side socket triggers 
    //  * if you choose not to use the HTTP POST for the initial send.
    //  */
    // socket.on('send_message', (data) => {
    //     const { chat_id, content, sender_username } = data;
        
    //     // Broadcast to everyone in the room (including sender)
    //     io.to(chat_id).emit('receive_message', {
    //         content,
    //         sender_username,
    //         createdAt: new Date()
    //     });
    // });
};