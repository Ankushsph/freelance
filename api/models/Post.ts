import { Schema, model, Document, Types } from "mongoose";

export type PostStatus = 
  | "pending" 
  | "scheduled" 
  | "publishing" 
  | "published" 
  | "partially_failed" 
  | "failed" 
  | "cancelled";

export type PlatformResult = 
  | { success: true; postId: string; url?: string }
  | { success: false; error: string };

export interface IPost extends Document {
  userId: Types.ObjectId;
  content: string;
  tags: string[];
  mediaUrls: string[];
  platforms: ("instagram" | "facebook" | "linkedin" | "twitter")[];
  scheduledTime: Date | null;
  status: PostStatus;
  results: {
    instagram?: PlatformResult;
    facebook?: PlatformResult;
    linkedin?: PlatformResult;
    twitter?: PlatformResult;
  };
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const PostSchema = new Schema<IPost>(
  {
    userId: { 
      type: Schema.Types.ObjectId, 
      ref: "User", 
      required: true,
      index: true
    },
    content: { 
      type: String, 
      required: true,
      maxlength: 2200 // Instagram caption limit
    },
    tags: [{
      type: String,
      default: []
    }],
    mediaUrls: [{ 
      type: String,
      required: true
    }],
    platforms: [{ 
      type: String, 
      enum: ["instagram", "facebook", "linkedin", "twitter"],
      required: true
    }],
    scheduledTime: { 
      type: Date, 
      default: null,
      index: true
    },
    status: { 
      type: String, 
      enum: ["pending", "scheduled", "publishing", "published", "partially_failed", "failed", "cancelled"],
      default: "pending",
      index: true
    },
    results: {
      type: Schema.Types.Mixed,
      default: {}
    },
    publishedAt: { 
      type: Date 
    }
  },
  { 
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Index for efficient querying of scheduled posts
PostSchema.index({ status: 1, scheduledTime: 1 });

export const Post = model<IPost>("Post", PostSchema);
