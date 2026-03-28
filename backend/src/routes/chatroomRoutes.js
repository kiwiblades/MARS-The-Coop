import { Router } from "express";
import { authenticateToken } from "../middleware/auth.js";
import { verifyOwner } from "../middleware/chatPermissions.js";
import { getChatrooms, createChatroom, joinChatroom, leaveChatroom, deleteChatroom, togglePin, updateSettings } from "../controllers/chatroomController.js";

const router = Router();

router.use(authenticateToken);
router.get("/", getChatrooms);
router.post("/create", createChatroom);
router.post("/join", joinChatroom);
router.delete("/leave", leaveChatroom);
router.delete("/delete", deleteChatroom);
router.patch("/pin", togglePin);
router.patch("/:id/settings", updateSettings); 
router.delete("/:id", verifyOwner, deleteChatroom); 
router.patch("/pin", togglePin);

export default router;