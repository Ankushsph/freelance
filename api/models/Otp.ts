// models/Otp.ts
import mongoose from "mongoose";

const otpSchema = new mongoose.Schema({
  email: { type: String, required: true },
  otp: { type: String, required: true },
  purpose: {
    type: String,
    enum: ["signup", "forgot_password", "change_email"],
    required: true,
  },
  verified: { type: Boolean, default: false },
  expiresAt: { type: Date, required: true },
});

export const Otp = mongoose.model("Otp", otpSchema);
