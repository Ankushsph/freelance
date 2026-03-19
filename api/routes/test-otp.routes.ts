import { Router } from "express";
import crypto from "crypto";
import { Otp } from "../models/Otp";

const router = Router();

// Simple OTP endpoint without any email dependencies
router.post("/send", async (req, res) => {
  try {
    console.log("🔍 OTP Request received:", req.body);
    
    const { email, purpose } = req.body;
    if (!email || !purpose) {
      return res.status(400).json({ message: "Email & purpose required" });
    }

    // Generate OTP
    const otp = crypto.randomInt(1000, 9999).toString();
    
    // Save to database
    await Otp.findOneAndUpdate(
      { email, purpose },
      {
        otp,
        verified: false,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
      { upsert: true }
    );
    
    console.log("🔑 GENERATED OTP FOR", email, ":", otp);
    console.log("🔑 USE THIS OTP IN THE APP:", otp);
    console.log("========================");

    res.json({ 
      message: "OTP sent successfully", 
      otp: otp, // Include OTP in response for development
      email: email 
    });
  } catch (error) {
    console.error("❌ Error:", error);
    res.status(500).json({ message: "Failed to send OTP", error: error.message });
  }
});

export default router;