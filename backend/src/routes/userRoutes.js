const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/auth');
const userController = require('../controllers/userController');

// protected endpoints: token needed
router.use(authenticateToken);
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);

module.exports = router;