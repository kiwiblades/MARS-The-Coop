import { config } from './src/config.js'; // load dotenv first so process.env is populated
import express from 'express'; // http framework
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import { sequelize } from './src/db/sequelize.js';
import { initModels } from './src/models/index.js';

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

// TODO: attach API routes here
import healthRoutes from './src/routes/healthRoutes.js';
import authRoutes from './src/routes/authRoutes.js';
app.use('/health', healthRoutes);
app.use('/auth', authRoutes);
app.use('/api/auth', authRoutes); // alias

// for testing only; delete later
import devRoutes from './src/dev/devRoutes.js';
app.use('/dev', devRoutes);

// error-handling middleware muist be attached last
import AppError from './src/utils/errors/AppError.js';
import errorHandler from './src/middleware/errorHandler.js';
app.use((req, res, next) => next(AppError.notFound('Route not found'))); // 404 for unknown routes
app.use(errorHandler);

await sequelize.authenticate();
console.log("Database connected");

// dev only: sync models with database (create tables if they don't exist)
initModels();
await sequelize.sync({ alter: true }); // alter: true modifies tables to match if the model has changed
console.log("Database models synced");

// listen on connection events for the incoming socket
io.on('connection', (socket) => {
    console.log('Socket connected: ', socket.id);

    socket.on('disconnect', () => {
        console.log('Socket disconnected: ', socket.id);
    });
});

// start server once everything is attached
const port = config.SV_PORT;
server.listen(port, () => console.log(`Server running on port ${port}`)); // display a server status upon startup