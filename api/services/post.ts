import { Post } from "../models/Post";
import { User } from "../models/User";
import { publishToInstagram, validateImageUrl } from "./instagram";
import { publishToPage } from "./facebook";
import { publishToLinkedIn } from "./linkedin";
import { publishToTwitter } from "./twitter";
import { schedulePost, cancelScheduledJob, setPublishCallback } from "./scheduler";
import { createTrendingPost } from "./trending";

setPublishCallback(async (postId: string) => {
  try {
    await publishPost(postId);
  } catch (error) {
    console.error(`[Post Service] Scheduled publish failed for ${postId}:`, error);
  }
});

interface CreatePostData {
  content: string;
  mediaUrls: string[];
  platforms: ("instagram" | "facebook" | "linkedin" | "twitter")[];
  scheduledTime?: Date | null;
}

export async function createPost(userId: string, data: CreatePostData) {
  const { content, mediaUrls, platforms, scheduledTime } = data;

  if (!platforms || platforms.length === 0) {
    throw new Error("At least one platform must be selected");
  }

  if (!mediaUrls || mediaUrls.length === 0) {
    throw new Error("At least one media URL is required");
  }

  if (platforms.includes("instagram") && mediaUrls[0]) {
    console.log(`[Post Service] Validating image URL for Instagram: ${mediaUrls[0]}`);
    const validation = await validateImageUrl(mediaUrls[0]);
    
    if (!validation.valid) {
      throw new Error(`Instagram image validation failed: ${validation.error}. Make sure the URL is publicly accessible and returns a valid image.`);
    }
  }

  const isScheduled = scheduledTime && new Date(scheduledTime) > new Date();
  const status = isScheduled ? "scheduled" : "pending";

  const post = new Post({
    userId,
    content,
    mediaUrls,
    platforms,
    scheduledTime: isScheduled ? scheduledTime : null,
    status,
    results: {}
  });

  await post.save();
  console.log(`[Post Service] Created post ${post._id} with status: ${status}`);

  if (isScheduled && scheduledTime) {
    schedulePost(post._id.toString(), new Date(scheduledTime));
  } else {
    await publishPost(post._id.toString());
  }

  return post;
}

export async function publishPost(postId: string) {
  const post = await Post.findById(postId);
  
  if (!post) {
    throw new Error("Post not found");
  }

  if (post.status === "published") {
    console.log(`[Post Service] Post ${postId} is already published`);
    return post;
  }

  post.status = "publishing";
  await post.save();

  const user = await User.findById(post.userId);
  
  if (!user) {
    post.status = "failed";
    await post.save();
    throw new Error("User not found");
  }

  const results: any = {};
  let successCount = 0;
  let failCount = 0;

  for (const platform of post.platforms) {
    console.log(`[Post Service] Publishing to ${platform}...`);
    
    try {
      let result;
      const firstImageUrl = post.mediaUrls[0] || "";
      const caption = post.content;

      switch (platform) {
        case "instagram":
          if (!user.instagramAccessToken || !user.instagramUserId) {
            result = {
              success: false,
              error: "Instagram not connected"
            };
          } else {
            result = await publishToInstagram(
              user.instagramAccessToken!,
              user.instagramUserId!,
              firstImageUrl,
              caption
            );
          }
          break;

        case "facebook":
          if (!user.facebookAccessToken || !user.facebookPageId) {
            result = {
              success: false,
              error: "Facebook not connected or no page selected"
            };
          } else {
            result = await publishToPage(
              user.facebookAccessToken,
              user.facebookPageId,
              caption,
              firstImageUrl
            );
          }
          break;

        case "linkedin":
          if (!user.linkedinAccessToken || !user.linkedinUserId) {
            result = {
              success: false,
              error: "LinkedIn not connected"
            };
          } else {
            result = await publishToLinkedIn(
              user.linkedinAccessToken,
              user.linkedinUserId,
              firstImageUrl || null,
              caption,
              user.linkedinCompanyId || null
            );
          }
          break;

        case "twitter":
          if (!user.twitterAccessToken) {
            result = {
              success: false,
              error: "Twitter not connected"
            };
          } else {
            result = await publishToTwitter(
              user.twitterAccessToken,
              firstImageUrl || null,
              caption
            );
          }
          break;

        default:
          result = {
            success: false,
            error: `Unknown platform: ${platform}`
          };
      }

      results[platform] = result;

      if (result.success) {
        successCount++;
        console.log(`[Post Service] ${platform} publish successful`);
      } else {
        failCount++;
        console.log(`[Post Service] ${platform} publish failed: ${result.error}`);
      }

    } catch (error: any) {
      results[platform] = {
        success: false,
        error: error.message || "Unknown error"
      };
      failCount++;
      console.error(`[Post Service] ${platform} publish error:`, error);
    }
  }

  post.results = results;
  post.publishedAt = new Date();

  if (successCount === post.platforms.length) {
    post.status = "published";
  } else if (successCount > 0) {
    post.status = "partially_failed";
  } else {
    post.status = "failed";
  }

  await post.save();
  console.log(`[Post Service] Post ${postId} publishing complete. Status: ${post.status}`);

  if (post.status === "published" || post.status === "partially_failed") {
    try {
      await createTrendingPost(
        postId,
        post.userId.toString(),
        post.content,
        post.mediaUrls,
        post.platforms
      );
    } catch (trendingError) {
      console.error(`[Post Service] Failed to create trending entry for ${postId}:`, trendingError);
    }
  }

  return post;
}

export async function cancelScheduledPost(postId: string, userId: string) {
  const post = await Post.findOne({ _id: postId, userId });

  if (!post) {
    throw new Error("Post not found");
  }

  if (post.status !== "scheduled") {
    throw new Error("Post is not scheduled");
  }

  cancelScheduledJob(postId);

  await Post.findByIdAndDelete(postId);

  console.log(`[Post Service] Cancelled and deleted post ${postId}`);
  return { message: "Post cancelled and deleted" };
}

export async function retryPost(postId: string, userId: string) {
  const post = await Post.findOne({ _id: postId, userId });

  if (!post) {
    throw new Error("Post not found");
  }

  if (post.status !== "failed" && post.status !== "partially_failed") {
    throw new Error("Post cannot be retried. Status: " + post.status);
  }

  post.status = "publishing";
  await post.save();

  return await publishPost(postId);
}

export async function getUserPosts(userId: string, options: { limit?: number; skip?: number; platform?: string } = {}) {
  const { limit = 20, skip = 0, platform } = options;

  const query: any = { userId };
  if (platform) {
    query.platforms = { $in: [platform] };
  }

  const posts = await Post.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .lean();

  const total = await Post.countDocuments(query);

  return { posts, total };
}

export async function getPostById(postId: string, userId: string) {
  const post = await Post.findOne({ _id: postId, userId });
  
  if (!post) {
    throw new Error("Post not found");
  }

  return post;
}
