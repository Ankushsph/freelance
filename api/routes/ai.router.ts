import express, { type Request, type Response } from "express";
import axios from "axios";
import dotenv from "dotenv";
import { Types } from "mongoose";
import { ConversationController } from "../controllers/conversation.controller";
import { Conversation } from "../models/Conversation";
import { Message } from "../models/Message";
import { verifyToken, type AuthRequest } from "../middleware/auth.js";
import { requirePremium } from "../middleware/premium.js";

dotenv.config();

const router = express.Router();

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || "";
const OPENROUTER_MODEL = process.env.OPENROUTER_MODEL || "meta-llama/llama-3.2-1b-instruct:free";

if (!OPENROUTER_API_KEY || OPENROUTER_API_KEY === "your_openrouter_api_key_here") {
  console.warn("⚠️  OPENROUTER_API_KEY not configured — AI features will return 503 until key is set.");
}

const OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";

function isValidObjectId(id: string): boolean {
  return Types.ObjectId.isValid(id) && (String)(new Types.ObjectId(id)) === id;
}

function generateTitle(content: string): string {
  const cleanContent = content.trim().replace(/\s+/g, ' ');
  const maxLength = 25;
  if (cleanContent.length <= maxLength) return cleanContent;
  const truncated = cleanContent.substring(0, maxLength);
  const lastSpace = truncated.lastIndexOf(' ');
  return lastSpace > 15 ? truncated.substring(0, lastSpace) + '...' : truncated + '...';
}

function cleanResponse(text: string): string {
  const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 2);
  return sentences[0]?.trim().substring(0, 50) || text.trim().substring(0, 50);
}

function isGreeting(message: string): boolean {
  const greetings = ['hello', 'hi', 'hey', 'hiya', 'greetings', 'sup', 'what\'s up', 'yo'];
  const lower = message.toLowerCase().trim();
  return greetings.includes(lower) || greetings.some(g => lower.startsWith(g));
}

function getGreetingResponse(): string {
  return "Hi! How can I help you today?";
}

async function callAI(prompt: string, maxTokens: number = 30): Promise<string> {
  try {
    console.log(`🤖 Calling OpenRouter API with prompt: "${prompt.substring(0, 50)}..."`);
    
    const response = await axios.post(
      OPENROUTER_API_URL,
      {
        model: OPENROUTER_MODEL,
        messages: [
          { role: "system", content: "You are a helpful assistant. Give concise, direct answers." },
          { role: "user", content: prompt }
        ],
        max_tokens: maxTokens,
        temperature: 0.7,
      },
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
          "HTTP-Referer": "https://konnect.app",
          "X-Title": "Konnect"
        },
        timeout: 30000,
      }
    );
    
    console.log(`✅ OpenRouter API response received`);
    
    const content = response.data?.choices?.[0]?.message?.content?.trim() || "";
    
    if (!content) {
      console.warn("⚠️  Empty response from OpenRouter");
      return "I'm having trouble responding right now. Please try again.";
    }
    
    console.log(`📝 AI Response: "${content.substring(0, 100)}..."`);
    return content;
    
  } catch (e: any) {
    console.error("❌ OpenRouter API Error:");
    console.error("  Status:", e.response?.status);
    console.error("  Message:", e.message);
    console.error("  Data:", JSON.stringify(e.response?.data, null, 2));
    
    if (e.response?.status === 401) {
      return "API authentication failed. Please check API key.";
    }
    if (e.response?.status === 429) {
      return "Rate limit exceeded. Please try again in a moment.";
    }
    if (e.code === 'ECONNABORTED' || e.code === 'ETIMEDOUT') {
      return "Request timed out. Please try again.";
    }
    
    return "I'm having trouble responding. Please try again.";
  }
}

router.post("/chat", verifyToken, requirePremium, async (req: AuthRequest, res: Response) => {
  if (!OPENROUTER_API_KEY || OPENROUTER_API_KEY === "your_openrouter_api_key_here") {
    return res.status(503).json({ success: false, message: "AI service is not configured. Please set OPENROUTER_API_KEY in .env" });
  }
  try {
    const { prompt, conversationId } = req.body;
    const userId = req.user?.id;

    if (!prompt) {
      return res.status(400).json({ success: false, message: "Prompt is required" });
    }

    let aiReply: string;
    if (isGreeting(prompt)) {
      aiReply = getGreetingResponse();
    } else {
      aiReply = await callAI(prompt, 25);
    }

    let conversation = null;

    if (conversationId && isValidObjectId(conversationId)) {
      try {
        conversation = await Conversation.findOne({
          _id: new Types.ObjectId(conversationId),
          userId: new Types.ObjectId(userId),
        });
      } catch (err) { }
    }

    let responseConversationId = conversation?._id;
    
    if (!conversation) {
      try {
        const generatedTitle = generateTitle(prompt);
        conversation = new Conversation({
          userId: new Types.ObjectId(userId),
          title: generatedTitle,
          messageCount: 0,
          lastMessageAt: new Date(),
        });
        await conversation.save();
        
        await Message.create([
          { conversationId: conversation._id, role: "user", content: prompt, timestamp: new Date() },
          { conversationId: conversation._id, role: "assistant", content: aiReply, timestamp: new Date() }
        ]);
        
        conversation.messageCount = 2;
        conversation.lastMessageAt = new Date();
        await conversation.save();
        responseConversationId = conversation._id;
      } catch (saveError) { }
    } else {
      try {
        await Message.create([
          { conversationId: conversation._id, role: "user", content: prompt, timestamp: new Date() },
          { conversationId: conversation._id, role: "assistant", content: aiReply, timestamp: new Date() }
        ]);
        conversation.messageCount += 2;
        conversation.lastMessageAt = new Date();
        await conversation.save();
      } catch (saveError) { }
    }

    return res.json({ success: true, reply: aiReply, conversationId: responseConversationId, title: conversation?.title || null });

  } catch (error: any) {
    console.error("AI Error:", error?.response?.data || error.message);
    return res.status(500).json({ success: false, message: "AI service failed" });
  }
});

router.post("/generate-caption", verifyToken, requirePremium, async (req: Request, res: Response) => {
  if (!OPENROUTER_API_KEY || OPENROUTER_API_KEY === "your_openrouter_api_key_here") {
    return res.status(503).json({ success: false, message: "AI service is not configured. Please set OPENROUTER_API_KEY in .env" });
  }
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ success: false, message: "Message is required" });
    }

    const prompt = `${message}`;
    const caption = await callAI(prompt, 30);

    return res.json({ success: true, caption });

  } catch (error: any) {
    console.error("AI Caption Error:", error?.response?.data || error.message);
    return res.status(500).json({ success: false, message: "Failed to generate caption" });
  }
});

router.post("/generate-hashtags", verifyToken, requirePremium, async (req: Request, res: Response) => {
  if (!OPENROUTER_API_KEY || OPENROUTER_API_KEY === "your_openrouter_api_key_here") {
    return res.status(503).json({ success: false, message: "AI service is not configured. Please set OPENROUTER_API_KEY in .env" });
  }
  try {
    const { caption } = req.body;

    if (!caption) {
      return res.status(400).json({ success: false, message: "Caption is required" });
    }

    const prompt = `Tags for: ${caption}`;
    const hashtagResponse = await callAI(prompt, 25);
    const hashtags = hashtagResponse.match(/#[a-zA-Z0-9_]+/g) || [];

    return res.json({ success: true, hashtags: hashtags.slice(0, 8) });

  } catch (error: any) {
    console.error("AI Hashtags Error:", error?.response?.data || error.message);
    return res.status(500).json({ success: false, message: "Failed to generate hashtags" });
  }
});

export default router;
