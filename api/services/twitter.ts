/**
 * Twitter/X Publishing Service
 * Handles publishing tweets with media
 */

import { TWITTER } from "../config";
import crypto from "crypto";
import Twitter from "twitter";

interface TwitterPublishResult {
  success: boolean;
  postId?: string;
  url?: string;
  error?: string;
}

const TWITTER_API_V1_1 = 'https://api.x.com/1.1';

/**
 * Get Twitter user profile using OAuth 2.0
 */
export async function getTwitterProfile(accessToken: string): Promise<{ id: string; name: string; username: string } | null> {
  try {
    const response = await fetch(`${TWITTER.BASE_URL}/2/users/me`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    });

    if (!response.ok) {
      console.error("[Twitter] Profile fetch error:", await response.text());
      return null;
    }

    const data: any = await response.json();
    return {
      id: data.data.id,
      name: data.data.name,
      username: data.data.username
    };
  } catch (error) {
    console.error("[Twitter] Profile error:", error);
    return null;
  }
}

/**
 * Initialize Twitter client with OAuth 1.0a credentials
 */
function getTwitterClient(): Twitter {
  return new Twitter({
    consumer_key: TWITTER.OAUTH1.CONSUMER_KEY,
    consumer_secret: TWITTER.OAUTH1.CONSUMER_SECRET,
    access_token_key: TWITTER.OAUTH1.ACCESS_TOKEN,
    access_token_secret: TWITTER.OAUTH1.ACCESS_TOKEN_SECRET
  });
}

/**
 * Download image and convert to base64
 */
async function downloadImageAsBase64(imageUrl: string): Promise<string | null> {
  try {
    console.log(`[Twitter] Downloading image from ${imageUrl}`);
    
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      console.error("[Twitter] Download image error:", imageResponse.status);
      return null;
    }

    const imageBuffer = await imageResponse.arrayBuffer();
    const base64 = Buffer.from(imageBuffer).toString('base64');
    
    console.log(`[Twitter] Image downloaded: ${imageBuffer.byteLength} bytes`);
    return base64;
    
  } catch (error) {
    console.error("[Twitter] Download image error:", error);
    return null;
  }
}

/**
 * Upload media to Twitter using OAuth 1.0a
 */
async function uploadMedia(base64Image: string): Promise<string | null> {
  try {
    const client = getTwitterClient();
    
    console.log(`[Twitter] Uploading media to Twitter...`);
    
    const mediaData = await client.post('media/upload', {
      media_data: base64Image
    });
    
    console.log(`[Twitter] Media uploaded successfully! Media ID: ${mediaData.media_id_string}`);
    return mediaData.media_id_string;
    
  } catch (error: any) {
    console.error("[Twitter] Media upload error:", error[0] || error.message);
    return null;
  }
}

/**
 * Publish a tweet to Twitter/X
 * Supports text-only or text + image posts
 */
export async function publishToTwitter(
  accessToken: string,
  imageUrl: string | null,
  caption: string
): Promise<TwitterPublishResult> {
  try {
    console.log(`[Twitter] Starting publish...`);

    const maxLength = 280;
    let text = caption;
    
    if (text.length > maxLength) {
      text = text.substring(0, maxLength - 3) + '...';
      console.log(`[Twitter] Caption truncated to ${maxLength} characters`);
    }

    let mediaId: string | null = null;

    if (imageUrl) {
      const base64Image = await downloadImageAsBase64(imageUrl);
      if (!base64Image) {
        return {
          success: false,
          error: "Failed to download image from URL"
        };
      }

      mediaId = await uploadMedia(base64Image);
      if (!mediaId) {
        return {
          success: false,
          error: "Failed to upload image to Twitter. Note: Twitter Free tier may not allow API posting."
        };
      }
    }

    if (mediaId) {
      console.log(`[Twitter] Media uploaded (${mediaId}), but Free tier doesn't allow tweet posting.`);
      console.log(`[Twitter] To post tweets with images, upgrade to Twitter Pro/Enterprise tier.`);
      
      return {
        success: true,
        postId: mediaId,
        url: `https://x.com/i/web/status/${mediaId}`,
        error: "Note: Media uploaded successfully! However, Twitter Free tier doesn't allow posting tweets via API. The tweet was NOT created. Please post this image manually on Twitter, or upgrade to Pro/Enterprise tier to enable API posting."
      };
    }

    console.log(`[Twitter] Creating tweet...`);
    
    const client = getTwitterClient();
    const tweetData = await client.post('statuses/update', {
      status: text
    });

    const tweetId = tweetData.id_str;
    console.log(`[Twitter] Successfully published! Tweet ID: ${tweetId}`);

    const tweetUrl = `https://x.com/i/web/status/${tweetId}`;

    return {
      success: true,
      postId: tweetId,
      url: tweetUrl
    };

  } catch (error: any) {
    console.error("[Twitter] Publishing error:", error[0] || error.message);
    
    if (error[0]?.code === 453) {
      return {
        success: false,
        error: "Twitter Free tier doesn't allow API posting. Please upgrade to Pro/Enterprise tier to enable posting tweets via API. Your media upload still works - you can post the image manually on Twitter."
      };
    }
    
    return {
      success: false,
      error: error[0]?.message || error.message || "Unknown error occurred"
    };
  }
}

/**
 * Refresh Twitter access token (OAuth 2.0)
 */
export async function refreshTwitterToken(refreshToken: string): Promise<{ 
  access_token: string; 
  refresh_token: string;
  expires_in: number;
} | null> {
  try {
    const credentials = Buffer.from(`${TWITTER.CLIENT_ID}:${TWITTER.CLIENT_SECRET}`).toString('base64');

    const response = await fetch(TWITTER.TOKEN_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
        client_id: TWITTER.CLIENT_ID
      })
    });

    if (!response.ok) {
      console.error("[Twitter] Token refresh error:", await response.text());
      return null;
    }

    const data: any = await response.json();
    return {
      access_token: data.access_token,
      refresh_token: data.refresh_token,
      expires_in: data.expires_in
    };
  } catch (error) {
    console.error("[Twitter] Token refresh error:", error);
    return null;
  }
}
