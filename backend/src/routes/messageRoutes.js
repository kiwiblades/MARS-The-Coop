import { Router } from 'express';
import * as messageController from '../controllers/messageController.js';
import { protect } from '../middleware/auth.js'; // Protect these routes

const router = Router();

// Apply protection middleware to all messaging routes
router.use(protect);

router.post('/', messageController.sendMessage); // Send
router.get('/:id/messages', messageController.getChatHistory); // Fetch

export default router;