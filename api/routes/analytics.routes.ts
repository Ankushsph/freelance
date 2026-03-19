/**
 * Analytics Routes
 * Provides endpoints for fetching analytics data from social platforms
 */

import { Router } from "express";
import { verifyToken } from "../middleware/auth.js";
import { requirePremium } from "../middleware/premium.js";
import { getPlatformAnalytics, getPostAnalytics } from "../services/analytics.js";

const router = Router();

/**
 * GET /api/analytics/:platform
 * Get analytics overview for a specific platform
 * Query params: days (7 or 30, default 30)
 */
router.get("/:platform", verifyToken, requirePremium, async (req: any, res) => {
  try {
    const { platform } = req.params;
    const days = parseInt(req.query.days as string) || 30;

    if (!['facebook', 'instagram'].includes(platform)) {
      return res.status(400).json({
        success: false,
        message: "Invalid platform. Supported: facebook, instagram"
      });
    }

    if (![7, 30].includes(days)) {
      return res.status(400).json({
        success: false,
        message: "Invalid days parameter. Supported: 7, 30"
      });
    }

    const analytics = await getPlatformAnalytics(req.user.id, platform as any, days);

    res.json({
      success: true,
      data: analytics
    });
  } catch (error: any) {
    console.error(`[Analytics] Error fetching ${req.params.platform} analytics:`, error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch analytics"
    });
  }
});

/**
 * GET /api/analytics/:platform/posts/:postId
 * Get analytics for a specific post
 */
router.get("/:platform/posts/:postId", verifyToken, requirePremium, async (req: any, res) => {
  try {
    const { platform, postId } = req.params;

    if (!['facebook', 'instagram'].includes(platform)) {
      return res.status(400).json({
        success: false,
        message: "Invalid platform. Supported: facebook, instagram"
      });
    }

    const analytics = await getPostAnalytics(req.user.id, platform as any, postId);

    res.json({
      success: true,
      data: analytics
    });
  } catch (error: any) {
    console.error(`[Analytics] Error fetching post analytics:`, error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch post analytics"
    });
  }
});

export default router;
