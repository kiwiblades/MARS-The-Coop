/* Entry point for journal routes */

const router = require('express').Router();
const journalController = require('../controllers/journalController');
const auth = require('../middleware/auth'); // Use your existing auth middleware

router.post('/', auth, journalController.createJournalEntry);
router.get('/eligible-subjects', auth, journalController.getEligibleSubjects);
router.get('/subjects', auth, journalController.getJournalSubjects); // For the "Bird Grid"
router.get('/:subjectId', auth, journalController.getEntriesBySubject);

module.exports = router;