import { Router } from "express";
import { devLogin, sendTestEmail } from "./devController.js";

const router = Router();

router.post("/login", devLogin);
router.post("/email", sendTestEmail);

export default router;