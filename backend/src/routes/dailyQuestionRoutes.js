import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import {
    getTodaysDailyQuestion,
    getDailyQuestionHistory,
    manualDispatch,
    resetToday
} from '../controllers/dailyQuestionController.js';

const router = Router();

router.use(authenticateToken);
router.get('/:roomId', getTodaysDailyQuestion);
router.get('/:roomId/history', getDailyQuestionHistory);
router.post('/dispatch', manualDispatch);
router.delete('/reset-today', resetToday)

export default router;