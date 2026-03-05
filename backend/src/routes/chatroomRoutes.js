import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { getChatrooms, createChatroom, joinChatroom, leaveChatroom, deleteChatroom } from "../controllers/chatroomController.js";

const router = Router();

router.use(authenticateToken);
router.get("/", getChatrooms);
router.post("/create", createChatroom);
router.post("/join", joinChatroom);
router.delete("/leave", leaveChatroom);
router.delete("/delete", deleteChatroom);

export default router;