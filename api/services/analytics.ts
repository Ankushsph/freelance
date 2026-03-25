/**
 * Analytics Service
 * Handles fetching insights and analytics data from social platforms
 */

import { User } from "../models/User";
import { getFacebookPageInsights, getFacebookPagePosts, getFacebookPostInsights, getUserPages } from "./facebook";
import { getInstagramAccountInsights, getInstagramMedia, getInstagramMediaInsights } from "./instagram";

export interface PlatformAnalytics {
  platform: string;
  connected: boolean;
  overview: {
    impressions: number;
    reach: number;
    engagement: number;
    followers: number;
  };
  history: Array<{
    date: string;
    impressions: number;
    reach: number;
    engagement: number;
  }>;
  posts: Array<{
    id: string;
    message?: string;
    caption?: string;
    created_time: string;
    media_type?: string;
    insights?: {
      impressions?: number;
      reach?: number;
      engagement?: number;
      likes?: number;
      comments?: number;
    };
  }>;
  permissionsError?: boolean;
}

export interface PostAnalytics {
  postId: string;
  platform: string;
  insights: {
    impressions: number;
    reach: number;
    engagement: number;
    likes: number;
    comments: number;
    shares?: number;
  };
}

/**
 * Get analytics for a specific user and platform
 */
export async function getPlatformAnalytics(
  userId: string,
  platform: 'facebook' | 'instagram' | 'linkedin' | 'twitter',
  days: number = 30
): Promise<PlatformAnalytics> {
  const user = await User.findById(userId);
  
  if (!user) {
    throw new Error("User not found");
  }

  if (platform === 'facebook') {
    return await getFacebookAnalytics(user, days);
  } else if (platform === 'instagram') {
    return await getInstagramAnalytics(user, days);
  } else if (platform === 'linkedin') {
    return await getLinkedInAnalytics(user, days);
  } else if (platform === 'twitter') {
    return await getTwitterAnalytics(user, days);
  }

  throw new Error(`Unsupported platform: ${platform}`);
}

/**
 * Get Facebook Page Analytics
 */
async function getFacebookAnalytics(user: any, days: number): Promise<PlatformAnalytics> {
  if (!user.facebookAccessToken) {
    // User not connected - return empty data
    return {
      platform: 'facebook',
      connected: false,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
    };
  }

  // If no page is selected but user has FB connected, get pages list
  if (!user.facebookPageId && user.facebookAccessToken) {
    try {
      const pages = await getUserPages(user.facebookAccessToken);
      if (pages.length > 0 && pages[0]) {
        // Auto-select first page for analytics
        const selectedPageId = pages[0].id;
        user.facebookPageId = selectedPageId;
        await (user as any).save();
        console.log(`[Analytics] Auto-selected Facebook page: ${selectedPageId}`);
      } else {
        return {
          platform: 'facebook',
          connected: true, // User is connected but has no pages
          overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
          history: [],
          posts: [],
        };
      }
    } catch (e) {
      console.error(`[Analytics] Failed to get pages:`, e);
    }
  }

  try {
    console.log(`[Analytics] Fetching Facebook analytics for Page: ${user.facebookPageId}`);
    
    // Calculate date range
    const until = Math.floor(Date.now() / 1000);
    const since = until - (days * 24 * 60 * 60);

    // Get page insights
    console.log(`[Analytics] Fetching Page insights from ${since} to ${until}`);
    let insights: any = { impressions: 0, reach: 0, engagement: 0, followers: 0, history: [] };
    let permissionsError = false;
    
    try {
      insights = await getFacebookPageInsights(
        user.facebookAccessToken,
        user.facebookPageId,
        since,
        until
      );
      permissionsError = insights.permissionsError || false;
      console.log(`[Analytics] Facebook insights result:`, insights);
    } catch (insightError: any) {
      console.error(`[Analytics] Failed to get page insights:`, insightError);
      permissionsError = true;
    }

    // Get recent posts
    let posts: any[] = [];
    try {
      posts = await getFacebookPagePosts(
        user.facebookAccessToken,
        user.facebookPageId,
        20 // Get last 20 posts
      );
      console.log(`[Analytics] Fetched ${posts.length} posts`);
    } catch (postError) {
      console.error(`[Analytics] Failed to get page posts:`, postError);
    }

    // Enrich posts with insights
    const postsWithInsights = await Promise.all(
      posts.map(async (post: any) => {
        try {
          const postInsights = await getFacebookPostInsights(
            user.facebookAccessToken,
            post.id
          );
          return {
            id: post.id,
            message: post.message || '',
            created_time: post.created_time,
            insights: postInsights,
          };
        } catch (e) {
          return {
            id: post.id,
            message: post.message || '',
            created_time: post.created_time,
            insights: undefined,
          };
        }
      })
    );

    // Calculate totals from posts if page insights failed
    let totalImpressions = insights.impressions || 0;
    let totalReach = insights.reach || 0;
    let totalEngagement = insights.engagement || 0;
    
    if (permissionsError && postsWithInsights.length > 0) {
      totalImpressions = postsWithInsights.reduce((sum: number, post: any) => 
        sum + (post.insights?.impressions || 0), 0);
      totalReach = postsWithInsights.reduce((sum: number, post: any) => 
        sum + (post.insights?.reach || 0), 0);
      totalEngagement = postsWithInsights.reduce((sum: number, post: any) => 
        sum + (post.insights?.engagement || 0), 0);
    }

    return {
      platform: 'facebook',
      connected: true,
      overview: {
        impressions: totalImpressions,
        reach: totalReach,
        engagement: totalEngagement,
        followers: insights.followers || 0,
      },
      history: insights.history || [],
      posts: postsWithInsights,
      permissionsError: permissionsError,
    };
  } catch (error: any) {
    console.error("[Analytics] Facebook error:", error);
    // Return empty analytics instead of throwing
    return {
      platform: 'facebook',
      connected: true,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
      permissionsError: true,
    };
  }
}

/**
 * Get LinkedIn Analytics
 */
async function getLinkedInAnalytics(user: any, days: number): Promise<PlatformAnalytics> {
  if (!user.linkedinAccessToken) {
    // User not connected - return empty data
    return {
      platform: 'linkedin',
      connected: false,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
    };
  }

  // LinkedIn API integration - for now return empty data with connected status
  // TODO: Implement LinkedIn analytics API calls
  return {
    platform: 'linkedin',
    connected: true,
    overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
    history: [],
    posts: [],
    permissionsError: false,
  };
}

/**
 * Get Twitter/X Analytics
 */
async function getTwitterAnalytics(user: any, days: number): Promise<PlatformAnalytics> {
  if (!user.twitterAccessToken) {
    // User not connected - return empty data
    return {
      platform: 'twitter',
      connected: false,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
    };
  }

  // Twitter API integration - for now return empty data with connected status
  // TODO: Implement Twitter analytics API calls
  return {
    platform: 'twitter',
    connected: true,
    overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
    history: [],
    posts: [],
    permissionsError: false,
  };
}

/**
 * Get Instagram Account Analytics
 */
async function getInstagramAnalytics(user: any, days: number): Promise<PlatformAnalytics> {
  if (!user.instagramAccessToken || !user.instagramUserId) {
    // User not connected - return empty data
    return {
      platform: 'instagram',
      connected: false,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
    };
  }

  try {
    console.log(`[Analytics] Fetching Instagram analytics for user ${user._id}, days: ${days}`);
    
    // Get account insights (may fail for non-business accounts)
    let insights: any = { reach: 0, engagement: 0, followers: 0, profileViews: 0, history: [] };
    try {
      insights = await getInstagramAccountInsights(
        user.instagramAccessToken,
        user.instagramUserId,
        days
      );
      console.log(`[Analytics] Instagram account insights:`, insights);
    } catch (insightError) {
      console.log(`[Analytics] Account insights not available (non-business account or permissions):`, insightError);
    }

    // Get recent media - this should work for all account types
    let media: any[] = [];
    try {
      media = await getInstagramMedia(
        user.instagramAccessToken,
        user.instagramUserId,
        20 // Get last 20 posts
      );
      console.log(`[Analytics] Fetched ${media.length} media items`);
    } catch (mediaError) {
      console.error(`[Analytics] Failed to fetch media:`, mediaError);
    }

    // Enrich media with insights
    const postsWithInsights = await Promise.all(
      media.map(async (item: any) => {
        try {
          console.log(`[Analytics] Fetching insights for media ${item.id} (${item.media_type})`);
          const mediaInsights = await getInstagramMediaInsights(
            user.instagramAccessToken,
            item.id,
            item.media_type
          );
          console.log(`[Analytics] Media ${item.id} insights:`, mediaInsights);
          return {
            id: item.id,
            caption: item.caption || '',
            created_time: item.timestamp,
            media_type: item.media_type,
            insights: mediaInsights,
          };
        } catch (e) {
          console.log(`[Analytics] Error fetching insights for ${item.id}:`, e);
          return {
            id: item.id,
            caption: item.caption || '',
            created_time: item.timestamp,
            media_type: item.media_type,
            insights: {
              impressions: 0,
              reach: item.like_count || 0, // Use like_count as fallback for reach
              engagement: (item.like_count || 0) + (item.comments_count || 0),
              likes: item.like_count || 0,
              comments: item.comments_count || 0,
            },
          };
        }
      })
    );

    // Calculate total metrics from posts (account-level metrics may not be available)
    const totalImpressions = postsWithInsights.reduce((sum: number, post: any) => 
      sum + (post.insights?.impressions || 0), 0);
    
    const totalReach = postsWithInsights.reduce((sum: number, post: any) => 
      sum + (post.insights?.reach || 0), 0);
    
    const totalEngagement = postsWithInsights.reduce((sum: number, post: any) => 
      sum + (post.insights?.engagement || 0), 0);
    
    const totalLikes = postsWithInsights.reduce((sum: number, post: any) => 
      sum + (post.insights?.likes || 0), 0);
    
    console.log(`[Analytics] Total impressions from posts: ${totalImpressions}`);
    console.log(`[Analytics] Total reach from posts: ${totalReach}`);
    console.log(`[Analytics] Total engagement from posts: ${totalEngagement}`);
    console.log(`[Analytics] Total likes from posts: ${totalLikes}`);

    return {
      platform: 'instagram',
      connected: true,
      overview: {
        impressions: totalImpressions,
        reach: totalReach || insights.reach || totalLikes || 0,
        engagement: totalEngagement || insights.engagement || 0,
        followers: insights.followers || 0,
      },
      history: insights.history || [],
      posts: postsWithInsights,
      permissionsError: !!insights.error,
    };
  } catch (error: any) {
    console.error("[Analytics] Instagram error:", error);
    // Return empty analytics instead of throwing
    return {
      platform: 'instagram',
      connected: true,
      overview: { impressions: 0, reach: 0, engagement: 0, followers: 0 },
      history: [],
      posts: [],
      permissionsError: true,
    };
  }
}

/**
 * Get analytics for a specific post
 */
export async function getPostAnalytics(
  userId: string,
  platform: 'facebook' | 'instagram' | 'linkedin' | 'twitter',
  postId: string
): Promise<PostAnalytics> {
  const user = await User.findById(userId);
  
  if (!user) {
    throw new Error("User not found");
  }

  if (platform === 'facebook') {
    if (!user.facebookAccessToken) {
      throw new Error("Facebook not connected");
    }

    const insights = await getFacebookPostInsights(user.facebookAccessToken, postId);
    
    return {
      postId,
      platform: 'facebook',
      insights: {
        impressions: insights?.impressions || 0,
        reach: insights?.reach || 0,
        engagement: insights?.engagement || 0,
        likes: insights?.likes || 0,
        comments: insights?.comments || 0,
        shares: insights?.shares || 0,
      },
    };
  } else if (platform === 'instagram') {
    if (!user.instagramAccessToken) {
      throw new Error("Instagram not connected");
    }

    const insights = await getInstagramMediaInsights(user.instagramAccessToken, postId);
    
    return {
      postId,
      platform: 'instagram',
      insights: {
        impressions: insights?.impressions || 0,
        reach: insights?.reach || 0,
        engagement: insights?.engagement || 0,
        likes: insights?.likes || 0,
        comments: insights?.comments || 0,
      },
    };
  } else if (platform === 'linkedin' || platform === 'twitter') {
    // Return dummy data for LinkedIn and Twitter
    return {
      postId,
      platform,
      insights: {
        impressions: 4523,
        reach: 3245,
        engagement: 892,
        likes: 756,
        comments: 89,
        shares: 47,
      },
    };
  }

  throw new Error(`Unsupported platform: ${platform}`);
}


/**
 * Generate dummy analytics data for demo purposes
 */
function getDummyAnalytics(platform: string, days: number): PlatformAnalytics {
  const now = new Date();
  const history = [];
  
  // Generate history data
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(now);
    date.setDate(date.getDate() - i);
    
    history.push({
      date: date.toISOString().split('T')[0] || date.toISOString(),
      impressions: Math.floor(Math.random() * 3000) + 1000,
      reach: Math.floor(Math.random() * 2000) + 500,
      engagement: Math.floor(Math.random() * 500) + 100,
    });
  }
  
  // Generate dummy posts
  const posts = [
    {
      id: '1',
      message: '🚀 Excited to announce our new product launch! Check it out now!',
      created_time: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
      media_type: 'IMAGE',
      insights: {
        impressions: 4523,
        reach: 3245,
        engagement: 892,
        likes: 756,
        comments: 89,
        shares: 47,
      },
    },
    {
      id: '2',
      caption: '✨ Behind the scenes of our latest campaign! Swipe to see more 📸',
      created_time: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000).toISOString(),
      media_type: 'CAROUSEL_ALBUM',
      insights: {
        impressions: 6234,
        reach: 4567,
        engagement: 1234,
        likes: 1089,
        comments: 123,
        shares: 22,
      },
    },
    {
      id: '3',
      caption: '🎥 Watch our new tutorial video! Link in bio 👆',
      created_time: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000).toISOString(),
      media_type: 'REELS',
      insights: {
        impressions: 12456,
        reach: 8934,
        engagement: 2345,
        likes: 2134,
        comments: 189,
        shares: 22,
      },
    },
    {
      id: '4',
      message: '💡 Pro tip: Here\'s how to maximize your productivity!',
      created_time: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString(),
      media_type: 'IMAGE',
      insights: {
        impressions: 3456,
        reach: 2345,
        engagement: 567,
        likes: 489,
        comments: 67,
        shares: 11,
      },
    },
    {
      id: '5',
      caption: '🌟 Customer testimonial: "Best decision we ever made!" - @happycustomer',
      created_time: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      media_type: 'IMAGE',
      insights: {
        impressions: 2789,
        reach: 1956,
        engagement: 445,
        likes: 378,
        comments: 56,
        shares: 11,
      },
    },
  ];
  
  // Calculate totals
  const totalImpressions = history.reduce((sum, h) => sum + h.impressions, 0);
  const totalReach = history.reduce((sum, h) => sum + h.reach, 0);
  const totalEngagement = history.reduce((sum, h) => sum + h.engagement, 0);
  
  return {
    platform,
    connected: true,
    overview: {
      impressions: totalImpressions,
      reach: totalReach,
      engagement: totalEngagement,
      followers: 12543,
    },
    history,
    posts,
    permissionsError: false,
  };
}
