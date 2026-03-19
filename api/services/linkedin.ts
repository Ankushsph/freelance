/**
 * LinkedIn Publishing Service
 * Handles publishing to LinkedIn personal profiles and company pages
 */

import { LINKEDIN } from "../config";

interface LinkedInPublishResult {
  success: boolean;
  postId?: string;
  url?: string;
  error?: string;
}

interface LinkedInCompany {
  id: string;
  name: string;
  vanityName?: string;
}

/**
 * Get LinkedIn user profile
 * Uses OpenID Connect userinfo endpoint (requires openid scope)
 * Note: LinkedIn deprecated r_basicprofile and r_liteprofile scopes
 */
export async function getLinkedInProfile(accessToken: string): Promise<{ id: string; name: string; email?: string } | null> {
  try {
    const response = await fetch(`${LINKEDIN.BASE_URL}/v2/userinfo`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    });

    if (!response.ok) {
      console.error("[LinkedIn] Profile fetch error:", await response.text());
      return null;
    }

    const data: any = await response.json();
    return {
      id: data.sub,
      name: data.name || `${data.given_name || ''} ${data.family_name || ''}`.trim(),
      email: data.email
    };
  } catch (error) {
    console.error("[LinkedIn] Profile error:", error);
    return null;
  }
}

/**
 * Register image upload to get upload URL and asset URN
 */
async function registerImageUpload(accessToken: string, ownerUrn: string): Promise<{ uploadUrl: string; asset: string } | null> {
  try {
    const response = await fetch(`${LINKEDIN.BASE_URL}/v2/assets?action=registerUpload`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'Linkedin-Version': LINKEDIN.API_VERSION,
        'X-Restli-Protocol-Version': '2.0.0'
      },
      body: JSON.stringify({
        registerUploadRequest: {
          recipes: ['urn:li:digitalmediaRecipe:feedshare-image'],
          owner: ownerUrn,
          serviceRelationships: [{
            relationshipType: 'OWNER',
            identifier: 'urn:li:userGeneratedContent'
          }]
        }
      })
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("[LinkedIn] Register upload error:", error);
      return null;
    }

    const data: any = await response.json();
    return {
      uploadUrl: data.value.uploadMechanism['com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest'].uploadUrl,
      asset: data.value.asset
    };
  } catch (error) {
    console.error("[LinkedIn] Register upload error:", error);
    return null;
  }
}

/**
 * Upload image binary to LinkedIn
 */
async function uploadImageBinary(uploadUrl: string, imageBuffer: Buffer): Promise<boolean> {
  try {
    const response = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': 'image/jpeg',
      },
      body: imageBuffer
    });

    return response.ok;
  } catch (error) {
    console.error("[LinkedIn] Image upload error:", error);
    return false;
  }
}

/**
 * Download image from URL and return as buffer
 */
async function downloadImage(imageUrl: string): Promise<Buffer | null> {
  try {
    const response = await fetch(imageUrl);
    if (!response.ok) {
      console.error("[LinkedIn] Download image error:", response.status);
      return null;
    }
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  } catch (error) {
    console.error("[LinkedIn] Download image error:", error);
    return null;
  }
}

/**
 * Publish a post to LinkedIn
 * Supports text-only or text + image posts
 */
export async function publishToLinkedIn(
  accessToken: string,
  userId: string,
  imageUrl: string | null,
  caption: string,
  companyId?: string | null
): Promise<LinkedInPublishResult> {
  try {
    console.log(`[LinkedIn] Starting publish for user ${userId}`);

    const authorUrn = companyId ? `urn:li:organization:${companyId}` : `urn:li:person:${userId}`;
    console.log(`[LinkedIn] Publishing as: ${authorUrn}`);

    let mediaAsset: string | null = null;

    if (imageUrl) {
      console.log(`[LinkedIn] Uploading image...`);
      
      const imageBuffer = await downloadImage(imageUrl);
      if (!imageBuffer) {
        return {
          success: false,
          error: "Failed to download image"
        };
      }

      const uploadInfo = await registerImageUpload(accessToken, authorUrn);
      if (!uploadInfo) {
        return {
          success: false,
          error: "Failed to register image upload"
        };
      }

      const uploaded = await uploadImageBinary(uploadInfo.uploadUrl, imageBuffer);
      if (!uploaded) {
        return {
          success: false,
          error: "Failed to upload image"
        };
      }

      mediaAsset = uploadInfo.asset;
      console.log(`[LinkedIn] Image uploaded: ${mediaAsset}`);
    }

    const postBody: any = {
      author: authorUrn,
      commentary: caption,
      visibility: "PUBLIC",
      distribution: {
        feedDistribution: "MAIN_FEED",
        targetEntities: [],
        thirdPartyDistributionChannels: []
      },
      lifecycleState: "PUBLISHED"
    };

    if (mediaAsset) {
      postBody.content = {
        media: {
          id: mediaAsset
        }
      };
    }

    console.log(`[LinkedIn] Creating post...`);
    const response = await fetch(`${LINKEDIN.BASE_URL}/rest/posts`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'Linkedin-Version': LINKEDIN.API_VERSION,
        'X-Restli-Protocol-Version': '2.0.0'
      },
      body: JSON.stringify(postBody)
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error("[LinkedIn] Post creation error:", errorData);
      return {
        success: false,
        error: `LinkedIn API error: ${response.status} - ${errorData}`
      };
    }

    const postId = response.headers.get('x-restli-id');
    console.log(`[LinkedIn] Successfully published! Post ID: ${postId}`);

    const postUrl = postId ? `https://linkedin.com/feed/update/${postId}` : undefined;

    return {
      success: true,
      postId: postId || 'unknown',
      url: postUrl
    };

  } catch (error: any) {
    console.error("[LinkedIn] Publishing error:", error);
    return {
      success: false,
      error: error.message || "Unknown error occurred"
    };
  }
}

/**
 * Get user's LinkedIn companies/pages
 */
export async function getUserCompanies(accessToken: string): Promise<LinkedInCompany[]> {
  try {
    const response = await fetch(`${LINKEDIN.BASE_URL}/v2/organizationalEntityAcls?q=roleAssignee`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Linkedin-Version': LINKEDIN.API_VERSION,
        'X-Restli-Protocol-Version': '2.0.0'
      }
    });

    if (!response.ok) {
      console.error("[LinkedIn] Get companies error:", await response.text());
      return [];
    }

    const data: any = await response.json();
    const companies: LinkedInCompany[] = [];

    if (data.elements) {
      for (const element of data.elements) {
        const orgUrn = element.organizationalTarget;
        const orgId = orgUrn.split(':').pop();
        
        const orgResponse = await fetch(`${LINKEDIN.BASE_URL}/v2/organizations/${orgId}`, {
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Linkedin-Version': LINKEDIN.API_VERSION,
            'X-Restli-Protocol-Version': '2.0.0'
          }
        });

        if (orgResponse.ok) {
          const orgData: any = await orgResponse.json();
          companies.push({
            id: orgId,
            name: orgData.localizedName || orgData.name,
            vanityName: orgData.vanityName
          });
        }
      }
    }

    return companies;
  } catch (error) {
    console.error("[LinkedIn] Get companies error:", error);
    return [];
  }
}

/**
 * Refresh LinkedIn access token
 * Note: LinkedIn tokens expire in 60 days, not 2 hours like Twitter
 */
export async function refreshLinkedInToken(refreshToken: string): Promise<{ access_token: string; expires_in: number } | null> {
  try {
    const response = await fetch(LINKEDIN.TOKEN_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
        client_id: LINKEDIN.CLIENT_ID,
        client_secret: LINKEDIN.CLIENT_SECRET
      })
    });

    if (!response.ok) {
      console.error("[LinkedIn] Token refresh error:", await response.text());
      return null;
    }

    const data: any = await response.json();
    return {
      access_token: data.access_token,
      expires_in: data.expires_in
    };
  } catch (error) {
    console.error("[LinkedIn] Token refresh error:", error);
    return null;
  }
}
