import { Router } from "express";
import { User } from "../models/User";
import { verifyToken } from "../middleware/auth";
import { type AuthRequest } from "../middleware/auth";

const router = Router();

/* ---------- GET CURRENT USER ---------- */
router.get("/me", verifyToken, async (req: AuthRequest, res) => {
  try {
    const user = await User.findById(req.user!.id).select("-password");
    if (!user) return res.status(404).json({ message: "User not found" });

    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      number: user.number,
      instagramOAuthState: user.instagramOAuthState,
      instagramUserId: user.instagramUserId,
      instagramAccessToken: user.instagramAccessToken,
      planType: user.planType,
      subscriptionStatus: user.subscriptionStatus,
      subscriptionExpiryDate: user.subscriptionExpiryDate,
    });
  } catch (err) {
    res.status(401).json({ message: "Invalid token" });
  }
});

/* ---------- READ ALL USERS ---------- */
router.get("/", verifyToken, async (_req: AuthRequest, res) => {
  const users = await User.find().select("-password");
  res.json(users);
});

/* ---------- READ ONE USER ---------- */
router.get("/:id", verifyToken, async (_req: AuthRequest, res) => {
  const user = await User.findById(_req.params.id).select("-password");
  if (!user) return res.status(404).json({ message: "User not found" });
  res.json(user);
});

/* ---------- UPDATE USER ---------- */
router.put("/:id", verifyToken, async (_req: AuthRequest, res) => {
  const user = await User.findByIdAndUpdate(
    _req.params.id,
    _req.body,
    { new: true }
  ).select("-password");

  res.json(user);
});

/* ---------- DELETE USER ---------- */
router.delete("/:id", verifyToken, async (_req: AuthRequest, res) => {
  await User.findByIdAndDelete(_req.params.id);
  res.json({ message: "User deleted" });
});

/* ---------- DISCONNECT INSTAGRAM ---------- */
router.post("/disconnect/instagram", verifyToken, async (req: AuthRequest, res) => {
  try {
    const user = await User.findById(req.user!.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Clear Instagram tokens from database
    user.instagramAccessToken = undefined;
    user.instagramUserId = undefined;
    user.instagramOAuthState = undefined;
    await user.save();

    console.log(`[User] Instagram disconnected for user ${req.user!.id}`);
    res.json({ success: true, message: "Instagram disconnected successfully" });
  } catch (error: any) {
    console.error("[User] Error disconnecting Instagram:", error);
    res.status(500).json({ success: false, message: error.message || "Failed to disconnect Instagram" });
  }
});

/* ---------- DISCONNECT FACEBOOK ---------- */
router.post("/disconnect/facebook", verifyToken, async (req: AuthRequest, res) => {
  try {
    const user = await User.findById(req.user!.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Clear Facebook tokens from database
    user.facebookAccessToken = undefined;
    user.facebookUserId = undefined;
    user.facebookOAuthState = undefined;
    user.facebookPageId = undefined;
    await user.save();

    console.log(`[User] Facebook disconnected for user ${req.user!.id}`);
    res.json({ success: true, message: "Facebook disconnected successfully" });
  } catch (error: any) {
    console.error("[User] Error disconnecting Facebook:", error);
    res.status(500).json({ success: false, message: error.message || "Failed to disconnect Facebook" });
  }
});

/* ---------- DISCONNECT LINKEDIN ---------- */
router.post("/disconnect/linkedin", verifyToken, async (req: AuthRequest, res) => {
  try {
    const user = await User.findById(req.user!.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Clear LinkedIn tokens from database
    user.linkedinAccessToken = undefined;
    user.linkedinRefreshToken = undefined;
    user.linkedinUserId = undefined;
    user.linkedinCompanyId = undefined;
    user.linkedinOAuthState = undefined;
    await user.save();

    console.log(`[User] LinkedIn disconnected for user ${req.user!.id}`);
    res.json({ success: true, message: "LinkedIn disconnected successfully" });
  } catch (error: any) {
    console.error("[User] Error disconnecting LinkedIn:", error);
    res.status(500).json({ success: false, message: error.message || "Failed to disconnect LinkedIn" });
  }
});

/* ---------- DISCONNECT TWITTER ---------- */
router.post("/disconnect/twitter", verifyToken, async (req: AuthRequest, res) => {
  try {
    const user = await User.findById(req.user!.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Clear Twitter tokens from database
    user.twitterAccessToken = undefined;
    user.twitterRefreshToken = undefined;
    user.twitterUserId = undefined;
    user.twitterOAuthState = undefined;
    await user.save();

    console.log(`[User] Twitter disconnected for user ${req.user!.id}`);
    res.json({ success: true, message: "Twitter disconnected successfully" });
  } catch (error: any) {
    console.error("[User] Error disconnecting Twitter:", error);
    res.status(500).json({ success: false, message: error.message || "Failed to disconnect Twitter" });
  }
});

export default router;
