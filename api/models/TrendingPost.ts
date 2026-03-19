import { Schema, model, Document, Types } from "mongoose";

export interface ITrendingPost extends Document {
  postId: Types.ObjectId;
  userId: Types.ObjectId;
  content: string;
  mediaUrls: string[];
  platforms: ("instagram" | "facebook" | "linkedin" | "twitter")[];
  publishedAt: Date;
  
  // Engagement metrics (aggregated across all platforms)
  likes: number;
  comments: number;
  shares: number;
  views: number;
  
  // Platform-specific engagement
  platformEngagement: {
    instagram?: { likes: number; comments: number; views?: number };
    facebook?: { likes: number; comments: number; shares: number; views?: number };
    linkedin?: { likes: number; comments: number; shares: number; views?: number };
    twitter?: { likes: number; comments: number; retweets: number; views?: number };
  };
  
  // Trending score (calculated field)
  trendingScore: number;
  
  // Rank tracking
  rank: number;
  previousRank: number;
  
  createdAt: Date;
  updatedAt: Date;
}

const TrendingPostSchema = new Schema<ITrendingPost>(
  {
    postId: {
      type: Schema.Types.ObjectId,
      ref: "Post",
      required: true,
      unique: true,
      index: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    content: {
      type: String,
      required: true,
    },
    mediaUrls: [{
      type: String,
      required: true,
    }],
    platforms: [{
      type: String,
      enum: ["instagram", "facebook", "linkedin", "twitter"],
      required: true,
    }],
    publishedAt: {
      type: Date,
      required: true,
      index: true,
    },
    
    // Engagement metrics
    likes: {
      type: Number,
      default: 0,
      index: true,
    },
    comments: {
      type: Number,
      default: 0,
    },
    shares: {
      type: Number,
      default: 0,
    },
    views: {
      type: Number,
      default: 0,
    },
    
    // Platform-specific engagement
    platformEngagement: {
      type: Schema.Types.Mixed,
      default: {},
    },
    
    // Trending score for ranking
    trendingScore: {
      type: Number,
      default: 0,
      index: true,
    },
    
    // Rank tracking
    rank: {
      type: Number,
      default: 0,
    },
    previousRank: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Compound index for efficient trending queries
TrendingPostSchema.index({ trendingScore: -1, publishedAt: -1 });
TrendingPostSchema.index({ platforms: 1, trendingScore: -1 });

export const TrendingPost = model<ITrendingPost>("TrendingPost", TrendingPostSchema);
