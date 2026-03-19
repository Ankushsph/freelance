// routes/instagram.ts
import { Router } from "express";
import crypto from "crypto";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";
import { INSTAGRAM } from "../config";

const router = Router();

// Check if Instagram is enabled
if (!INSTAGRAM.ENABLED) {
  console.log('⚠️  Instagram integration is disabled');
}

/* =======================================================
   1️⃣ START INSTAGRAM OAUTH (JWT REQUIRED)
   ======================================================= */
router.post("/connect", verifyToken, async (req: any, res) => {
  if (!INSTAGRAM.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Instagram integration is currently disabled" 
    });
  }

  const state = crypto.randomUUID();

  await User.findByIdAndUpdate(req.user.id, {
    instagramOAuthState: state,
  });

  const oauthUrl =
    `${INSTAGRAM.OAUTH_BASE_URL}` +
    `?force_reauth=true` +
    `&client_id=${INSTAGRAM.CLIENT_ID}` +
    `&redirect_uri=${encodeURIComponent(INSTAGRAM.REDIRECT_URI)}` +
    `&response_type=code` +
    `&scope=${INSTAGRAM.SCOPES}` +
    `&state=${state}`;

  res.json({ success: true, url: oauthUrl });
});

/* =======================================================
   2️⃣ INSTAGRAM CALLBACK (NO JWT ❌)
   ======================================================= */
router.get("/callback", async (req, res) => {
  if (!INSTAGRAM.ENABLED) {
    return res.status(503).send("Instagram integration is currently disabled");
  }

  const { code, state } = req.query as {
    code?: string;
    state?: string;
  };

  if (!code || !state) {
    return res.status(400).send("Missing code or state");
  }

  try {
    const user = await User.findOne({ instagramOAuthState: state });
    if (!user) {
      return res.status(401).send("Invalid OAuth state");
    }

    // Exchange code for access token
    const params = new URLSearchParams();
    params.append("client_id", INSTAGRAM.CLIENT_ID);
    params.append("client_secret", INSTAGRAM.CLIENT_SECRET);
    params.append("grant_type", "authorization_code");
    params.append("redirect_uri", INSTAGRAM.REDIRECT_URI);
    params.append("code", code);

    console.log(`[Instagram] Exchanging code for token, redirect_uri: ${INSTAGRAM.REDIRECT_URI}`);
    
    const tokenRes = await fetch(INSTAGRAM.TOKEN_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: params
    });

    const tokenData: any = await tokenRes.json();

    if (!tokenData.access_token) {
      console.error("[Instagram] Token error:", tokenData);
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head><title>Instagram Connection Failed</title></head>
        <body style="font-family: Arial; background:#f0f0f0; text-align:center; padding:50px;">
          <div style="background:white; padding:30px; border-radius:10px; max-width:400px; margin:0 auto;">
            <div style="color: #dc3545; font-size: 48px;">✗</div>
            <h1>Connection Failed</h1>
            <p style="color: #dc3545;">${tokenData.error_message || tokenData.error?.message || "Failed to get access token"}</p>
            <p style="font-size: 12px; color: #666;">Error: ${tokenData.error?.type || 'unknown'}</p>
          </div>
        </body>
        </html>
      `);
    }

    // Fetch IG profile
    console.log(`[Instagram] Fetching user profile with access token...`);
    const meRes = await fetch(
      `${INSTAGRAM.GRAPH_BASE_URL}/me?fields=id,username,account_type&access_token=${tokenData.access_token}`
    );
    const meData: any = await meRes.json();
    
    if (!meRes.ok || !meData.id) {
      console.error("[Instagram] Profile fetch error:", meData);
      return res.status(400).send(`
        <!DOCTYPE html>
        <html>
        <head><title>Instagram Connection Failed</title></head>
        <body style="font-family: Arial; background:#f0f0f0; text-align:center; padding:50px;">
          <div style="background:white; padding:30px; border-radius:10px; max-width:400px; margin:0 auto;">
            <div style="color: #dc3545; font-size: 48px;">✗</div>
            <h1>Profile Fetch Failed</h1>
            <p style="color: #dc3545;">${meData.error?.message || "Could not fetch Instagram profile"}</p>
          </div>
        </body>
        </html>
      `);
    }

    // Save
    user.instagramAccessToken = tokenData.access_token;
    user.instagramUserId = meData.id;
    user.instagramOAuthState = "connected";
    await user.save();

    console.log(`[Instagram] User ${user._id} connected successfully`);

    // Success HTML
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Instagram Connected</title>
        <style>
          body { font-family: Arial; background:#f0f0f0; text-align:center; padding:50px; }
          .box { background:white; padding:30px; border-radius:10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .success { color: #28a745; font-size: 48px; margin-bottom: 10px; }
        </style>
      </head>
      <body>
        <div class="box">
          <div class="success">✓</div>
          <h1>Instagram Connected!</h1>
          <p>You can safely return to the app.</p>
          <a href="/" style="display: inline-block; margin-top: 15px; padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Back to Dashboard</a>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error("[Instagram] OAuth error:", err);
    res.status(500).send("Instagram OAuth failed");
  }
});

/* =======================================================
   3️⃣ GET INSTAGRAM PROFILE (JWT REQUIRED)
   ======================================================= */
router.get("/me", verifyToken, async (req: any, res) => {
  if (!INSTAGRAM.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Instagram integration is currently disabled" 
    });
  }

  try {
    const user = await User.findById(req.user.id);
    if (!user || !user.instagramAccessToken) {
      return res.status(400).json({ 
        success: false,
        message: "Instagram not connected" 
      });
    }

    const igRes = await fetch(
      `${INSTAGRAM.GRAPH_BASE_URL}/me?fields=id,username,account_type,media_count,biography,follows_count,followers_count,profile_picture_url&access_token=${user.instagramAccessToken}`
    );
    const igData = await igRes.json();

    if (!igRes.ok) {
      console.error("[Instagram] Profile fetch error:", igData);
      return res.status(400).json({
        success: false,
        message: "Failed to fetch Instagram profile",
        error: igData
      });
    }

    res.json({ success: true, profile: igData });
  } catch (err) {
    console.error("[Instagram] Profile error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch Instagram profile" 
    });
  }
});

/* =======================================================
   4️⃣ UPLOAD IMAGE TO INSTAGRAM (JWT REQUIRED) - DEPRECATED
   Use /api/posts instead for unified posting
   ======================================================= */
router.post("/post", verifyToken, async (req: any, res) => {
  if (!INSTAGRAM.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Instagram integration is currently disabled" 
    });
  }

  const { image_url } = req.body;

  if (!image_url) {
    return res.status(400).json({ 
      success: false,
      message: "image_url is required" 
    });
  }

  try {
    // Get user and token
    const user = await User.findById(req.user.id);
    if (!user || !user.instagramAccessToken || !user.instagramUserId) {
      return res.status(400).json({ 
        success: false,
        message: "Instagram not connected" 
      });
    }

    const accessToken = user.instagramAccessToken;
    const userId = user.instagramUserId;

    // Step 1: Create Media Object
    const createRes = await fetch(
      `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${userId}/media?access_token=${accessToken}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          image_url,
          caption: "",
        }),
      }
    );

    const createData: any = await createRes.json();

    if (!createData.id) {
      console.error("[Instagram] Create media error:", createData);
      return res.status(400).json({
        success: false,
        message: "Failed to create media",
        error: createData
      });
    }

    const mediaId = createData.id;

    // Step 2: Publish Media
    const publishRes = await fetch(
      `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${userId}/media_publish?access_token=${accessToken}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ creation_id: mediaId }),
      }
    );

    const publishData: any = await publishRes.json();

    if (!publishData.id) {
      console.error("[Instagram] Publish error:", publishData);
      return res.status(400).json({
        success: false,
        message: "Failed to publish media",
        error: publishData
      });
    }

    res.json({
      success: true,
      message: "Image uploaded successfully",
      postId: publishData.id,
      note: "This endpoint is deprecated. Use POST /api/posts for unified posting"
    });
  } catch (err) {
    console.error("[Instagram] Post error:", err);
    res.status(500).json({ 
      success: false,
      message: "Instagram upload failed" 
    });
  }
});

export default router;
