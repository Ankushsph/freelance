/**
 * Facebook Publishing Service
 * Handles publishing to Facebook Pages
 */

import { FACEBOOK } from "../config";

interface FacebookPage {
  id: string;
  name: string;
  access_token: string;
  category?: string;
}

interface FacebookPublishResult {
  success: boolean;
  postId?: string;
  url?: string;
  error?: string;
}

/**
 * Get all Facebook Pages that the user manages
 */
export async function getUserPages(accessToken: string): Promise<FacebookPage[]> {
  try {
    const url = `${FACEBOOK.GRAPH_API_URL}/me/accounts?access_token=${accessToken}`;
    
    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Facebook] Failed to get pages:", data);
      throw new Error(data.error?.message || "Failed to get pages");
    }

    return data.data || [];
  } catch (error: any) {
    console.error("[Facebook] Error getting pages:", error);
    throw error;
  }
}

/**
 * Get a specific page's access token
 * The page access token is different from user access token
 */
export async function getPageAccessToken(
  userAccessToken: string, 
  pageId: string
): Promise<string | null> {
  try {
    const pages = await getUserPages(userAccessToken);
    const page = pages.find(p => p.id === pageId);
    return page?.access_token || null;
  } catch (error) {
    console.error("[Facebook] Error getting page access token:", error);
    return null;
  }
}

/**
 * Publish a post to a Facebook Page
 * Supports text-only or text + image posts
 */
export async function publishToPage(
  userAccessToken: string,
  pageId: string,
  message: string,
  imageUrl?: string
): Promise<FacebookPublishResult> {
  try {
    console.log(`[Facebook] Starting publish to page ${pageId}`);

    const pageAccessToken = await getPageAccessToken(userAccessToken, pageId);
    
    if (!pageAccessToken) {
      return {
        success: false,
        error: "Cannot get page access token. Make sure you have admin access to this page."
      };
    }

    let postUrl: string;
    let postData: any;

    if (imageUrl) {
      postUrl = `${FACEBOOK.GRAPH_API_URL}/${pageId}/photos`;
      postData = {
        access_token: pageAccessToken,
        message: message,
        url: imageUrl,
        published: true
      };
    } else {
      postUrl = `${FACEBOOK.GRAPH_API_URL}/${pageId}/feed`;
      postData = {
        access_token: pageAccessToken,
        message: message
      };
    }

    console.log(`[Facebook] Sending post request...`);
    const response = await fetch(postUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(postData)
    });

    const data: any = await response.json();

    if (!response.ok || !data.id) {
      console.error("[Facebook] Failed to publish:", data);
      return {
        success: false,
        error: data.error?.message || "Failed to publish post"
      };
    }

    const postId = data.id;
    console.log(`[Facebook] Successfully published! Post ID: ${postId}`);

    const postUrlFormatted = `https://facebook.com/${postId}`;

    return {
      success: true,
      postId: postId,
      url: postUrlFormatted
    };

  } catch (error: any) {
    console.error("[Facebook] Publishing error:", error);
    return {
      success: false,
      error: error.message || "Unknown error occurred"
    };
  }
}

/**
 * Get Facebook Page Insights
 * Returns metrics for the page over a date range
 */
export async function getFacebookPageInsights(
  accessToken: string,
  pageId: string,
  since: number,
  until: number
): Promise<any> {
  try {
    const pageAccessToken = await getPageAccessToken(accessToken, pageId);
    
    if (!pageAccessToken) {
      throw new Error("Cannot get page access token for insights");
    }

    const metrics = [
      'page_impressions',
      'page_impressions_unique',
      'page_engaged_users',
      'page_fan_adds',
      'page_total_actions'
    ].join(',');

    const url = `${FACEBOOK.GRAPH_API_URL}/${pageId}/insights?metric=${metrics}&since=${since}&until=${until}&period=day&access_token=${pageAccessToken}`;

    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Facebook] Insights error:", data);
      throw new Error(data.error?.message || "Failed to get insights");
    }

    const result: any = {
      impressions: 0,
      reach: 0,
      engagement: 0,
      followers: 0,
      history: []
    };

    if (data.data) {
      data.data.forEach((metric: any) => {
        const values = metric.values || [];
        const total = values.reduce((sum: number, v: any) => sum + (v.value || 0), 0);
        
        switch (metric.name) {
          case 'page_impressions':
            result.impressions = total;
            break;
          case 'page_impressions_unique':
            result.reach = total;
            break;
          case 'page_engaged_users':
            result.engagement = total;
            break;
          case 'page_fan_adds':
            result.followers = total;
            break;
        }
      });

      const impressionsMetric = data.data.find((m: any) => m.name === 'page_impressions');
      if (impressionsMetric && impressionsMetric.values) {
        result.history = impressionsMetric.values.map((v: any) => ({
          date: v.end_time,
          impressions: v.value || 0,
          reach: 0,
          engagement: 0
        }));
      }
    }

    return result;
  } catch (error: any) {
    console.error("[Facebook] Page insights error:", error);
    if (error.message?.includes('permission') || error.message?.includes('authorized')) {
      console.log("[Facebook] Insights permissions not granted, returning empty data");
      return {
        impressions: 0,
        reach: 0,
        engagement: 0,
        followers: 0,
        history: [],
        permissionsError: true
      };
    }
    throw error;
  }
}

/**
 * Get Facebook Page Posts
 * Returns recent posts from the page
 */
export async function getFacebookPagePosts(
  accessToken: string,
  pageId: string,
  limit: number = 20
): Promise<any[]> {
  try {
    const pageAccessToken = await getPageAccessToken(accessToken, pageId);
    
    if (!pageAccessToken) {
      throw new Error("Cannot get page access token");
    }

    const url = `${FACEBOOK.GRAPH_API_URL}/${pageId}/posts?fields=id,message,created_time,full_picture&limit=${limit}&access_token=${pageAccessToken}`;

    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Facebook] Posts error:", data);
      throw new Error(data.error?.message || "Failed to get posts");
    }

    return data.data || [];
  } catch (error: any) {
    console.error("[Facebook] Page posts error:", error);
    throw error;
  }
}

/**
 * Get Facebook Post Insights
 * Returns metrics for a specific post
 */
export async function getFacebookPostInsights(
  accessToken: string,
  postId: string
): Promise<any> {
  try {
    const metrics = [
      'post_impressions',
      'post_impressions_unique',
      'post_engaged_users',
      'post_reactions_by_type_total',
      'post_comments',
      'post_shares'
    ].join(',');

    const url = `${FACEBOOK.GRAPH_API_URL}/${postId}/insights?metric=${metrics}&access_token=${accessToken}`;

    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Facebook] Post insights error:", data);
      return null;
    }

    const result: any = {
      impressions: 0,
      reach: 0,
      engagement: 0,
      likes: 0,
      comments: 0,
      shares: 0
    };

    if (data.data) {
      data.data.forEach((metric: any) => {
        const values = metric.values || [];
        const value = values[0]?.value || 0;
        
        switch (metric.name) {
          case 'post_impressions':
            result.impressions = value;
            break;
          case 'post_impressions_unique':
            result.reach = value;
            break;
          case 'post_engaged_users':
            result.engagement = value;
            break;
          case 'post_reactions_by_type_total':
            result.likes = Object.values(value || {}).reduce((a: number, b: any) => a + (b || 0), 0);
            break;
          case 'post_comments':
            result.comments = value;
            break;
          case 'post_shares':
            result.shares = value;
            break;
        }
      });
    }

    return result;
  } catch (error: any) {
    console.error("[Facebook] Post insights error:", error);
    return null;
  }
}
