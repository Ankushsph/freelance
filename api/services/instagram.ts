/**
 * Instagram Publishing Service
 * Handles publishing to Instagram Business accounts
 */

import { INSTAGRAM } from "../config";

interface InstagramPublishResult {
  success: boolean;
  postId?: string;
  url?: string;
  error?: string;
}

/**
 * Publish an image post to Instagram
 * 
 * Process:
 * 1. Create a media container with the image URL
 * 2. Publish the container
 * 
 * Note: Instagram requires publicly accessible image URLs
 */
export async function publishToInstagram(
  accessToken: string,
  instagramUserId: string,
  imageUrl: string,
  caption: string
): Promise<InstagramPublishResult> {
  try {
    console.log(`[Instagram] Starting publish for user ${instagramUserId}`);

    const createUrl = `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${instagramUserId}/media`;
    const createParams = new URLSearchParams({
      access_token: accessToken,
      image_url: imageUrl,
      caption: caption
    });

    console.log(`[Instagram] Creating media container...`);
    const createResponse = await fetch(createUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: createParams
    });

    const createData: any = await createResponse.json();

    if (!createResponse.ok || !createData.id) {
      console.error("[Instagram] Failed to create media container:", createData);
      const errorMsg = createData.error?.message || "Failed to create media container";
      const errorSubcode = createData.error?.error_subcode;
      
      let helpfulError = errorMsg;
      if (errorSubcode === 2207052 || errorMsg.includes("media type")) {
        helpfulError = `Instagram cannot access the image URL. Make sure: 1) The URL is publicly accessible (not localhost), 2) The image is a valid JPG/PNG file, 3) The image URL returns proper content-type headers. URL: ${imageUrl}`;
      }
      
      return {
        success: false,
        error: helpfulError
      };
    }

    const mediaId = createData.id;
    console.log(`[Instagram] Media container created: ${mediaId}`);

    await new Promise(resolve => setTimeout(resolve, 2000));

    const publishUrl = `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${instagramUserId}/media_publish`;
    const publishParams = new URLSearchParams({
      access_token: accessToken,
      creation_id: mediaId
    });

    console.log(`[Instagram] Publishing media...`);
    const publishResponse = await fetch(publishUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: publishParams
    });

    const publishData: any = await publishResponse.json();

    if (!publishResponse.ok || !publishData.id) {
      console.error("[Instagram] Failed to publish media:", publishData);
      return {
        success: false,
        error: publishData.error?.message || "Failed to publish media"
      };
    }

    const postId = publishData.id;
    console.log(`[Instagram] Successfully published! Post ID: ${postId}`);

    const postUrl = `https://instagram.com/p/${postId}`;

    return {
      success: true,
      postId: postId,
      url: postUrl
    };

  } catch (error: any) {
    console.error("[Instagram] Publishing error:", error);
    return {
      success: false,
      error: error.message || "Unknown error occurred"
    };
  }
}

/**
 * Validate if an image URL is publicly accessible
 * Instagram requires images to be publicly accessible
 */
export async function validateImageUrl(imageUrl: string): Promise<{ valid: boolean; error?: string }> {
  try {
    const response = await fetch(imageUrl, { method: "HEAD" });
    
    if (!response.ok) {
      return {
        valid: false,
        error: `Image URL returned status ${response.status}`
      };
    }

    const contentType = response.headers.get("content-type");
    if (!contentType || !contentType.startsWith("image/")) {
      return {
        valid: false,
        error: "URL does not point to a valid image"
      };
    }

    return { valid: true };
  } catch (error: any) {
    return {
      valid: false,
      error: `Cannot access image URL: ${error.message}`
    };
  }
}

/**
 * Get Instagram Account Insights
 * Returns metrics for the account
 */
export async function getInstagramAccountInsights(
  accessToken: string,
  instagramUserId: string,
  days: number = 30
): Promise<any> {
  try {
    const metrics = [
      'reach',
      'accounts_engaged',
      'follower_count',
      'profile_views'
    ].join(',');

    const url = `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${instagramUserId}/insights?metric=${metrics}&period=day&since=${Math.floor(Date.now()/1000) - days*24*60*60}&until=${Math.floor(Date.now()/1000)}&access_token=${accessToken}`;

    console.log(`[Instagram] Fetching account insights from: ${url.replace(accessToken, '***TOKEN***')}`);
    
    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Instagram] Account insights error:", data);
      return {
        reach: 0,
        engagement: 0,
        followers: 0,
        profileViews: 0,
        history: [],
        error: data.error?.message || "Failed to get account insights"
      };
    }

    const result: any = {
      reach: 0,
      engagement: 0,
      followers: 0,
      profileViews: 0,
      history: []
    };

    if (data.data) {
      data.data.forEach((metric: any) => {
        const values = metric.values || [];
        const total = values.reduce((sum: number, v: any) => sum + (v.value || 0), 0);
        
        switch (metric.name) {
          case 'reach':
            result.reach = total;
            break;
          case 'accounts_engaged':
            result.engagement = total;
            break;
          case 'follower_count':
            result.followers = values[values.length - 1]?.value || 0;
            break;
          case 'profile_views':
            result.profileViews = total;
            break;
        }
      });

      const reachMetric = data.data.find((m: any) => m.name === 'reach');
      const engagementMetric = data.data.find((m: any) => m.name === 'accounts_engaged');

      if (reachMetric && reachMetric.values) {
        result.history = reachMetric.values.map((v: any, index: number) => ({
          date: v.end_time,
          reach: v.value || 0,
          impressions: 0,
          engagement: engagementMetric?.values?.[index]?.value || 0
        }));
      }
    }

    return result;
  } catch (error: any) {
    console.error("[Instagram] Account insights error:", error);
    return {
      reach: 0,
      engagement: 0,
      followers: 0,
      profileViews: 0,
      history: [],
      error: error.message
    };
  }
}

/**
 * Get Instagram Media (Posts)
 * Returns recent media from the account
 */
export async function getInstagramMedia(
  accessToken: string,
  instagramUserId: string,
  limit: number = 20
): Promise<any[]> {
  try {
    const url = `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${instagramUserId}/media?fields=id,caption,media_type,media_url,thumbnail_url,timestamp,like_count,comments_count&limit=${limit}&access_token=${accessToken}`;

    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error("[Instagram] Media error:", data);
      throw new Error(data.error?.message || "Failed to get media");
    }

    return data.data || [];
  } catch (error: any) {
    console.error("[Instagram] Media error:", error);
    throw error;
  }
}

/**
 * Get Instagram Media Insights
 * Returns metrics for a specific media item
 */
export async function getInstagramMediaInsights(
  accessToken: string,
  mediaId: string,
  mediaType?: string
): Promise<any> {
  try {
    let metrics = ['likes', 'comments', 'saved'];
    
    if (mediaType === 'REELS') {
      metrics = [...metrics, 'reach', 'shares', 'plays'];
    } else if (mediaType === 'STORY') {
      metrics = ['reach', 'replies'];
    } else {
      metrics = [...metrics, 'impressions', 'reach', 'shares'];
    }

    const url = `${INSTAGRAM.GRAPH_BASE_URL}/${INSTAGRAM.GRAPH_API_VERSION}/${mediaId}/insights?metric=${metrics.join(',')}&access_token=${accessToken}`;
    
    console.log(`[Instagram] Fetching insights for media ${mediaId} (${mediaType || 'unknown type'})`);

    const response = await fetch(url);
    const data: any = await response.json();

    if (!response.ok) {
      console.error(`[Instagram] Media insights error for ${mediaId}:`, data);
      return {
        impressions: 0,
        reach: 0,
        likes: 0,
        comments: 0,
        saved: 0,
        shares: 0,
        engagement: 0,
        error: data.error?.message
      };
    }
    
    console.log(`[Instagram] Insights for ${mediaId}:`, data);

    const result: any = {
      impressions: 0,
      reach: 0,
      likes: 0,
      comments: 0,
      saved: 0,
      shares: 0,
      engagement: 0
    };

    if (data.data) {
      data.data.forEach((metric: any) => {
        const values = metric.values || [];
        const value = values[0]?.value || 0;
        
        switch (metric.name) {
          case 'impressions':
            result.impressions = value;
            break;
          case 'reach':
            result.reach = value;
            break;
          case 'likes':
            result.likes = value;
            break;
          case 'comments':
            result.comments = value;
            break;
          case 'saved':
            result.saved = value;
            break;
          case 'shares':
            result.shares = value;
            break;
        }
      });
      
      result.engagement = result.likes + result.comments + result.shares + result.saved;
    }

    return result;
  } catch (error: any) {
    console.error("[Instagram] Media insights error:", error);
    return null;
  }
}
