/* Entry point for journal routes */
import { Router } from 'express';
import * as journalController from '../controllers/journalController.js';
import { authenticateToken } from '../middleware/auth.js'; 

const router = Router();

router.use(authenticateToken);
router.get('/eligible-subjects', journalController.getEligibleSubjects);
router.get('/subjects', journalController.getJournalSubjects);

router.get('/:subjectId', journalController.getEntriesBySubject);
router.post('/', journalController.createJournalEntry);

router.delete('/:id', journalController.deleteEntry);
router.patch('/:id', journalController.updateEntry);

export default router;