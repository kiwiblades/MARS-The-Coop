export function buildResetPasswordEmail({ resetUrl }) {
    return {
        subject: "Reset your password",
        text: `Reset your password using this link:\n\n${resetUrl}\n\nIf you didn't request this, you can safely ignore this email.`,
        html: `
            <p>Reset your password by clicking the link below:</p>
            <p><a href="${resetUrl}">Reset password</a></p>
            <p>If you didn't request this, you can safely ignore this email.</p>`,
    };
}