import { config } from './src/config.js'; // load dotenv first so process.env is populated
import express from 'express'; // http framework
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import { sequelize } from './src/db/sequelize.js';
import { initModels } from './src/models/index.js';
import cors from 'cors';

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

// route for server healthcheck
app.get('/health', async (req, res) => {
    try {
        res.json({ ok: true, message: 'backend reachable' });
    } catch(e) {
        console.error(e);
        res.status(500).json({ ok: false, error: "db healthcheck failed" });
    }
})

// route for db healthcheck
app.get('/health/db', async (req, res) => {
    try {
        const row = await Healthcheck.create({});
        const count = await Healthcheck.count();
        res.json({ ok: true, insertedId: row.id, totalRows: count });
    } catch(e) {
        console.error(e);
        res.status(500).json({ ok: false, error: "db healthcheck failed" });
    }
});

// TODO: attach custom error handling middleware
// error-handling middleware muist be attached last.

await sequelize.authenticate();
console.log("Database connected");

// dev only: sync models with database (create tables if they don't exist)
await sequelize.sync({ alter: true });
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