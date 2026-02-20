/*
    Auth middleware intercepts requests sent to a protected route to verify the user's auth status before
    allowing access. It examines the request token and extracts user details from it, rather than accepting
    user info directly that might have been tampered with.
*/

import AppError from "../utils/errors/AppError.js";
import { verifyAccessToken } from "../utils/jwt.js";

export function authenticateToken(req, res, next) {
    // expected header: Authorization: Bearer <accessToken>
    const authHeader = req.get('authorization') || '';
    const [scheme, token] = authHeader.split(' '); // extract the components from the header
    
    if (scheme !== 'Bearer' || !token) {
        throw AppError.unauthorized('Access token missing', { code: "TOKEN_MISSING" });
    }

    try {
        // check signature and expiry of token
        const payload = verifyAccessToken(token);

        // attach identity for the controller to use
        req.user = { uid: payload.uid, email: payload?.email };

        return next();
    } catch(e) {
        return next(e);
    }
}