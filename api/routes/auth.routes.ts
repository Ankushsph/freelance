import { Router } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { User } from "../models/User";
import { Otp } from "../models/Otp";

const router = Router();

router.post("/signup", async (req, res) => {
  console.log("🔍 SIGNUP REQUEST:", req.body);
  
  const { name, email, number, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ message: "Missing fields" });
  }
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    console.log("❌ User already exists:", email);
    return res.status(409).json({ message: "User already exists" });
  }
  
  console.log("✅ Creating new user:", email);
  // Skip OTP verification for development
  const hashedPassword = await bcrypt.hash(password, 10);
  const user = await User.create({
    name,
    email,
    number,
    password: hashedPassword,
  });
  const token = jwt.sign(
    { userId: user._id },
    process.env.JWT_SECRET!,
    { expiresIn: "7d" }
  );
  
  console.log("✅ User created successfully:", user._id);
  res.status(201).json({
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
    },
  });
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "Email and password required" });
  }
  const user = await User.findOne({ email });
  if (!user || !user.password) {
    return res.status(401).json({ message: "Invalid credentials" });
  }
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    return res.status(401).json({ message: "Invalid credentials" });
  }
  const token = jwt.sign(
    { userId: user._id },
    process.env.JWT_SECRET!,
    { expiresIn: "7d" }
  );
  res.json({
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
    },
  });
});

router.post("/reset-password", async (req, res) => {
  const { email, newPassword } = req.body;
  const otp = await Otp.findOne({
    email,
    purpose: "forgot_password",
    verified: true,
  });
  if (!otp) {
    return res.status(403).json({ message: "OTP not verified" });
  }
  const hashed = await bcrypt.hash(newPassword, 10);
  await User.updateOne({ email }, { password: hashed });
  await Otp.deleteOne({ email, purpose: "forgot_password" });
  res.json({ message: "Password updated successfully" });
});

export default router;