import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { getNotificationSummary, updateFcmToken } from "../controllers/notificationController.js";

const router = Router();

router.use(authenticateToken);
router.post('/fcm-token', updateFcmToken);
router.get('/summary', getNotificationSummary);

export default router;