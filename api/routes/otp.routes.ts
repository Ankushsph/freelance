import crypto from "crypto";
import { Otp } from "../models/Otp";
import { User } from "../models/User";
import { Router } from "express";
import { transporter } from "../utils/mailer";
import { otpTemplate } from "../utils/otpTemplate";

const router = Router();

/* SEND OTP - WITH EMAIL */
router.post("/send", async (req, res) => {
  try {
    console.log("🔍 OTP SEND REQUEST:", req.body);
    
    const { email, purpose } = req.body;
    if (!email || !purpose) {
      return res.status(400).json({ message: "Email & purpose required" });
    }
    if (purpose === "forgot_password") {
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
    }
    
    // Generate OTP
    const otp = crypto.randomInt(1000, 9999).toString();
    
    // Save OTP to database
    await Otp.findOneAndUpdate(
      { email, purpose },
      {
        otp,
        verified: false,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
      { upsert: true }
    );
    
    // Log OTP for development
    console.log("🔑 GENERATED OTP FOR", email, ":", otp);
    
    // Try to send email
    try {
      await transporter.sendMail({
        from: process.env.MAIL_USER || 'noreply@konnectmedia.com',
        to: email,
        subject: 'Your KonnectMedia OTP',
        html: otpTemplate(otp, purpose),
      });
      console.log("✅ OTP email sent to", email);
    } catch (emailError: any) {
      console.log("⚠️  Email sending failed:", emailError.message);
      console.log("🔑 USE THIS OTP IN THE APP:", otp);
    }

    res.json({ 
      message: "OTP sent successfully", 
      otp: otp, // Include OTP in response for development
      email: email 
    });
  } catch (error: any) {
    console.error("❌ Error sending OTP:", error);
    res.status(500).json({ message: "Failed to send OTP", error: error?.message || String(error) });
  }
});

/* VERIFY OTP */
router.post("/verify", async (req, res) => {
  try {
    const { email, otp, purpose } = req.body;
    console.log(`🔍 Verifying OTP for ${email}: ${otp}`);
    
    const record = await Otp.findOne({ email, purpose });
    if (!record || record.otp !== otp || record.expiresAt < new Date()) {
      console.log(`❌ Invalid OTP for ${email}`);
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }
    
    record.verified = true;
    await record.save();
    
    console.log(`✅ OTP verified successfully for ${email}`);
    res.json({ message: "OTP verified" });
  } catch (error: any) {
    console.error("❌ Error verifying OTP:", error);
    res.status(500).json({ message: "Failed to verify OTP", error: error?.message || String(error) });
  }
});

export default router;