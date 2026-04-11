import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import {
    getTodaysDailyQuestion,
    getDailyQuestionHistory,
    manualDispatch,
    resetToday,
    getDailyQuestionAnswers
} from '../controllers/dailyQuestionController.js';

const router = Router();

router.use(authenticateToken);
router.get('/:chatId/history', getDailyQuestionHistory);
router.get('/:chatId/answers', getDailyQuestionAnswers);
router.get('/:chatId', getTodaysDailyQuestion);
router.post('/dispatch', manualDispatch);
router.delete('/reset-today', resetToday)

export default router;