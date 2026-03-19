import { Schema, model, Document, Types } from "mongoose";

export interface IConversation extends Document {
  userId: Types.ObjectId;
  title: string;
  createdAt: Date;
  updatedAt: Date;
  messageCount: number;
  lastMessageAt: Date;
  isArchived: boolean;
}

const ConversationSchema = new Schema<IConversation>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      default: "New Chat",
    },
    messageCount: {
      type: Number,
      default: 0,
    },
    lastMessageAt: {
      type: Date,
      default: Date.now,
    },
    isArchived: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// Indexes for faster queries
ConversationSchema.index({ userId: 1, lastMessageAt: -1 });
ConversationSchema.index({ userId: 1, isArchived: 1 });

export const Conversation = model<IConversation>("Conversation", ConversationSchema);
