import schedule from "node-schedule";
import { Post } from "../models/Post.js";
import { User } from "../models/User.js";

const scheduledJobs = new Map<string, schedule.Job>();

let publishCallback: ((postId: string) => Promise<void>) | null = null;

export function setPublishCallback(callback: (postId: string) => Promise<void>): void {
  publishCallback = callback;
}

export function schedulePost(postId: string, scheduledTime: Date): void {
  cancelScheduledJob(postId);

  const job = schedule.scheduleJob(scheduledTime, async () => {
    console.log(`[Scheduler] Executing scheduled post: ${postId}`);
    try {
      if (publishCallback) {
        await publishCallback(postId);
      } else {
        console.error(`[Scheduler] No publish callback set for post ${postId}`);
      }
    } catch (error) {
      console.error(`[Scheduler] Failed to publish post ${postId}:`, error);
    }
    scheduledJobs.delete(postId);
  });

  scheduledJobs.set(postId, job);
  console.log(`[Scheduler] Post ${postId} scheduled for ${scheduledTime.toISOString()}`);
}

export function cancelScheduledJob(postId: string): boolean {
  const job = scheduledJobs.get(postId);
  if (job) {
    job.cancel();
    scheduledJobs.delete(postId);
    console.log(`[Scheduler] Cancelled scheduled job for post ${postId}`);
    return true;
  }
  return false;
}

export async function initializeScheduler(): Promise<void> {
  console.log("[Scheduler] Initializing...");

  try {
    const scheduledPosts = await Post.find({
      status: "scheduled",
      scheduledTime: { $gt: new Date() }
    });

    console.log(`[Scheduler] Found ${scheduledPosts.length} scheduled posts to restore`);

    for (const post of scheduledPosts) {
      if (post.scheduledTime) {
        schedulePost(post._id.toString(), post.scheduledTime);
      }
    }

    const overduePosts = await Post.find({
      status: "scheduled",
      scheduledTime: { $lte: new Date() }
    });

    if (overduePosts.length > 0) {
      console.log(`[Scheduler] Found ${overduePosts.length} overdue posts, will be handled by scheduled jobs`);
    }

    // Initialize daily subscription check job
    console.log("[Scheduler] Setting up daily subscription expiry check at 00:00 AM...");
    schedule.scheduleJob('0 0 * * *', async () => {
      console.log("[Scheduler] Running daily subscription expiry check...");
      try {
        const expiredUsers = await User.find({
          planType: 'Premium',
          subscriptionExpiryDate: { $lte: new Date() }
        });

        for (const user of expiredUsers) {
          user.planType = 'Free';
          user.subscriptionStatus = 'Expired';
          await user.save();
          console.log(`[Scheduler] Downgraded user ${user._id} to Free plan due to expiry.`);
        }
      } catch (err) {
        console.error("[Scheduler] Failed running daily subscription check:", err);
      }
    });

    console.log("[Scheduler] Initialization complete");
  } catch (error) {
    console.error("[Scheduler] Initialization failed:", error);
  }
}

export function getActiveJobs(): string[] {
  return Array.from(scheduledJobs.keys());
}
