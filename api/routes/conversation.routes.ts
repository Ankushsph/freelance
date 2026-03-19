import { Router } from "express";
import { verifyToken } from "../middleware/auth";
import { ConversationController } from "../controllers/conversation.controller";

const router = Router();

// All routes require authentication
router.use(verifyToken);

// Conversation CRUD routes
router.get("/", ConversationController.listConversations);
router.post("/", ConversationController.createConversation);
router.get("/:id", ConversationController.getConversation);
router.put("/:id", ConversationController.updateConversation);
router.delete("/:id", ConversationController.deleteConversation);

// Message routes
router.post("/:id/messages", ConversationController.addMessage);

export default router;
