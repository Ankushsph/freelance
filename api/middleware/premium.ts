import type { Request, Response, NextFunction } from "express";
import { Subscription } from "../models/Subscription.js";

// ✅ Extend Express Request type (matching auth.ts)
export interface AuthRequest extends Request {
  user?: { id: string };
}

export const requirePremium = async (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!req.user || !req.user.id) {
    return res.status(401).json({ success: false, message: "Authentication required" });
  }

  try {
    // Check subscription from Subscription model
    let subscription = await Subscription.findOne({ userId: req.user.id });
    
    // Create free subscription if doesn't exist
    if (!subscription) {
      subscription = await Subscription.create({
        userId: req.user.id,
        planType: 'free',
        subscriptionStatus: 'active'
      });
    }

    // Check if premium subscription expired
    if (subscription.planType === 'premium' && subscription.expiryDate) {
      if (new Date() > subscription.expiryDate) {
        subscription.subscriptionStatus = 'expired';
        subscription.planType = 'free';
        await subscription.save();
      }
    }

    // Check if user has premium
    if (subscription.planType !== 'premium' || subscription.subscriptionStatus !== 'active') {
      return res.status(403).json({ 
        success: false, 
        message: "Premium subscription required to access this feature",
        requireUpgrade: true 
      });
    }

    next();
  } catch (error) {
    console.error("Premium authorization error:", error);
    return res.status(500).json({ success: false, message: "Server error checking subscription status" });
  }
};
