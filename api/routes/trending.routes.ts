/**
 * Trending Routes
 * Provides endpoints for fetching trending posts globally
 */

import { Router } from "express";
import { verifyToken } from "../middleware/auth.js";
import { requirePremium } from "../middleware/premium.js";
import {
  getTrendingPosts,
  getUserTrendingPosts,
  getTrendingStats,
  updateEngagement,
  recalculateAllTrendingScores,
  createTrendingPost,
} from "../services/trending";
import { Post } from "../models/Post";

const router = Router();

/**
 * GET /api/trending
 * Get trending posts globally (sorted by trending score)
 * 
 * Query params:
 * - limit: number (default: 20)
 * - skip: number (default: 0)
 * - platform: "instagram" | "facebook" | "linkedin" | "twitter" | "all" (default: "all")
 * - timeframe: "24h" | "7d" | "30d" | "all" (default: "7d")
 */
router.get("/", verifyToken, requirePremium, async (req: any, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = parseInt(req.query.skip as string) || 0;
    const platform = (req.query.platform as string) || "all";
    const timeframe = (req.query.timeframe as string) || "7d";

    // Validate platform
    const validPlatforms = ["instagram", "facebook", "linkedin", "twitter", "all"];
    if (!validPlatforms.includes(platform)) {
      return res.status(400).json({
        success: false,
        message: `Invalid platform. Valid options: ${validPlatforms.join(", ")}`,
      });
    }

    // Validate timeframe
    const validTimeframes = ["24h", "7d", "30d", "all"];
    if (!validTimeframes.includes(timeframe)) {
      return res.status(400).json({
        success: false,
        message: `Invalid timeframe. Valid options: ${validTimeframes.join(", ")}`,
      });
    }

    const { posts, total } = await getTrendingPosts({
      limit,
      skip,
      platform: platform as any,
      timeframe: timeframe as any,
    });

    res.json({
      success: true,
      data: {
        posts,
        pagination: {
          total,
          limit,
          skip,
          hasMore: skip + posts.length < total,
        },
      },
    });
  } catch (error: any) {
    console.error("[Trending API] Error fetching trending posts:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch trending posts",
    });
  }
});

/**
 * GET /api/trending/me
 * Get trending posts for the authenticated user
 * 
 * Query params:
 * - limit: number (default: 20)
 * - skip: number (default: 0)
 */
router.get("/me", verifyToken, requirePremium, async (req: any, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = parseInt(req.query.skip as string) || 0;

    const { posts, total } = await getUserTrendingPosts(req.user.id, {
      limit,
      skip,
    });

    res.json({
      success: true,
      data: {
        posts,
        pagination: {
          total,
          limit,
          skip,
          hasMore: skip + posts.length < total,
        },
      },
    });
  } catch (error: any) {
    console.error("[Trending API] Error fetching user trending posts:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch user trending posts",
    });
  }
});

/**
 * GET /api/trending/stats
 * Get global trending statistics
 */
router.get("/stats", verifyToken, async (req: any, res) => {
  try {
    const stats = await getTrendingStats();

    res.json({
      success: true,
      data: stats,
    });
  } catch (error: any) {
    console.error("[Trending API] Error fetching trending stats:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch trending stats",
    });
  }
});

/**
 * POST /api/trending/:postId/engagement
 * Update engagement metrics for a post (admin/internal use)
 * 
 * Body:
 * - platform: "instagram" | "facebook" | "linkedin" | "twitter"
 * - likes?: number
 * - comments?: number
 * - shares?: number
 * - views?: number
 * - retweets?: number (for Twitter only)
 */
router.post("/:postId/engagement", verifyToken, async (req: any, res) => {
  try {
    const { postId } = req.params;
    const { platform, likes, comments, shares, views, retweets } = req.body;

    // Validate platform
    const validPlatforms = ["instagram", "facebook", "linkedin", "twitter"];
    if (!validPlatforms.includes(platform)) {
      return res.status(400).json({
        success: false,
        message: `Invalid platform. Valid options: ${validPlatforms.join(", ")}`,
      });
    }

    const engagementData: any = {
      likes: likes || 0,
      comments: comments || 0,
      views: views || 0,
    };

    if (platform === "twitter") {
      engagementData.retweets = retweets || 0;
    } else {
      engagementData.shares = shares || 0;
    }

    const updatedPost = await updateEngagement(postId, platform, engagementData);

    if (!updatedPost) {
      return res.status(404).json({
        success: false,
        message: "Post not found in trending",
      });
    }

    res.json({
      success: true,
      data: updatedPost,
    });
  } catch (error: any) {
    console.error("[Trending API] Error updating engagement:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to update engagement",
    });
  }
});

/**
 * POST /api/trending/recalculate
 * Recalculate all trending scores (admin use)
 */
router.post("/recalculate", verifyToken, async (req: any, res) => {
  try {
    // TODO: Add admin check here
    const updatedCount = await recalculateAllTrendingScores();

    res.json({
      success: true,
      data: {
        message: `Recalculated scores for ${updatedCount} posts`,
        updatedCount,
      },
    });
  } catch (error: any) {
    console.error("[Trending API] Error recalculating scores:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to recalculate scores",
    });
  }
});

/**
 * POST /api/trending/populate
 * Populate trending collection from existing published posts
 * This is useful when trending collection is empty but posts exist
 */
router.post("/populate", verifyToken, async (req: any, res) => {
  try {
    // Find all published posts that don't have trending entries
    const publishedPosts = await Post.find({
      status: { $in: ["published", "partially_failed"] },
      publishedAt: { $exists: true }
    });

    let created = 0;
    let skipped = 0;

    for (const post of publishedPosts) {
      try {
        await createTrendingPost(
          post._id.toString(),
          post.userId.toString(),
          post.content,
          post.mediaUrls,
          post.platforms as any
        );
        created++;
      } catch (error: any) {
        // If error is duplicate key, post already exists in trending
        if (error.code === 11000) {
          skipped++;
        } else {
          console.error(`[Trending Populate] Error creating entry for ${post._id}:`, error);
        }
      }
    }

    res.json({
      success: true,
      data: {
        message: `Populated trending collection`,
        created,
        skipped,
        total: publishedPosts.length,
      },
    });
  } catch (error: any) {
    console.error("[Trending API] Error populating trending:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to populate trending collection",
    });
  }
});

export default router;
