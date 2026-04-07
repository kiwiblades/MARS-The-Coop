import AppError from "../utils/errors/AppError.js";
import User from "../models/userModel.js";

export async function updateFcmToken(req, res) {
    const { fcmToken } = req.body;
    if (!fcmToken) {
        throw AppError.badRequest("fcmToken is required for update");
    }

    
    await User.update(
        { fcmToken },
        { where: { uid: req.user.uid } }
    );

    return res.status(204).end(); // success w/ no return content
}