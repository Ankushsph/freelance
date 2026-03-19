import { Router } from "express";
import crypto from "crypto";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";
import { TWITTER } from "../config";
import { getTwitterProfile } from "../services/twitter";

const router = Router();

// Check if Twitter is enabled
if (!TWITTER.ENABLED) {
  console.log('⚠️  Twitter integration is disabled');
}

// Generate PKCE code verifier and challenge
function generatePKCE() {
  const codeVerifier = crypto.randomBytes(32).toString('base64url');
  const codeChallenge = crypto
    .createHash('sha256')
    .update(codeVerifier)
    .digest('base64url');
  return { codeVerifier, codeChallenge };
}

/* =======================================================
   1️⃣ START TWITTER OAUTH (JWT REQUIRED)
   ======================================================= */
router.post("/connect", verifyToken, async (req: any, res) => {
  if (!TWITTER.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "Twitter integration is currently disabled"
    });
  }

  const state = crypto.randomUUID();
  const { codeVerifier, codeChallenge } = generatePKCE();

  // Store code verifier in user record (needed for token exchange)
  await User.findByIdAndUpdate(req.user.id, {
    twitterOAuthState: state,
    // We need to store code verifier temporarily, but we'll use a workaround
    // since we don't have a field for it. We'll encode it in the state.
  });

  // Store code verifier in memory map (in production, use Redis)
  const stateKey = `twitter_pkce_${state}`;
  pkceStore.set(stateKey, codeVerifier);

  const oauthUrl =
    `${TWITTER.OAUTH_URL}` +
    `?response_type=code` +
    `&client_id=${TWITTER.CLIENT_ID}` +
    `&redirect_uri=${encodeURIComponent(TWITTER.REDIRECT_URI)}` +
    `&scope=${encodeURIComponent(TWITTER.SCOPES)}` +
    `&state=${state}` +
    `&code_challenge=${codeChallenge}` +
    `&code_challenge_method=S256`;

  res.json({ success: true, url: oauthUrl });
});

// In-memory PKCE store (use Redis in production)
const pkceStore = new Map<string, string>();

/* =======================================================
   2️⃣ TWITTER CALLBACK (NO JWT ❌)
   ======================================================= */
router.get("/callback", async (req, res) => {
  if (!TWITTER.ENABLED) {
    return res.status(503).send("Twitter integration is currently disabled");
  }

  const { code, state } = req.query as {
    code?: string;
    state?: string;
  };

  if (!code || !state) {
    return res.status(400).send("Missing code or state");
  }

  try {
    const user = await User.findOne({ twitterOAuthState: state });
    if (!user) {
      return res.status(401).send("Invalid OAuth state");
    }

    // Retrieve code verifier
    const stateKey = `twitter_pkce_${state}`;
    const codeVerifier = pkceStore.get(stateKey);
    
    if (!codeVerifier) {
      return res.status(400).send("Code verifier expired. Please try connecting again.");
    }
    
    // Clean up
    pkceStore.delete(stateKey);

    // Exchange code for access token
    // Twitter OAuth 2.0 requires Basic Authorization header with base64(client_id:client_secret)
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: TWITTER.REDIRECT_URI,
      code_verifier: codeVerifier,
      client_id: TWITTER.CLIENT_ID
      // Note: client_secret is NOT included in body when using Basic Auth
    });

    // Create Basic Auth header with base64 encoded client_id:client_secret
    const credentials = Buffer.from(`${TWITTER.CLIENT_ID}:${TWITTER.CLIENT_SECRET}`).toString('base64');

    console.log('[Twitter] Exchanging code for token...');
    console.log('[Twitter] Token URL:', TWITTER.TOKEN_URL);
    console.log('[Twitter] Client ID:', TWITTER.CLIENT_ID.substring(0, 10) + '...');
    console.log('[Twitter] Using Basic Auth header');
    
    const tokenResponse = await fetch(TWITTER.TOKEN_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: tokenBody
    });

    const tokenData: any = await tokenResponse.json();

    if (!tokenResponse.ok || !tokenData.access_token) {
      console.error("[Twitter] Token exchange failed:");
      console.error("  Status:", tokenResponse.status);
      console.error("  Response:", JSON.stringify(tokenData, null, 2));
      return res.status(400).send(`Twitter OAuth failed: ${tokenData.error_description || tokenData.error || 'Unknown error'}`);
    }

    // Get user profile to get the ID
    const profile = await getTwitterProfile(tokenData.access_token);
    
    if (!profile) {
      return res.status(400).send("Failed to fetch Twitter profile");
    }

    // Save tokens
    user.twitterAccessToken = tokenData.access_token;
    user.twitterRefreshToken = tokenData.refresh_token;
    user.twitterUserId = profile.id;
    user.twitterOAuthState = "connected";
    await user.save();

    console.log(`[Twitter] User ${user._id} connected successfully`);

    // Success HTML
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Twitter Connected</title>
        <style>
          body { font-family: Arial; background:#f0f0f0; text-align:center; padding:50px; }
          .box { background:white; padding:30px; border-radius:10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .success { color: #1da1f2; font-size: 48px; margin-bottom: 10px; }
        </style>
      </head>
      <body>
        <div class="box">
          <div class="success">𝕏</div>
          <h1>Twitter Connected!</h1>
          <p>You can safely return to the app.</p>
          <a href="/" style="display: inline-block; margin-top: 15px; padding: 10px 20px; background: #1da1f2; color: white; text-decoration: none; border-radius: 5px;">Back to Dashboard</a>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error("[Twitter] OAuth error:", err);
    res.status(500).send("Twitter OAuth failed");
  }
});

/* =======================================================
   3️⃣ GET TWITTER PROFILE (JWT REQUIRED)
   ======================================================= */
router.get("/me", verifyToken, async (req: any, res) => {
  if (!TWITTER.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "Twitter integration is currently disabled"
    });
  }

  try {
    const user = await User.findById(req.user.id);
    if (!user || !user.twitterAccessToken) {
      return res.status(400).json({
        success: false,
        message: "Twitter not connected"
      });
    }

    const profile = await getTwitterProfile(user.twitterAccessToken);

    if (!profile) {
      return res.status(400).json({
        success: false,
        message: "Failed to fetch Twitter profile"
      });
    }

    res.json({
      success: true,
      profile
    });
  } catch (err) {
    console.error("[Twitter] Profile error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch Twitter profile"
    });
  }
});

export default router;
