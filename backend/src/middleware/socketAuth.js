import AppError from '../utils/errors/AppError.js';
import { verifyAccessToken } from '../utils/jwt.js';

// socket auth middleware runs once per connection before any handlers
export const socketAuth = (socket, next) => {
    try {
        console.log('[socketAuth] running, headers:', socket.handshake.headers['authorization']);

        const token = socket.handshake.headers['authorization']?.split(' ')[1];
        if (!token) {
            throw AppError.unauthorized('Access token missing', { code: "TOKEN_MISSING" });
        }

        // check signature and expiry of token
        const payload = verifyAccessToken(token);

        // attach identity for handlers to use
        socket.user = { uid: payload.uid };

        return next();
    } catch(e) {
        console.error('[socketAuth] auth failed', e.message);
        return next(e);
    }
};