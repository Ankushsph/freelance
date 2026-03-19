import { Router } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { verifyToken } from "../middleware/auth";
import { 
  createPost, 
  cancelScheduledPost, 
  retryPost, 
  getUserPosts, 
  getPostById 
} from "../services/post";

const router = Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = "uploads/";
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024
  },
  fileFilter: (req, file, cb) => {
    const allowedImageTypes = /jpeg|jpg|png|gif|webp|bmp|tiff|heic|heif/;
    const allowedVideoTypes = /mp4|mov|avi|mkv|flv|wmv|m4v|3gp|webm/;

    const ext = path.extname(file.originalname).toLowerCase();
    const isImage = allowedImageTypes.test(ext);
    const isVideo = allowedVideoTypes.test(ext);

    if (isImage || isVideo) {
      return cb(null, true);
    } else {
      cb(new Error("Only image and video files are allowed. Supported: jpg, png, gif, webp, mp4, mov, avi, etc."));
    }
  }
});

router.post("/", verifyToken, upload.single("media"), async (req: any, res) => {
  try {
    const file = req.file;
    const { content, tags, platforms, scheduledTime } = req.body;

    if (!content || typeof content !== "string") {
      if (file) fs.unlinkSync(file.path);
      return res.status(400).json({ 
        success: false,
        error: "Content is required and must be a string" 
      });
    }

    if (!file) {
      return res.status(400).json({ 
        success: false,
        error: "Media file is required" 
      });
    }

    if (!platforms) {
      fs.unlinkSync(file.path);
      return res.status(400).json({ 
        success: false,
        error: "Platforms are required" 
      });
    }

    let parsedPlatforms: string[];
    if (typeof platforms === "string") {
      parsedPlatforms = platforms.split(",").map((p: string) => p.trim().toLowerCase());
    } else if (Array.isArray(platforms)) {
      parsedPlatforms = platforms.map((p: string) => p.toLowerCase());
    } else {
      fs.unlinkSync(file.path);
      return res.status(400).json({ 
        success: false,
        error: "Invalid platforms format" 
      });
    }

    const validPlatforms = ["instagram", "facebook", "linkedin", "twitter"];
    const invalidPlatforms = parsedPlatforms.filter((p: string) => !validPlatforms.includes(p));
    if (invalidPlatforms.length > 0) {
      fs.unlinkSync(file.path);
      return res.status(400).json({ 
        success: false,
        error: `Invalid platforms: ${invalidPlatforms.join(", ")}. Valid options: ${validPlatforms.join(", ")}` 
      });
    }

    if (parsedPlatforms.length === 0) {
      fs.unlinkSync(file.path);
      return res.status(400).json({ 
        success: false,
        error: "At least one platform must be selected" 
      });
    }

    let parsedTags: string[] = [];
    if (tags) {
      if (typeof tags === "string") {
        parsedTags = tags.split(",").map((t: string) => t.trim()).filter(Boolean);
      } else if (Array.isArray(tags)) {
        parsedTags = tags;
      }
    }

    const publicUrl = process.env.PUBLIC_URL || `${req.protocol}://${req.get("host")}`;
    const mediaUrl = `${publicUrl}/uploads/${file.filename}`;

    let parsedScheduledTime: Date | null = null;
    if (scheduledTime && scheduledTime !== "now") {
      parsedScheduledTime = new Date(scheduledTime);
      if (isNaN(parsedScheduledTime.getTime())) {
        fs.unlinkSync(file.path);
        return res.status(400).json({ 
          success: false,
          error: "Invalid scheduledTime format. Use ISO 8601 format or 'now'." 
        });
      }

      if (parsedScheduledTime <= new Date()) {
        fs.unlinkSync(file.path);
        return res.status(400).json({ 
          success: false,
          error: "scheduledTime must be in the future" 
        });
      }
    }

    let finalContent = content;
    if (parsedTags.length > 0) {
      const hashtags = parsedTags.map((tag: string) => `#${tag.replace(/^#/, '')}`).join(" ");
      finalContent = `${content}\n\n${hashtags}`;
    }

    const post = await createPost(req.user.id, {
      content: finalContent,
      mediaUrls: [mediaUrl],
      platforms: parsedPlatforms as ("instagram" | "facebook" | "linkedin" | "twitter")[],
      scheduledTime: parsedScheduledTime
    });

    res.status(201).json({
      success: true,
      message: parsedScheduledTime
        ? "Post scheduled successfully"
        : "Post created and publishing...",
      post: {
        ...post.toObject(),
        tags: parsedTags
      }
    });

  } catch (error: any) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    console.error("[Posts] Create post error:", error);
    res.status(500).json({ 
      success: false,
      error: error.message || "Failed to create post" 
    });
  }
});

router.get("/", verifyToken, async (req: any, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = parseInt(req.query.skip as string) || 0;
    const platform = req.query.platform as string | undefined;

    const { posts, total } = await getUserPosts(req.user.id, { limit, skip, platform });

    res.json({
      success: true,
      posts,
      pagination: {
        total,
        limit,
        skip,
        hasMore: skip + posts.length < total
      }
    });

  } catch (error: any) {
    console.error("[Posts] Get posts error:", error);
    res.status(500).json({ 
      success: false,
      error: error.message || "Failed to get posts" 
    });
  }
});

router.get("/:id", verifyToken, async (req: any, res) => {
  try {
    const post = await getPostById(req.params.id, req.user.id);
    res.json({ success: true, post });

  } catch (error: any) {
    console.error("[Posts] Get post error:", error);

    if (error.message === "Post not found") {
      return res.status(404).json({ success: false, error: "Post not found" });
    }

    res.status(500).json({ 
      success: false,
      error: error.message || "Failed to get post" 
    });
  }
});

router.delete("/:id", verifyToken, async (req: any, res) => {
  try {
    const result = await cancelScheduledPost(req.params.id, req.user.id);
    res.json({ success: true, ...result });

  } catch (error: any) {
    console.error("[Posts] Cancel post error:", error);

    if (error.message === "Post not found") {
      return res.status(404).json({ success: false, error: "Post not found" });
    }

    if (error.message === "Post is not scheduled") {
      return res.status(400).json({ success: false, error: "Post is not scheduled" });
    }

    res.status(500).json({ 
      success: false,
      error: error.message || "Failed to cancel post" 
    });
  }
});

router.post("/:id/retry", verifyToken, async (req: any, res) => {
  try {
    const post = await retryPost(req.params.id, req.user.id);
    res.json({ 
      success: true, 
      message: "Retrying post...",
      post 
    });

  } catch (error: any) {
    console.error("[Posts] Retry post error:", error);

    if (error.message === "Post not found") {
      return res.status(404).json({ success: false, error: "Post not found" });
    }

    if (error.message.includes("cannot be retried")) {
      return res.status(400).json({ success: false, error: error.message });
    }

    res.status(500).json({ 
      success: false,
      error: error.message || "Failed to retry post" 
    });
  }
});

export default router;
