/*
    Utility functions for signing and verifying jwt tokens
*/

import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import AppError from './errors/AppError.js';

/*
    The access token is short lived, and the refresh token is used to get a new
    access token.
*/
export function generateAccessToken(user) {
    return jwt.sign(
        { id: user.id, email: user.email },
        config.jwt.access_secret,
        { expiresIn: config.jwt.access_expires_in || "15m" }
    );
}

/*
    The refresh token is stateful and must be persisted. It lasts many days to persist
    a user's session (preventing frequent re-login). Logging out should also revoke the token.
*/
export function generateRefreshToken(user) {
    return jwt.sign(
        { id: user.id, email: user.email },
        config.jwt.refresh_secret,
        { expiresIn: config.jwt.refresh_expires_in || "30d" }
    );
}

/* */
export function generateEmailVerificationToken(user) {
    return jwt.sign(
        { id: user.id, email: user.email, purpose: "verify_email" },
        config.jwt.verify_email_secret,
        { expiresIn: config.jwt.verify_email_expires_in || "1h" }
    );
}

export function verifyAccessToken(token) {
    try {
        return jwt.verify(token, config.jwt.access_secret);
    } catch(e) {
        // normalize jwt errors to AppError
        if (e?.name === "TokenExpiredError") {
            throw AppError.unauthorized("Access token expired", { code: "TOKEN_EXPIRED" });
        }
        throw AppError.unauthorized("Invalid access token", { code: "TOKEN_INVALID" });
    }
}

export function verifyRefreshToken(token) {
    try {
        return jwt.verify(token, config.jwt.refresh_secret);
    } catch(e) {
        if (e?.name === "TokenExpiredError") {
            throw AppError.unauthorized("Refresh token expired", { code: "REFRESH_EXPIRED" });
        }
        throw AppError.unauthorized("Invalid refresh token", { code: "REFRESH_INVALID" });
    }
}

export function verifyEmailVerificationToken(token) {
    try {
        const payload = jwt.verify(token, config.jwt.verify_email_secret);
        if (payload?.purpose !== "verify_email") {
            throw AppError.unauthorized("Invalid verification token", { code: "VERIFY_INVALID" });
        }
        return payload;
    } catch(e) {
        if (e?.name === "TokenExpiredError") {
            throw AppError.unauthorized("Verification link expired", { code: "VERIFY_EXPIRED" });
        }
        throw AppError.unauthorized("Invalid verification token", { code: "VERIFY_INVALID" });
    }
}