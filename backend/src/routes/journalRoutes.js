/* Entry point for journal routes */
import { Router } from 'express';
import * as journalController from '../controllers/journalController.js';
import { authenticateToken } from '../middleware/auth.js'; 

const router = Router();

// Routes
router.get('/eligible-subjects', authenticateToken, journalController.getEligibleSubjects);
router.get('/subjects', authenticateToken, journalController.getJournalSubjects);

router.get('/:subjectId', authenticateToken, journalController.getEntriesBySubject);
router.post('/', authenticateToken, journalController.createJournalEntry);


export default router;