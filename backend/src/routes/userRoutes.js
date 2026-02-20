import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { getProfile, updateProfile } from "../controllers/userController.js";

const router = Router();

router.use(authenticateToken); // for protected endpoints, a valid access token is required
router.get("/", getProfile)
router.patch("/", updateProfile);

export default router;