/**
 * Socket.io Handler for Chat Messaging
 * This handles the real-time events for User Story ID 14.
 */

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
    socket.on('send_message', (data) => {
        const { chat_id, content, sender_username } = data;
        
        // Broadcast to everyone in the room (including sender)
        io.to(chat_id).emit('receive_message', {
            content,
            sender_username,
            createdAt: new Date()
        });
    });
};