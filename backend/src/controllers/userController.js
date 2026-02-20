/*

*/

import User from '../models/userModel.js';
import AppError from '../utils/errors/AppError.js';
import { Op } from 'sequelize';
import { generateEmailVerificationToken } from '../utils/jwt.js';
import { config } from '../config.js';
import EmailVerificationToken from '../models/EmailVerificationToken.js';
import { tokenFingerprint } from '../utils/tokenFingerprint.js';
import { sendVerifyEmail } from '../utils/mailer.js';

/* 
    Helper function for calculating expiry of tokens.
    "fallback" is in ms. If the provided duration cannot be parsed, fallback is used instead.
    The function only supports expires_in format of minute (15m), hour (24h), or day (30d)
*/
function expiresAtFrom(duration, fallback) {
    if (typeof duration !== "string") return new Date(Date.now() + fallback);

    // match() returns an array where m[0] is the full match, m[1] is the first group (\d+), etc.
    const m = duration.trim().match(/^(\d+)\s*([mhd])$/i); // regex literal is used to understand the string duration
    if (!m) return new Date(Date.now() + fallback); // if it cannot be parsed, use ms fallback

    // e.g., "15m"
    const n = Number(m[1]); // "15"
    const unit = m[2].toLowerCase(); // "m"

    // identify the number of ms corresponding to minute, hour, or day
    // 60_000 == 60000, js supports underscore for readability
    const mult = unit === "m" ? 60_000 : unit === "h" ? 3_600_000 : unit === "d" ? 86_400_000 :
        fallback;

    return new Date(Date.now() + n*mult); // add the expiry length to the current time
}

export async function getProfile(req, res) {
    const uid = req.user.uid; // no need to check this; auth middleware handles that

    const user = await User.findByPk(uid, {
        attributes: ["uid", "username", "email", "emailVerified", "emailVerifiedAt", "pigeonId"],
    });
    if (!user) throw AppError.notFound("User not found", { code: "USER_NOT_FOUND" });

    return res.status(200).json({ user });
}

export async function updateProfile(req, res) {
    const uid = req.user.uid;

    let { username, email, pigeonId } = req.body || {};

    if (username !== undefined) username = String(username).trim();
    if (email !== undefined) email = String(email).trim().toLowerCase();
    if (pigeonId !== undefined) pigeonId = Number(pigeonId);

    if (username === undefined && email === undefined && pigeonId === undefined) {
        throw AppError.badRequest("No fields to update", { code: "NO_UPDATES" });
    }

    if (username !== undefined && username.length === 0) {
        throw AppError.badRequest("Username cannot be empty", { code: "USERNAME_INVALID" });
    }
    if (email !== undefined && email.length === 0) {
        throw AppError.badRequest("Email cannot be empty", { code: "EMAIL_INVALID" });
    }

    const user = await User.findByPk(uid);
    if (!user) throw AppError.notFound("User not found", { code: "USER_NOT_FOUND" });

    // if neither fields actually changed, return current profile
    const usernameChanged = username !== undefined && username !== user.username;
    const emailChanged = email !== undefined && email !== user.email;
    const pigeonIdChanged = pigeonId !== undefined && pigeonId !== user.pigeonId;

    if (!usernameChanged && !emailChanged && !pigeonIdChanged) {
        return res.status(200).json({
            user: {
                uid: user.uid,
                username: user.username,
                email: user.email,
                emailVerified: user.emailVerified,
                emailVerifiedAt: user.emailVerifiedAt,
                pigeonId: user.pigeonId,
            },
            message: "No changes detected",
        });
    }

    // check duplicate only for fields that are changing
    if (usernameChanged || emailChanged || pigeonIdChanged) {
        const where = [];
        if (usernameChanged) where.push({ username });
        if (emailChanged) where.push({ email });
        if (pigeonIdChanged) where.push({ pigeonId });

        const existing = await User.findOne({
            where: {
                [Op.and]: [
                    { uid: { [Op.ne]: uid} },
                    { [Op.or]: where },
                ],
            },
        });

        if (existing) {
            throw AppError.badRequest("Username or email already recorded", { code: "DUPLICATE" });
        }
    }

    // apply the updates
    if (usernameChanged) user.username = username;
    if (pigeonIdChanged) user.pigeonId = pigeonId;

    let verificationUrl;
    if (emailChanged) {
        user.email = email;
        // reset verification when email changes
        user.emailVerified = false;
        user.emailVerifiedAt = null;
    }

    await user.save();

    // if email changed, issue a new verification link
    if (emailChanged) {
        const verifyToken = generateEmailVerificationToken({ uid: user.uid, email: user.email });
        const verifyExpiresAt = expiresAtFrom(config.jwt.verify_email_expires_in, 60*60*1000);

        await EmailVerificationToken.create({
            userId: user.uid,
            tokenHash: tokenFingerprint(verifyToken),
            expiresAt: verifyExpiresAt,
        });

        const baseUrl = `http://localhost:${config.SV_PORT}`;
        verificationUrl = `${baseUrl}/auth/verify-email?token=${encodeURIComponent(verifyToken)}`;

        // send the verification email
        try {
            await sendVerifyEmail(user.email, verificationUrl);
        } catch(e) {
            console.error("[UpdateProfile] failed to send verification email:", e);
            // just continue after an error in dev
        }
    }

    return res.status(200).json({
        user: {
            uid: user.uid,
            username: user.username,
            email: user.email,
            emailVerified: user.emailVerified,
            emailVerifiedAt: user.emailVerifiedAt,
            pigeonId: user.pigeonId,
        },
        ...(verificationUrl ? { verificationUrl } : {}), // for testing
    });
}