import express from 'express'; // Import express using ES Modules
import { signup } from '../controllers/authController.js'; // Import the signup controller

const router = express.Router(); // Create a new router instance

// Define a POST route for registration
router.post('/signup', signup); // Connect /signup to the signup controller

export default router; // Export the router