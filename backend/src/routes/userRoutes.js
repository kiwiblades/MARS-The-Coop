const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/auth');
const userController = require('../controllers/userController');

// protected endpoints: token needed
router.use(authenticateToken);
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.get('/medical', userController.getMedical);
router.put('/medical', userController.updateMedical);


module.exports = router;