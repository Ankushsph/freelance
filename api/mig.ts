// mig.ts
import mongoose from "mongoose";
import { User } from "./models/User";

async function migrateInstagramFields() {
  try {
    // ✅ Connect to MongoDB
    await mongoose.connect("mongodb://localhost:27017/konnect"); // no extra options needed
    console.log("✅ MongoDB connected");

    // ✅ Update all users to add Instagram fields
    const result = await User.updateMany(
      {}, // all users
      { $set: { instagramAccessToken: null, instagramUserId: null } }
    );

    console.log(`🚀 Migration complete. Updated ${result.modifiedCount} users.`);

    // ✅ Disconnect
    await mongoose.disconnect();
    console.log("MongoDB disconnected");
  } catch (err) {
    console.error("Migration error:", err);
    process.exit(1);
  }
}

migrateInstagramFields();