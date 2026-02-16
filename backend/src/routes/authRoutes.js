const express = require('express');
const router = express.Router();
const { signup } = require('../controllers/authController');

// Define the POST route for signup
router.post('/signup', signup);

module.exports = router;