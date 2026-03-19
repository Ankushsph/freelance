import mongoose from "mongoose";

const boostSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },

    name: {
      type: String,
      required: true,
    },

    contact: {
      type: String,
      required: true,
    },

    timeSlot: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      default: null,
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
  },
  { timestamps: true }
);

export const Boost = mongoose.model("Boost", boostSchema);