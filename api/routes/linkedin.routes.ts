import { Router } from "express";
import crypto from "crypto";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";
import { LINKEDIN } from "../config";
import { getLinkedInProfile, getUserCompanies } from "../services/linkedin";

const router = Router();

// Check if LinkedIn is enabled
if (!LINKEDIN.ENABLED) {
  console.log('⚠️  LinkedIn integration is disabled');
}

/* =======================================================
   1️⃣ START LINKEDIN OAUTH (JWT REQUIRED)
   ======================================================= */
router.post("/connect", verifyToken, async (req: any, res) => {
  if (!LINKEDIN.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "LinkedIn integration is currently disabled"
    });
  }

  const state = crypto.randomUUID();

  await User.findByIdAndUpdate(req.user.id, {
    linkedinOAuthState: state,
  });

  const oauthUrl =
    `${LINKEDIN.OAUTH_URL}` +
    `?response_type=code` +
    `&client_id=${LINKEDIN.CLIENT_ID}` +
    `&redirect_uri=${encodeURIComponent(LINKEDIN.REDIRECT_URI)}` +
    `&scope=${encodeURIComponent(LINKEDIN.SCOPES)}` +
    `&state=${state}`;

  res.json({ success: true, url: oauthUrl });
});

/* =======================================================
   2️⃣ LINKEDIN CALLBACK (NO JWT ❌)
   ======================================================= */
router.get("/callback", async (req, res) => {
  if (!LINKEDIN.ENABLED) {
    return res.status(503).send("LinkedIn integration is currently disabled");
  }

  const { code, state } = req.query as {
    code?: string;
    state?: string;
  };

  if (!code || !state) {
    return res.status(400).send("Missing code or state");
  }

  try {
    const user = await User.findOne({ linkedinOAuthState: state });
    if (!user) {
      return res.status(401).send("Invalid OAuth state");
    }

    // Exchange code for access token
    const tokenResponse = await fetch(LINKEDIN.TOKEN_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        client_id: LINKEDIN.CLIENT_ID,
        client_secret: LINKEDIN.CLIENT_SECRET,
        redirect_uri: LINKEDIN.REDIRECT_URI
      })
    });

    const tokenData: any = await tokenResponse.json();

    if (!tokenData.access_token) {
      console.error("[LinkedIn] Token error:", tokenData);
      return res.status(400).json(tokenData);
    }

    // Get user profile to get the ID
    const profile = await getLinkedInProfile(tokenData.access_token);
    
    if (!profile) {
      return res.status(400).send("Failed to fetch LinkedIn profile");
    }

    // Save tokens
    user.linkedinAccessToken = tokenData.access_token;
    user.linkedinRefreshToken = tokenData.refresh_token;
    user.linkedinUserId = profile.id;
    user.linkedinOAuthState = "connected";
    await user.save();

    console.log(`[LinkedIn] User ${user._id} connected successfully`);

    // Success HTML
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>LinkedIn Connected</title>
        <style>
          body { font-family: Arial; background:#f0f0f0; text-align:center; padding:50px; }
          .box { background:white; padding:30px; border-radius:10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .success { color: #28a745; font-size: 48px; margin-bottom: 10px; }
          .linkedin { color: #0077b5; }
        </style>
      </head>
      <body>
        <div class="box">
          <div class="success linkedin">in</div>
          <h1>LinkedIn Connected!</h1>
          <p>You can safely return to the app.</p>
          <a href="/" style="display: inline-block; margin-top: 15px; padding: 10px 20px; background: #0077b5; color: white; text-decoration: none; border-radius: 5px;">Back to Dashboard</a>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error("[LinkedIn] OAuth error:", err);
    res.status(500).send("LinkedIn OAuth failed");
  }
});

/* =======================================================
   3️⃣ GET LINKEDIN PROFILE (JWT REQUIRED)
   ======================================================= */
router.get("/me", verifyToken, async (req: any, res) => {
  if (!LINKEDIN.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "LinkedIn integration is currently disabled"
    });
  }

  try {
    const user = await User.findById(req.user.id);
    if (!user || !user.linkedinAccessToken) {
      return res.status(400).json({
        success: false,
        message: "LinkedIn not connected"
      });
    }

    const profile = await getLinkedInProfile(user.linkedinAccessToken);

    if (!profile) {
      return res.status(400).json({
        success: false,
        message: "Failed to fetch LinkedIn profile"
      });
    }

    res.json({
      success: true,
      profile: {
        ...profile,
        selectedCompanyId: user.linkedinCompanyId || null
      }
    });
  } catch (err) {
    console.error("[LinkedIn] Profile error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch LinkedIn profile"
    });
  }
});

/* =======================================================
   4️⃣ GET LINKEDIN COMPANIES (JWT REQUIRED)
   ======================================================= */
router.get("/companies", verifyToken, async (req: any, res) => {
  if (!LINKEDIN.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "LinkedIn integration is currently disabled"
    });
  }

  try {
    const user = await User.findById(req.user.id);

    if (!user || !user.linkedinAccessToken) {
      return res.status(400).json({
        success: false,
        message: "LinkedIn not connected"
      });
    }

    const companies = await getUserCompanies(user.linkedinAccessToken);

    res.json({
      success: true,
      companies,
      selectedCompanyId: user.linkedinCompanyId || null
    });

  } catch (err: any) {
    console.error("[LinkedIn] Get companies error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to get LinkedIn companies",
      error: err.message
    });
  }
});

/* =======================================================
   5️⃣ SELECT LINKEDIN COMPANY (JWT REQUIRED)
   ======================================================= */
router.post("/select-company", verifyToken, async (req: any, res) => {
  if (!LINKEDIN.ENABLED) {
    return res.status(503).json({
      success: false,
      message: "LinkedIn integration is currently disabled"
    });
  }

  try {
    const { companyId } = req.body;

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // If companyId is null/undefined, clear the selection (post to personal)
    if (companyId === null || companyId === undefined) {
      user.linkedinCompanyId = undefined;
      await user.save();

      return res.json({
        success: true,
        message: "Switched to personal profile posting",
        company: null
      });
    }

    if (!companyId) {
      return res.status(400).json({
        success: false,
        message: "companyId is required"
      });
    }

    if (!user.linkedinAccessToken) {
      return res.status(400).json({
        success: false,
        message: "LinkedIn not connected"
      });
    }

    // Verify the user has access to this company
    const companies = await getUserCompanies(user.linkedinAccessToken);
    const companyExists = companies.find(c => c.id === companyId);

    if (!companyExists) {
      return res.status(400).json({
        success: false,
        message: "You don't have access to this company or it doesn't exist"
      });
    }

    // Save the selected company
    user.linkedinCompanyId = companyId;
    await user.save();

    res.json({
      success: true,
      message: "Company selected successfully",
      company: companyExists
    });

  } catch (err: any) {
    console.error("[LinkedIn] Select company error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to select company",
      error: err.message
    });
  }
});

export default router;
