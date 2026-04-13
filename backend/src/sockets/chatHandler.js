/**
 * Socket.io Handler for Chat Messaging
 * This handles the real-time events.
 */

import ChatMembership from "../models/ChatMembership.js";
import ChatRoom from "../models/ChatRoom.js";
import Message from "../models/Message.js";
import User from "../models/userModel.js";
import { incrementUnread, notifyUsers } from "../utils/notify.js";

export const registerChatHandlers = (io, socket) => {

    // join a personal room keyed by userId so server can emit directly to the user from any handler
    // such as unread count updates
    // const userId = socket.user?.uid;
    // if (userId) {
    //     socket.join(userId);
    //     console.log(`[chatHandler] user ${userId} joined personal room`);
    // }
    
    // 1. Join Room Logic
    // Users must join a room based on chat_id to receive messages for that specific chat
    socket.on('join_room', (chat_id) => {
        socket.join(chat_id);
        console.log(`[chatHandler] User ${socket.id} joined room: ${chat_id}`);
    });

    // 2. Leave Room Logic
    // Useful for cleaning up when a user switches chats
    socket.on('leave_room', (chat_id) => {
        socket.leave(chat_id);
        console.log(`[chatHandler] User ${socket.id} left room: ${chat_id}`);
    });

    /**
     * NOTE: Message persistence (saving to DB) is handled in messageController.js.
     * After the controller saves the message, it uses req.app.get('io') 
     * to broadcast. This handler is for incoming client-side socket triggers 
     * if you choose not to use the HTTP POST for the initial send.
     */

    // 3. Message Handling
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

            // incremenmt unread counts for all members except the sender
            const updatedMembers = await incrementUnread(chat_id, sender_id);

            // notify each member's personal room so their mail screen pdates the unread badge 
            // and message preview w/out a full reload of mail screen
            for (const member of updatedMembers) {
                io.to(member.userId).emit('unread_count_update', {
                    chatId: chat_id,
                    unreadCount: member.unreadCount,
                });
                io.to(member.userId).emit('chat_updated', {
                    chatId: chat_id,
                    lastSentMessage: content,
                    lastSentTime: message.createdAt,
                });
            }
            console.log(`[chatHandler] message sent in room ${chat_id} by ${sender_id}`);

            // fetch online users
            const socketsInRoom = await io.in(chat_id).fetchSockets();
            const onlineIds = new Set(socketsInRoom.map(s => s.user?.uid));

            // determine which members are offline/aren't connected to the live socket
            const offlineMembers = [...new Set(
                updatedMembers.map(m => m.userId).filter(uid => !onlineIds.has(uid))
            )];

            const chatroom = await ChatRoom.findByPk(chat_id, { attributes: ['name'] });

            // send push notifications to users who were offline
            await notifyUsers(offlineMembers, {
                title: `${chatroom?.name ?? 'New Message'}`,
                body: `${sender?.username ?? 'Someone'}: ${content}`,
                data: { chatId: chat_id },
            });

        } catch(e) {
            console.error('[chatHandler] error saving message:', e.message);
            socket.emit('message_error', { message: 'Failed to send message.' });
        }
    });
        
        
    // 4. Room Settings Update
    // This allows the UI to update the name/topics instantly for all participants
    socket.on('room_update', (data) => {
        const { chatId, newName, relationshipType } = data;
        // Broadcast the changes to everyone else in the room
        socket.to(chatId).emit('room_settings_changed', { 
            newName, 
            relationshipType 
        });
    });

    socket.on('typing_indicator', ({ chatId, userId, isTyping }) => {
        socket.to(chatId).emit('user_typing', { userId, isTyping });
    });
};