// routes/account.routes.ts
import { Router } from "express";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";

const router = Router();

/* =======================================================
   GET ALL CONNECTED ACCOUNTS
   ======================================================= */
router.get("/connected", verifyToken, async (req: any, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: "User not found" 
      });
    }

    const accounts = [];

    // Instagram
    if (user.instagramAccessToken && user.instagramUserId) {
      try {
        const igRes = await fetch(
          `https://graph.instagram.com/me?fields=id,username,account_type,media_count,biography,follows_count,followers_count,profile_picture_url&access_token=${user.instagramAccessToken}`
        );
        const igData = await igRes.json();
        
        if (igRes.ok && igData.id) {
          accounts.push({
            platform: 'instagram',
            platformId: igData.id,
            username: igData.username,
            name: igData.username,
            handle: `@${igData.username}`,
            bio: igData.biography || '',
            avatar: igData.profile_picture_url || '',
            followers: igData.followers_count || 0,
            following: igData.follows_count || 0,
            posts: igData.media_count || 0,
            isConnected: true,
            isActive: user.activePlatform === 'instagram',
          });
        }
      } catch (e) {
        console.error('[Account] Instagram fetch error:', e);
      }
    }

    // Facebook
    if (user.facebookAccessToken && user.facebookUserId) {
      try {
        const fbRes = await fetch(
          `https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${user.facebookAccessToken}`
        );
        const fbData = await fbRes.json();
        
        if (fbRes.ok && fbData.id) {
          accounts.push({
            platform: 'facebook',
            platformId: fbData.id,
            username: fbData.name,
            name: fbData.name,
            handle: fbData.name,
            bio: '',
            avatar: fbData.picture?.data?.url || '',
            followers: 0,
            following: 0,
            posts: 0,
            isConnected: true,
            isActive: user.activePlatform === 'facebook',
          });
        }
      } catch (e) {
        console.error('[Account] Facebook fetch error:', e);
      }
    }

    // Twitter
    if (user.twitterAccessToken && user.twitterUserId) {
      accounts.push({
        platform: 'twitter',
        platformId: user.twitterUserId,
        username: 'Twitter User',
        name: 'Twitter User',
        handle: '@twitter',
        bio: '',
        avatar: '',
        followers: 0,
        following: 0,
        posts: 0,
        isConnected: true,
        isActive: user.activePlatform === 'twitter',
      });
    }

    // LinkedIn
    if (user.linkedinAccessToken && user.linkedinUserId) {
      accounts.push({
        platform: 'linkedin',
        platformId: user.linkedinUserId,
        username: 'LinkedIn User',
        name: 'LinkedIn User',
        handle: 'LinkedIn',
        bio: '',
        avatar: '',
        followers: 0,
        following: 0,
        posts: 0,
        isConnected: true,
        isActive: user.activePlatform === 'linkedin',
      });
    }

    res.json({
      success: true,
      accounts,
      activePlatform: user.activePlatform || null,
    });
  } catch (err) {
    console.error("[Account] Get connected error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch connected accounts" 
    });
  }
});

/* =======================================================
   SET ACTIVE ACCOUNT
   ======================================================= */
router.post("/set-active", verifyToken, async (req: any, res) => {
  try {
    const { platform } = req.body;

    if (!platform) {
      return res.status(400).json({ 
        success: false,
        message: "Platform is required" 
      });
    }

    const validPlatforms = ['instagram', 'facebook', 'twitter', 'linkedin'];
    if (!validPlatforms.includes(platform)) {
      return res.status(400).json({ 
        success: false,
        message: "Invalid platform" 
      });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: "User not found" 
      });
    }

    // Verify the platform is connected
    const isConnected = 
      (platform === 'instagram' && user.instagramAccessToken) ||
      (platform === 'facebook' && user.facebookAccessToken) ||
      (platform === 'twitter' && user.twitterAccessToken) ||
      (platform === 'linkedin' && user.linkedinAccessToken);

    if (!isConnected) {
      return res.status(400).json({ 
        success: false,
        message: `${platform} is not connected` 
      });
    }

    user.activePlatform = platform;
    await user.save();

    res.json({
      success: true,
      message: `Active platform set to ${platform}`,
      activePlatform: platform,
    });
  } catch (err) {
    console.error("[Account] Set active error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to set active platform" 
    });
  }
});

/* =======================================================
   GET ACTIVE ACCOUNT
   ======================================================= */
router.get("/active", verifyToken, async (req: any, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: "User not found" 
      });
    }

    res.json({
      success: true,
      activePlatform: user.activePlatform || null,
    });
  } catch (err) {
    console.error("[Account] Get active error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch active platform" 
    });
  }
});

export default router;
