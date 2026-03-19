// routes/facebook.ts
import { Router } from "express";
import crypto from "crypto";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";
import multer from "multer";
import { getUserPages } from "../services/facebook";
import { FACEBOOK } from "../config";

const router = Router();
const upload = multer({ dest: "uploads/" });

// Check if Facebook is enabled
if (!FACEBOOK.ENABLED) {
  console.log('⚠️  Facebook integration is disabled');
}

/* =======================================================
   1️⃣ START FACEBOOK OAUTH (JWT REQUIRED)
   ======================================================= */
router.post("/connect", verifyToken, async (req: any, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Facebook integration is currently disabled" 
    });
  }

  try {
    const state = crypto.randomUUID();

    await User.findByIdAndUpdate(req.user.id, {
      facebookOAuthState: state,
    });

    const oauthUrl =
      `${FACEBOOK.OAUTH_URL}` +
      `?client_id=${FACEBOOK.CLIENT_ID}` +
      `&redirect_uri=${encodeURIComponent(FACEBOOK.REDIRECT_URI)}` +
      `&scope=${FACEBOOK.SCOPES}` +
      `&response_type=code` +
      `&state=${state}`;

    res.json({ success: true, url: oauthUrl });
  } catch (err) {
    console.error("[Facebook] Connect error:", err);
    res.status(500).json({ 
      success: false,
      message: "Facebook connect failed" 
    });
  }
});

/* =======================================================
   2️⃣ FACEBOOK CALLBACK (NO JWT ❌)
   ======================================================= */
router.get("/callback/facebook", async (req, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).send("Facebook integration is currently disabled");
  }

  const { code, state } = req.query as {
    code?: string;
    state?: string;
  };

  if (!code || !state) {
    return res.status(400).send("Missing code or state");
  }

  try {
    // Find user by state
    const user = await User.findOne({ facebookOAuthState: state });

    if (!user) {
      return res.status(401).send("Invalid OAuth state");
    }

    // Exchange code for access token
    const tokenUrl =
      `${FACEBOOK.TOKEN_URL}` +
      `?client_id=${FACEBOOK.CLIENT_ID}` +
      `&redirect_uri=${encodeURIComponent(FACEBOOK.REDIRECT_URI)}` +
      `&client_secret=${FACEBOOK.CLIENT_SECRET}` +
      `&code=${code}`;

    const tokenRes = await fetch(tokenUrl);
    const tokenData: any = await tokenRes.json();

    if (!tokenData.access_token) {
      console.error("[Facebook] Token error:", tokenData);
      return res.status(400).json(tokenData);
    }

    const accessToken = tokenData.access_token;

    // Fetch profile
    const meRes = await fetch(
      `${FACEBOOK.GRAPH_API_URL}/me?fields=id,name,email&access_token=${accessToken}`
    );

    const meData: any = await meRes.json();

    if (!meData.id) {
      console.error("[Facebook] Profile error:", meData);
      return res.status(400).json(meData);
    }

    // Save in DB
    user.facebookAccessToken = accessToken;
    user.facebookUserId = meData.id;
    user.facebookOAuthState = "connected";

    await user.save();

    console.log(`[Facebook] User ${user._id} connected successfully`);

    // Success HTML
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Facebook Connected</title>
        <style>
          body { font-family: Arial; background:#f0f0f0; text-align:center; padding:50px; }
          .box { background:white; padding:30px; border-radius:10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .success { color: #28a745; font-size: 48px; margin-bottom: 10px; }
        </style>
      </head>
      <body>
        <div class="box">
          <div class="success">✓</div>
          <h1>Facebook Connected!</h1>
          <p>You can safely return to the app.</p>
          <a href="/" style="display: inline-block; margin-top: 15px; padding: 10px 20px; background: #1877f2; color: white; text-decoration: none; border-radius: 5px;">Back to Dashboard</a>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error("[Facebook] Callback error:", err);
    res.status(500).send("Facebook OAuth failed");
  }
});

/* =======================================================
   3️⃣ GET FACEBOOK PROFILE (JWT REQUIRED)
   ======================================================= */
router.get("/me", verifyToken, async (req: any, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Facebook integration is currently disabled" 
    });
  }

  try {
    const user = await User.findById(req.user.id);

    if (!user || !user.facebookAccessToken) {
      return res.status(400).json({ 
        success: false,
        message: "Facebook not connected" 
      });
    }

    const fbRes = await fetch(
      `${FACEBOOK.GRAPH_API_URL}/me?fields=id,name,email,picture&access_token=${user.facebookAccessToken}`
    );

    const fbData = await fbRes.json();

    if (!fbRes.ok) {
      console.error("[Facebook] Profile error:", fbData);
      return res.status(400).json({
        success: false,
        message: "Failed to fetch Facebook profile",
        error: fbData
      });
    }

    res.json({ success: true, profile: fbData });
  } catch (err) {
    console.error("[Facebook] Profile error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch Facebook profile" 
    });
  }
});

/* =======================================================
   4️⃣ GET FACEBOOK PAGES (JWT REQUIRED)
   ======================================================= */
router.get("/pages", verifyToken, async (req: any, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Facebook integration is currently disabled" 
    });
  }

  try {
    const user = await User.findById(req.user.id);

    if (!user || !user.facebookAccessToken) {
      return res.status(400).json({ 
        success: false,
        message: "Facebook not connected" 
      });
    }

    const pages = await getUserPages(user.facebookAccessToken);

    res.json({
      success: true,
      pages: pages.map(page => ({
        id: page.id,
        name: page.name,
        category: page.category
      })),
      selectedPageId: user.facebookPageId || null
    });

  } catch (err: any) {
    console.error("[Facebook] Get pages error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to get Facebook pages",
      error: err.message 
    });
  }
});

/* =======================================================
   5️⃣ SELECT FACEBOOK PAGE (JWT REQUIRED)
   ======================================================= */
router.post("/select-page", verifyToken, async (req: any, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Facebook integration is currently disabled" 
    });
  }

  try {
    const { pageId } = req.body;

    if (!pageId) {
      return res.status(400).json({ 
        success: false,
        message: "pageId is required" 
      });
    }

    const user = await User.findById(req.user.id);

    if (!user || !user.facebookAccessToken) {
      return res.status(400).json({ 
        success: false,
        message: "Facebook not connected" 
      });
    }

    // Verify the user has access to this page
    const pages = await getUserPages(user.facebookAccessToken);
    const pageExists = pages.find(p => p.id === pageId);

    if (!pageExists) {
      return res.status(400).json({ 
        success: false,
        message: "You don't have access to this page or it doesn't exist" 
      });
    }

    // Save the selected page
    user.facebookPageId = pageId;
    await user.save();

    res.json({
      success: true,
      message: "Page selected successfully",
      page: {
        id: pageExists.id,
        name: pageExists.name
      }
    });

  } catch (err: any) {
    console.error("[Facebook] Select page error:", err);
    res.status(500).json({ 
      success: false,
      message: "Failed to select page",
      error: err.message 
    });
  }
});

/* =======================================================
   6️⃣ POST TO FACEBOOK PAGE (JWT REQUIRED) - DEPRECATED
   Use /api/posts instead for unified posting
   ======================================================= */
router.post("/post", verifyToken, upload.single("image"), async (req: any, res) => {
  if (!FACEBOOK.ENABLED) {
    return res.status(503).json({ 
      success: false,
      message: "Facebook integration is currently disabled" 
    });
  }

  try {
    const { message } = req.body;
    const file = req.file;

    if (!message) {
      return res.status(400).json({ 
        success: false,
        message: "message is required" 
      });
    }

    const user = await User.findById(req.user.id);

    if (!user || !user.facebookAccessToken) {
      return res.status(400).json({ 
        success: false,
        message: "Facebook not connected" 
      });
    }

    if (!user.facebookPageId) {
      return res.status(400).json({ 
        success: false,
        message: "No Facebook page selected. Use POST /api/facebook/select-page first" 
      });
    }

    // For now, we only support message-only posts in this legacy endpoint
    const accessToken = user.facebookAccessToken;
    const postUrl = `${FACEBOOK.GRAPH_API_URL}/${user.facebookPageId}/feed?access_token=${accessToken}`;

    const postRes = await fetch(postUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });

    const postData: any = await postRes.json();

    if (!postData.id) {
      console.error("[Facebook] Post error:", postData);
      return res.status(400).json({
        success: false,
        message: "Failed to publish post",
        error: postData
      });
    }

    res.json({ 
      success: true,
      message: "Post published successfully", 
      postId: postData.id,
      note: "This endpoint is deprecated. Use POST /api/posts for unified posting"
    });
  } catch (err) {
    console.error("[Facebook] Post error:", err);
    res.status(500).json({ 
      success: false,
      message: "Facebook post failed" 
    });
  }
});

export default router;
