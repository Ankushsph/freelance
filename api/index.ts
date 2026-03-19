import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import path from "path";
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import { connectDB } from "./db.js";
import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";
import otpRouters from "./routes/otp.routes.js"
import testOtpRoutes from "./routes/test-otp.routes.js";
import instagramRoutes from "./routes/instagram.routes.js";
import facebookRoutes from "./routes/facebook.routers.js";
import linkedinRoutes from "./routes/linkedin.routes.js";
import twitterRoutes from "./routes/twitter.routes.js";
import uploadRoutes from "./routes/upload.routes.js";
import callbackRoutes from "./routes/callback.routers.js";
import aiRouters from "./routes/ai.router.js";
import boostRoutes from "./routes/boost.router.js";
import postsRoutes from "./routes/posts.routes.js";
import analyticsRoutes from "./routes/analytics.routes.js";
import conversationRoutes from "./routes/conversation.routes.js";
import trendingRoutes from "./routes/trending.routes.js";
import adminRoutes from "./routes/admin.routes.js";
import trendsRoutes from "./routes/trends.routes.js";
import subscriptionRoutes from "./routes/subscription.routes.js";
import { initializeScheduler } from "./services/scheduler.js";
import { validateConfig, SERVER } from "./config.js";

dotenv.config();

validateConfig();

const app = express();

app.use(cors({
  origin: true,          // Reflect request origin — allows any origin
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());


app.use(express.static(path.join(__dirname, "public")));

app.use("/uploads", express.static(path.join(__dirname, "uploads"), {
  setHeaders: (res, filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    const mimeTypes: Record<string, string> = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.webp': 'image/webp'
    };
    
    if (mimeTypes[ext]) {
      res.setHeader('Content-Type', mimeTypes[ext]);
    }
    
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD');
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    
    res.setHeader('Cache-Control', 'public, max-age=86400');
  }
}));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/otp", otpRouters);
app.use("/api/test-otp", testOtpRoutes);
app.use("/api/instagram", instagramRoutes);
app.use("/api/facebook", facebookRoutes);
app.use("/api/linkedin", linkedinRoutes);
app.use("/api/twitter", twitterRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/callback", callbackRoutes);
app.use("/api/ai", aiRouters);
app.use("/api/boost", boostRoutes);
app.use("/api/posts", postsRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api/conversations", conversationRoutes);
app.use("/api/trending", trendingRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/trends", trendsRoutes);
app.use("/api/subscription", subscriptionRoutes);

const PORT = SERVER.PORT;

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on ${SERVER.PUBLIC_URL} (port ${PORT})`);
    initializeScheduler();
  });
});

