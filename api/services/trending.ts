/**
 * Trending Service
 * Manages trending posts and calculates trending scores
 * Uses a weighted engagement algorithm with time decay
 */

import { TrendingPost, type ITrendingPost } from "../models/TrendingPost";
import { Post } from "../models/Post";
import { Types } from "mongoose";

// Weight constants for engagement types
const ENGAGEMENT_WEIGHTS = {
  likes: 1,
  comments: 3,
  shares: 5,
  views: 0.1,
};

// Time decay constant (hours)
const TIME_DECAY_HOURS = 24;

interface EngagementData {
  likes?: number;
  comments?: number;
  shares?: number;
  views?: number;
  retweets?: number;
}

interface PlatformEngagement {
  instagram?: EngagementData;
  facebook?: EngagementData;
  linkedin?: EngagementData;
  twitter?: EngagementData;
}

/**
 * Calculate trending score using engagement + time decay algorithm
 * Formula: (likes + comments*3 + shares*5 + views*0.1) / (hours_since_post + 2)^1.5
 */
function calculateTrendingScore(
  engagement: {
    likes: number;
    comments: number;
    shares: number;
    views: number;
  },
  publishedAt: Date
): number {
  const hoursSincePost =
    (Date.now() - publishedAt.getTime()) / (1000 * 60 * 60);

  // Calculate weighted engagement score
  const engagementScore =
    engagement.likes * ENGAGEMENT_WEIGHTS.likes +
    engagement.comments * ENGAGEMENT_WEIGHTS.comments +
    engagement.shares * ENGAGEMENT_WEIGHTS.shares +
    engagement.views * ENGAGEMENT_WEIGHTS.views;

  // Apply time decay (Reddit-style hot algorithm)
  // The +2 prevents division by zero and gives new posts a boost
  const timeDecay = Math.pow(hoursSincePost + 2, 1.5);

  return engagementScore / timeDecay;
}

/**
 * Aggregate engagement across all platforms
 */
function aggregateEngagement(
  platformEngagement: PlatformEngagement
): { likes: number; comments: number; shares: number; views: number } {
  let likes = 0;
  let comments = 0;
  let shares = 0;
  let views = 0;

  Object.entries(platformEngagement).forEach(([platform, data]) => {
    if (data) {
      likes += data.likes || 0;
      comments += data.comments || 0;
      views += data.views || 0;

      // Shares come from different fields depending on platform
      if (platform === "twitter") {
        shares += (data as any).retweets || 0;
      } else {
        shares += data.shares || 0;
      }
    }
  });

  return { likes, comments, shares, views };
}

/**
 * Create a trending post entry when a post is published
 */
export async function createTrendingPost(
  postId: string,
  userId: string,
  content: string,
  mediaUrls: string[],
  platforms: ("instagram" | "facebook" | "linkedin" | "twitter")[]
): Promise<ITrendingPost> {
  const trendingPost = new TrendingPost({
    postId: new Types.ObjectId(postId),
    userId: new Types.ObjectId(userId),
    content: content.substring(0, 200), // Store truncated content
    mediaUrls,
    platforms,
    publishedAt: new Date(),
    likes: 0,
    comments: 0,
    shares: 0,
    views: 0,
    platformEngagement: {},
    trendingScore: 0,
    rank: 0,
    previousRank: 0,
  });

  await trendingPost.save();
  console.log(`[Trending] Created trending entry for post ${postId}`);

  return trendingPost;
}

/**
 * Update engagement metrics for a trending post
 */
export async function updateEngagement(
  postId: string,
  platform: "instagram" | "facebook" | "linkedin" | "twitter",
  engagement: EngagementData
): Promise<ITrendingPost | null> {
  const trendingPost = await TrendingPost.findOne({
    postId: new Types.ObjectId(postId),
  });

  if (!trendingPost) {
    console.warn(`[Trending] Post ${postId} not found for engagement update`);
    return null;
  }

  // Update platform-specific engagement
  if (!trendingPost.platformEngagement) {
    trendingPost.platformEngagement = {};
  }

  // Build platform-specific engagement data
  const platformData: any = {
    likes: engagement.likes || 0,
    comments: engagement.comments || 0,
    views: engagement.views || 0,
  };
  
  if (platform === "twitter") {
    platformData.retweets = (engagement as any).retweets || 0;
  } else {
    platformData.shares = engagement.shares || 0;
  }
  
  trendingPost.platformEngagement[platform] = platformData;

  // Aggregate total engagement
  const aggregated = aggregateEngagement(
    trendingPost.platformEngagement as PlatformEngagement
  );

  trendingPost.likes = aggregated.likes;
  trendingPost.comments = aggregated.comments;
  trendingPost.shares = aggregated.shares;
  trendingPost.views = aggregated.views;

  // Recalculate trending score
  trendingPost.trendingScore = calculateTrendingScore(
    aggregated,
    trendingPost.publishedAt
  );

  await trendingPost.save();

  console.log(
    `[Trending] Updated engagement for post ${postId} on ${platform}. New score: ${trendingPost.trendingScore.toFixed(2)}`
  );

  return trendingPost;
}

/**
 * Get trending posts with pagination and filtering
 */
export async function getTrendingPosts(options: {
  limit?: number;
  skip?: number;
  platform?: "instagram" | "facebook" | "linkedin" | "twitter" | "all";
  timeframe?: "24h" | "7d" | "30d" | "all";
}): Promise<{ posts: ITrendingPost[]; total: number }> {
  const {
    limit = 20,
    skip = 0,
    platform = "all",
    timeframe = "7d",
  } = options;

  // Build query
  const query: any = {};

  // Platform filter
  if (platform !== "all") {
    query.platforms = platform;
  }

  // Timeframe filter
  if (timeframe !== "all") {
    const now = new Date();
    let startDate: Date;

    switch (timeframe) {
      case "24h":
        startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case "7d":
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case "30d":
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(0);
    }

    query.publishedAt = { $gte: startDate };
  }

  // Get total count
  const total = await TrendingPost.countDocuments(query);

  // Get posts sorted by trending score
  const posts = await TrendingPost.find(query)
    .sort({ trendingScore: -1, publishedAt: -1 })
    .skip(skip)
    .limit(limit)
    .populate("userId", "name username avatar")
    .lean();

  // Update ranks
  const rankedPosts = posts.map((post, index) => ({
    ...post,
    rank: skip + index + 1,
  }));

  return { posts: rankedPosts as unknown as ITrendingPost[], total };
}

/**
 * Get trending posts for a specific user
 */
export async function getUserTrendingPosts(
  userId: string,
  options: { limit?: number; skip?: number } = {}
): Promise<{ posts: ITrendingPost[]; total: number }> {
  const { limit = 20, skip = 0 } = options;

  const query = { userId: new Types.ObjectId(userId) };

  const total = await TrendingPost.countDocuments(query);

  const posts = await TrendingPost.find(query)
    .sort({ trendingScore: -1, publishedAt: -1 })
    .skip(skip)
    .limit(limit)
    .lean();

  return { posts, total };
}

/**
 * Recalculate all trending scores (can be run periodically via cron job)
 */
export async function recalculateAllTrendingScores(): Promise<number> {
  const posts = await TrendingPost.find({});
  let updatedCount = 0;

  for (const post of posts) {
    const aggregated = aggregateEngagement(
      post.platformEngagement as PlatformEngagement
    );

    const newScore = calculateTrendingScore(aggregated, post.publishedAt);

    // Only update if score changed significantly
    if (Math.abs(newScore - post.trendingScore) > 0.01) {
      post.previousRank = post.rank;
      post.trendingScore = newScore;
      await post.save();
      updatedCount++;
    }
  }

  console.log(
    `[Trending] Recalculated scores for ${updatedCount}/${posts.length} posts`
  );

  return updatedCount;
}

/**
 * Get global trending statistics
 */
export async function getTrendingStats(): Promise<{
  totalPosts: number;
  totalEngagement: {
    likes: number;
    comments: number;
    shares: number;
    views: number;
  };
  topPlatforms: { platform: string; count: number }[];
}> {
  const stats = await TrendingPost.aggregate([
    {
      $group: {
        _id: null,
        totalPosts: { $sum: 1 },
        totalLikes: { $sum: "$likes" },
        totalComments: { $sum: "$comments" },
        totalShares: { $sum: "$shares" },
        totalViews: { $sum: "$views" },
      },
    },
  ]);

  const platformStats = await TrendingPost.aggregate([
    { $unwind: "$platforms" },
    {
      $group: {
        _id: "$platforms",
        count: { $sum: 1 },
      },
    },
    { $sort: { count: -1 } },
  ]);

  const result = stats[0] || {
    totalPosts: 0,
    totalLikes: 0,
    totalComments: 0,
    totalShares: 0,
    totalViews: 0,
  };

  return {
    totalPosts: result.totalPosts,
    totalEngagement: {
      likes: result.totalLikes,
      comments: result.totalComments,
      shares: result.totalShares,
      views: result.totalViews,
    },
    topPlatforms: platformStats.map((p) => ({
      platform: p._id,
      count: p.count,
    })),
  };
}

/**
 * Delete trending post entry (when original post is deleted)
 */
export async function deleteTrendingPost(postId: string): Promise<void> {
  await TrendingPost.findOneAndDelete({ postId: new Types.ObjectId(postId) });
  console.log(`[Trending] Deleted trending entry for post ${postId}`);
}

export {
  calculateTrendingScore,
  aggregateEngagement,
  ENGAGEMENT_WEIGHTS,
  TIME_DECAY_HOURS,
};
