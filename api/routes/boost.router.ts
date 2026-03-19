import { Router } from "express";
import { Boost } from "../models/Boost.js";
import { verifyToken } from "../middleware/auth.js";
import { requirePremium } from "../middleware/premium.js";

const router = Router();

router.post("/send", verifyToken, requirePremium, async (req, res) => {
  try {
    const { name, userId, contact, timeSlot, message } = req.body;

    if (!name || !userId || !contact || !timeSlot) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    const boost = await Boost.create({
      name,
      userId,
      contact,
      timeSlot,
      message,
    });

    // Log boost request instead of sending email
    console.log("📧 BOOST REQUEST CREATED:");
    console.log("ID:", boost._id.toString());
    console.log("Name:", name);
    console.log("User ID:", userId);
    console.log("Contact:", contact);
    console.log("Time Slot:", timeSlot);
    console.log("Message:", message);
    console.log("========================");

    res.json({
      message: "Boost request sent successfully",
      boostId: boost._id,
    });
  } catch (err) {
    console.error("Boost Error:", err);

    res.status(500).json({
      message: "Failed to send boost request",
    });
  }
});

router.get("/action", async (req, res) => {
  try {
    const { id, type } = req.query;

    if (!id || !type) {
      return res.status(400).send("Invalid request");
    }

    if (!["approve", "reject"].includes(type as string)) {
      return res.status(400).send("Invalid action");
    }

    const status = type === "approve" ? "approved" : "rejected";

    const boost = await Boost.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    );

    if (!boost) {
      return res.status(404).send("Request not found");
    }

    res.send(`
      <div style="font-family:Arial;padding:30px;">
        <h2>Boost Request ${status.toUpperCase()}</h2>

        <p><b>User:</b> ${boost.name}</p>
        <p><b>Status:</b> ${status}</p>

        <hr/>

        <p>Action completed successfully.</p>
      </div>
    `);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

router.patch("/status/:id", async (req, res) => {
  try {
    const { status } = req.body;

    if (!["approved", "rejected", "pending"].includes(status)) {
      return res.status(400).json({
        message: "Invalid status",
      });
    }

    await Boost.findByIdAndUpdate(req.params.id, { status });

    res.json({ message: "Status updated" });
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/:userId", verifyToken, requirePremium, async (req, res) => {
  try {
    const { userId } = req.params;

    const boosts = await Boost.find({ userId }).sort({ createdAt: -1 });

    res.json(boosts);
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});

export default router;