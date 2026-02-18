import { Router } from "express";
import { refresh, verifyEmail } from "../controllers/authController.js"

const router = Router();

router.post("/refresh", refresh);
router.get("/verify-email", verifyEmail);

export default router;