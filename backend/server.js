import { config } from './src/config.js'; // load dotenv first so process.env is populated
import express from 'express'; // http framework
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import { sequelize } from './src/db/sequelize.js';
import { initModels } from './src/models/index.js';
import { startSyncScheduler } from './src/utils/sheetSync.js';
import admin from 'firebase-admin';
import { createRequire } from 'module';

/*
    The server consists of multiple parts:
    - Express app: request handler + middleware stack, dictates how to respond to HTTP requests.
    - Node HTTP server: binds to a port and accepts connections.
    - Socket.io: attaches to the HTTP server to enable bidirectional real-time events (e.g., instant messaging).
*/

const app = express(); // create a request handler via Express
app.use(express.json()); // attach json parsing middleware

const server = createServer(app); // create the HTTP server
const io = new Server(server); // attach socket.io to the server object
app.set('io', io); // Allows controllers to use req.app.get('io')
import { socketAuth } from './src/middleware/socketAuth.js';
io.use(socketAuth); // attach socket auth middleware

const require = createRequire(import.meta.url); // create require anchored to the file location
const serviceAccount = require(config.firebase.keyFilePath); // load the private key json file
// initialie firebase admin sdk, needed for push notifications
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

// attach API routes here
import healthRoutes from './src/routes/healthRoutes.js';
import authRoutes from './src/routes/authRoutes.js';
import userRoutes from './src/routes/userRoutes.js';
import chatroomRoutes from './src/routes/chatroomRoutes.js';
import messageRoutes from './src/routes/messageRoutes.js';
import syncRoutes from './src/routes/syncRoutes.js';
import dailyQuestionRoutes from './src/routes/dailyQuestionRoutes.js';
import notificationRoutes from './src/routes/notificationRoutes.js';
import journalRoutes from './src/routes/journalRoutes.js';

app.use('/health', healthRoutes);
app.use('/auth', authRoutes);
app.use('/api/auth', authRoutes); // alias
app.use('/user', userRoutes);
app.use('/chatroom', chatroomRoutes);
app.use('/chat', messageRoutes);
app.use('/sync', syncRoutes);
app.use('/daily-question', dailyQuestionRoutes);
app.use('/notifications', notificationRoutes);
app.use('/api/journals', journalRoutes);

// for testing only
import devRoutes from './src/dev/devRoutes.js';
app.use('/dev', devRoutes);


import AppError from './src/utils/errors/AppError.js';
import errorHandler from './src/middleware/errorHandler.js';
import { startQuestionScheduler } from './src/utils/questionScheduler.js';
import { registerDailyQuestionHandlers } from './src/sockets/dailyQuestionHandler.js';
import { registerChatHandlers } from './src/sockets/chatHandler.js';
import { registerNotificationHandlers } from './src/sockets/notificationHandler.js';

// error-handling middleware muist be attached last
app.get("/favicon.ico", (req, res) => res.status(204).end()); // ignore browser favicon request
app.use((req, res, next) => next(AppError.notFound('Route not found'))); // 404 for unknown routes
app.use(errorHandler);

await sequelize.authenticate();
console.log("Database connected");

// dev only: sync models with database (create tables if they don't exist)
initModels();
await sequelize.sync({ alter: true }); // alter: true modifies tables to match if the model has changed
//await sequelize.sync({ force: true }); // TEMPORARY
console.log("Database models synced");

// // ---------------------------------- TEMPORARY FIX FOR DB SYNC ISSUES --
// // If schema changes cause errors, use { force: true } to drop and recreate tables (data loss warning) 
// //  change back to { alter: true } after the issue is resolved to prevent accidental data loss in the future

// // 1. Initialize models
// initModels();

// // 2. TEMPORARY FIX: Change { alter: true } to { force: true }
// // This will drop ALL tables and recreate them cleanly.
// // Use this once to clear the error, then change it back to { alter: true }
// await sequelize.sync({ force: true }); 

// // -------------------------- END OF TEMPORARY FIX FOR DB SYNC ISSUES ------------------------

console.log("Database models recreated and synced successfully");

// listen on connection events for the incoming socket
io.on('connection', (socket) => {
    console.log('Socket connected: ', socket.id);
    // join personal room immedaitely upon connect: used for direct events
    // such as unread counts + chat updates before they open any chatroom
    const userId = socket.user?.uid;
    if (userId) {
        socket.join(userId);
        console.log(`[socket] user ${userId} joined personal room`);
    } else {
        console.warn(`[socket] no userId on socket at connection time`);
    }

    registerChatHandlers(io, socket);
    registerDailyQuestionHandlers(io, socket);
    registerNotificationHandlers(io, socket);

    socket.on('disconnect', () => {
        console.log('Socket disconnected: ', socket.id);
    });
});

// start server once everything is attached
const port = config.SV_PORT;
server.listen(port, () => console.log(`Server running on port ${port}`)); // display a server status upon startup
startSyncScheduler();
startQuestionScheduler(io);

// if (process.env.NODE_ENV !== 'test') {
//     const port = config.SV_PORT;
//     server.listen(port, () => console.log(`Server running on port ${port}`));
// }

// export default app; // This allows the test file to see your Express logic
