/*
    Mailer utility for sending out emails of any kind.
    Usage requires email information to be added to .env
*/

import { config } from '../config.js'
import nodemailer from "nodemailer";
import { buildVerifyEmail } from './emails/verifyEmail.js';
import { buildResetPasswordEmail } from './emails/resetPassword.js';

// transporter is a connection to a smtp server
const transporter = nodemailer.createTransport({
    host: config.email.host,
    port: config.email.port,
    secure: config.email.secure, // 465 -> true, 587 -> false
    auth: {
        user: config.email.user, // email address
        pass: config.email.pass, // app password
    },
    pool: true, maxConnections:3, maxMessages:100,
});

export async function sendEmail({ to, subject, html, text }) {
    console.log('[Mailer] sending', { to, subject });
    const info = await transporter.sendMail({
        from: config.email.email_from || config.email.user,
        to, subject, text, html,
        replyTo: config.email.email_from || config.email.user,
    });
    console.log('[Mailer] sent:', info.messageId);
    return info;
}

// --- public api ---

export async function sendVerifyEmail(to, verifyUrl) {
    const { subject, text, html } = buildVerifyEmail({ verifyUrl });
    return sendEmail({ to, subject, text, html });
}

export async function sendResetPasswordEmail(to, resetUrl) {
    const { subject, text, html } = buildResetPasswordEmail({ resetUrl });
    return sendEmail({ to, subject, text, html });
}