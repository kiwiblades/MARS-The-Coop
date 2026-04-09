import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { verifyOwner } from "../middleware/chatPermissions.js";
import { getChatrooms, createChatroom, joinChatroom, leaveChatroom, deleteChatroom, togglePin, updateSettings, getChatroomById } from "../controllers/chatroomController.js";

const router = Router();

router.use(authenticateToken);
router.get("/", getChatrooms);
router.get("/:chatId", getChatroomById);
router.post("/create", createChatroom);
router.post("/join", joinChatroom);
router.delete("/leave", leaveChatroom);
router.patch("/pin", togglePin);
router.patch("/:id/settings", updateSettings); 
router.delete("/:id", verifyOwner, deleteChatroom); 

export default router;