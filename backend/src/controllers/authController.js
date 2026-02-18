import EmailVerificationToken from "../models/EmailVerificationToken.js";
import RefreshToken from "../models/RefreshToken.js";
import AppError from "../utils/errors/AppError.js";
import { generateAccessToken, verifyEmailVerificationToken, verifyRefreshToken } from "../utils/jwt.js";
import { tokenFingerprint } from "../utils/tokenFingerprint.js";

export async function refresh(req, res) {
    const refreshToken = String(req.body?.refreshToken || "");
    if (!refreshToken) throw AppError.unauthorized("Refresh token missing", { code: "REFRESH_MISSING" });

    const payload = verifyRefreshToken(refreshToken); // verify jwt signature

    // compare the hashed token to the one stored in the database
    const row = await RefreshToken.findOne({
        where: {
            userId: payload.id,
            tokenHash: tokenFingerprint(refreshToken),
            revokedAt: null,
        },
    });

    if (!row) {
        throw AppError.unauthorized("Refresh token not found", { code: "REFRESH_NOT_FOUND" });
    }

    // check db expiry
    if (row.expiresAt && row.expiresAt < new Date()) {
        throw AppError.unauthorized("Refresh token expired", { code: "REFRESH_EXPIRED" });
    }

    // issue a new access token
    const accessToken = generateAccessToken({ id: payload.id, email: payload.email });

    return res.status(200).json({ accessToken });
}

// called when user clicks verification link from email
export async function verifyEmail(req, res) {
    const token = String(req.query.token || "");
    if (!token) throw AppError.badRequest("Missing token", { code: "MISSING_TOKEN" });

    const payload = verifyEmailVerificationToken(token); // check the attached token, verify signature, expiry, etc
    const row = await EmailVerificationToken.findOne({
        where: {
            userId: payload.id,
            tokenHash: tokenFingerprint(token), // tokenFingerprint computes the hash to check against the stored one; only store hash, not raw token
            usedAt: null,
        },
    });

    if (!row) {
        throw AppError.unauthorized("Verification link is not valid", { code: "VERIFY_NOT_FOUND" });
    }

    if (row.expiresAt && row.expiresAt < new Date()) {
        throw AppError.unauthorized("Verification link expired", { code: "VERIFY_EXPIRED" });
    }

    // mark user account as verified
    // await User.update(
    //     { emailVerified: true, emailVerifiedAt: new Date() },
    //     { where: { id: payload.id }}
    // );

    await row.update({ usedAt: new Date() });

    return res.status(200).send(`<h2>Email verified</h2><p>You can safely close this tab and return to the app.</p>`);
}