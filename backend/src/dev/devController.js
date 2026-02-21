import RefreshToken from "../models/RefreshToken.js";
import AppError from "../utils/errors/AppError.js";
import { generateAccessToken, generateRefreshToken } from "../utils/jwt.js";
import { tokenFingerprint } from "../utils/tokenFingerprint.js";
import { sendEmail } from "../utils/mailer.js";

export async function devLogin(req, res) {
    const user = { id: "00000000-0000-0000-0000-000000000001", email: "dev@example.com" };

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    const row = await RefreshToken.create({
      userId: user.id,
      tokenHash: tokenFingerprint(refreshToken),
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      revokedAt: null,
    });

    if (!row) {
        throw AppError.badRequest("Unable to create refresh token (dev)");
    }

    return res.json({ accessToken, refreshToken });
}

export async function sendTestEmail(req, res) {
    const to = String(req.body?.to || "");
    if (!to) {
        throw AppError.badRequest("Missing 'to' email (dev)", { code: "MISSING_TO" });
    }

    const mail = await sendEmail({
        to,
        subject: "[DEV] Mailer test",
        html: `<h2>Mailer works</h2><p>If you see this, email config is working</p>`,
        text: "Mailer works",
    });
    if (!mail) {
        throw AppError.badRequest("Unable to send email (dev)");
    }

    return res.json({ ok: true });
}