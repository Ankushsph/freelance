import type { Request, Response } from "express";
import { Conversation } from "../models/Conversation";
import { Message } from "../models/Message";
import { Types } from "mongoose";
import type { AuthRequest } from "../middleware/auth";

/**
 * Generate a title from the first user message
 */
function generateTitle(content: string): string {
  const maxLength = 30;
  if (content.length <= maxLength) {
    return content;
  }
  return content.substring(0, maxLength) + "...";
}

export const ConversationController = {
  /**
   * List all conversations for the authenticated user
   */
  async listConversations(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const skip = (page - 1) * limit;

      const conversations = await Conversation.find({
        userId: new Types.ObjectId(userId),
        isArchived: false,
      })
        .sort({ lastMessageAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

      const total = await Conversation.countDocuments({
        userId: new Types.ObjectId(userId),
        isArchived: false,
      });

      return res.json({
        success: true,
        data: conversations,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      });
    } catch (error: any) {
      console.error("List conversations error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to fetch conversations",
      });
    }
  },

  /**
   * Create a new conversation
   */
  async createConversation(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const { title } = req.body;

      const conversation = new Conversation({
        userId: new Types.ObjectId(userId),
        title: title || "New Chat",
        messageCount: 0,
        lastMessageAt: new Date(),
      });

      await conversation.save();

      return res.status(201).json({
        success: true,
        data: conversation,
      });
    } catch (error: any) {
      console.error("Create conversation error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to create conversation",
      });
    }
  },

  /**
   * Get a single conversation with messages
   */
  async getConversation(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const conversation = await Conversation.findOne({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found",
        });
      }

      // Get messages with pagination
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;
      const skip = (page - 1) * limit;

      const messages = await Message.find({
        conversationId: conversation._id,
      })
        .sort({ timestamp: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

      return res.json({
        success: true,
        data: {
          ...conversation.toObject(),
          messages: messages.reverse(), // Return in chronological order
        },
        pagination: {
          page,
          limit,
          total: conversation.messageCount,
        },
      });
    } catch (error: any) {
      console.error("Get conversation error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to fetch conversation",
      });
    }
  },

  /**
   * Update conversation (title, archive status)
   */
  async updateConversation(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;
      const { title, isArchived } = req.body;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const updateData: any = {};
      if (title !== undefined) updateData.title = title;
      if (isArchived !== undefined) updateData.isArchived = isArchived;

      const conversation = await Conversation.findOneAndUpdate(
        {
          _id: new Types.ObjectId(id),
          userId: new Types.ObjectId(userId),
        },
        updateData,
        { new: true }
      );

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found",
        });
      }

      return res.json({
        success: true,
        data: conversation,
      });
    } catch (error: any) {
      console.error("Update conversation error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to update conversation",
      });
    }
  },

  /**
   * Delete a conversation
   */
  async deleteConversation(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      const conversation = await Conversation.findOneAndDelete({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found",
        });
      }

      // Delete all associated messages
      await Message.deleteMany({
        conversationId: conversation._id,
      });

      return res.json({
        success: true,
        message: "Conversation deleted successfully",
      });
    } catch (error: any) {
      console.error("Delete conversation error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to delete conversation",
      });
    }
  },

  /**
   * Add a message to a conversation
   */
  async addMessage(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;
      const { role, content, metadata } = req.body;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Unauthorized",
        });
      }

      if (!role || !content) {
        return res.status(400).json({
          success: false,
          message: "Role and content are required",
        });
      }

      const conversation = await Conversation.findOne({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: "Conversation not found",
        });
      }

      // Create message
      const message = new Message({
        conversationId: conversation._id,
        role,
        content,
        metadata,
        timestamp: new Date(),
      });

      await message.save();

      // Update conversation stats
      conversation.messageCount += 1;
      conversation.lastMessageAt = new Date();

      // Auto-generate title from first user message
      if (conversation.messageCount === 1 && role === "user") {
        conversation.title = generateTitle(content);
      }

      await conversation.save();

      return res.status(201).json({
        success: true,
        data: message,
      });
    } catch (error: any) {
      console.error("Add message error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to add message",
      });
    }
  },

  /**
   * Get conversation context for AI (last N messages)
   */
  async getConversationContext(
    conversationId: string,
    userId: string,
    messageCount: number = 10
  ): Promise<{ role: string; content: string }[]> {
    try {
      const conversation = await Conversation.findOne({
        _id: new Types.ObjectId(conversationId),
        userId: new Types.ObjectId(userId),
      });

      if (!conversation) {
        throw new Error("Conversation not found");
      }

      const messages = await Message.find({
        conversationId: conversation._id,
      })
        .sort({ timestamp: -1 })
        .limit(messageCount)
        .lean();

      return messages
        .reverse()
        .map((msg) => ({
          role: msg.role,
          content: msg.content,
        }));
    } catch (error) {
      console.error("Get conversation context error:", error);
      return [];
    }
  },
};
