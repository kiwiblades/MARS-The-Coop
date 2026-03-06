import { Router } from 'express';
import * as messageController from '../controllers/messageController.js';
import { authenticateToken } from '../middleware/auth.js'; // Protect these routes

const router = Router();

// Apply protection middleware to all messaging routes
router.use(authenticateToken);

router.post('/', messageController.sendMessage); // Send
router.get('/:id/messages', messageController.getChatHistory); // Fetch

export default router;