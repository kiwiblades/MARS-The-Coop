import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { getChatrooms, createChatroom, joinChatroom } from "../controllers/chatroomController.js";

const router = Router();

router.use(authenticateToken);
router.get("/", getChatrooms);
router.post("/create", createChatroom);
router.post("/join", joinChatroom);

export default router;