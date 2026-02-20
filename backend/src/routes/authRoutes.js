/*
1. User visits signup page and clicks submit
-> frontend sents POST request to /api/auth/signup with username, email, password
-> backend receives request and calls authController.signup
-> authController.signup checks if username/email already exists in DB
*/

import { Router } from "express";
import { signup, signin, signout, refresh, verifyEmail, resendVerification } from "../controllers/authController.js"

const router = Router();

// Define a POST route for registration
router.post('/signup', signup); // Connect /signup to the signup controller
router.post('/signin', signin);
router.post('/signout', signout);
router.post("/refresh", refresh);
router.get("/verify-email", verifyEmail);
router.post("/resend-verification", resendVerification);

export default router;