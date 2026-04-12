import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { verifyOwner } from "../middleware/chatPermissions.js";
import { getChatrooms, createChatroom, joinChatroom, leaveChatroom, deleteChatroom, togglePin, updateSettings, getChatroomById, banUser, unbanUser } from "../controllers/chatroomController.js";

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
router.post("/:id/ban", verifyOwner, banUser);
router.post("/:id/unban", verifyOwner, unbanUser);


export default router;