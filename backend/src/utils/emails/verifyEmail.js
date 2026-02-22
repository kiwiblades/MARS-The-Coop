export function buildVerifyEmail({ verifyUrl }) {
    return {
        subject: "Verify your email",
        text: `Verify your email by clicking this link:\n\n${verifyUrl}\n\nIf you didn't request this, you can safely ignore this email.`,
        html:`
            <p>Verify your email by clicking the link below:</p>
            <p><a href="${verifyUrl}">${verifyUrl}</a></p>
            <p>If you didn't request this, you can safely ignore this email.</p>`,
    };
}