/*
1. User visits signup page and clicks submit
-> frontend sents POST request to /api/auth/signup with username, email, password
-> backend receives request and calls authController.signup
-> authController.signup checks if username/email already exists in DB
*/

import { Router } from "express";
import { signup, signin, signout, refresh, verifyEmail, resendVerification, changePassword } from "../controllers/authController.js"
import { authenticateToken } from "../middleware/auth.js";

const router = Router();

// Define a POST route for registration
router.post('/signup', signup); // Connect /signup to the signup controller
router.post('/signin', signin);
router.post('/signout', signout);
router.post("/refresh", refresh);
router.get("/verify-email", verifyEmail);

// from here, endpoints require uid+verification
router.use(authenticateToken);
router.post("/resend-verification", resendVerification);
router.patch("/change-password", changePassword);

export default router;