import { Router } from "express";
import { User } from "../models/User";
import { Post } from "../models/Post";
import { Trend } from "../models/Trend";
import { Announcement } from "../models/Announcement";
import { Ticket } from "../models/Ticket";

const router = Router();

// Minimal middleware to protect routes. Since there isn't a dedicated admin auth system yet, 
// we'll allow requests to pass, but in production, we would verify a JWT and check {role: 'admin'}
const isAdmin = (req: any, res: any, next: any) => {
  next(); 
};

router.use(isAdmin);

// --- 1. Dashboard Stats ---
router.get("/stats", async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    // In a real app, 'active' might mean logged in last 30 days. We'll approximate.
    const activeUsers = Math.floor(totalUsers * 0.7) || 0; 
    const totalPosts = await Post.countDocuments();
    const scheduledPosts = await Post.countDocuments({ status: 'scheduled' });
    const successfulPosts = await Post.countDocuments({ status: 'published' });
    const failedPosts = await Post.countDocuments({ status: 'failed' });

    // Platform usage distribution
    const users = await User.find();
    let initialPlatformData = { Instagram: 0, LinkedIn: 0, Facebook: 0, Twitter: 0 };
    users.forEach(u => {
      if (u.instagramUserId) initialPlatformData.Instagram++;
      if (u.linkedinOAuthState) initialPlatformData.LinkedIn++;
      if (u.facebookOAuthState) initialPlatformData.Facebook++;
      if (u.twitterUserId) initialPlatformData.Twitter++;
    });

    const platformData = Object.entries(initialPlatformData).map(([name, value]) => ({ 
      name, 
      value,
      color: name === 'Instagram' ? '#E1306C' : name === 'LinkedIn' ? '#0A66C2' : name === 'Facebook' ? '#1877F2' : '#000000'
    })).filter(p => p.value > 0);

    // If empty DB, return some defaults for pie chart so it's not empty
    const finalPlatformData = platformData.length > 0 ? platformData : [
      { name: 'Instagram', value: 1, color: '#E1306C' }
    ];

    return res.json({
      success: true,
      data: {
        totalUsers,
        activeUsers,
        totalPosts,
        scheduledPosts,
        successfulPosts,
        failedPosts,
        platformData: finalPlatformData
      }
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// --- 2. Users Management ---
router.get("/users", async (req, res) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });
    
    // Transform data for frontend table
    const formattedUsers = users.map(user => {
      const platforms = [];
      if (user.instagramUserId) platforms.push('Instagram');
      if (user.facebookOAuthState) platforms.push('Facebook');
      if (user.linkedinOAuthState) platforms.push('LinkedIn');
      if (user.twitterUserId) platforms.push('X');

      return {
        id: user._id,
        name: user.name || 'Unknown User',
        email: user.email,
        platforms,
        plan: user.planType || 'Free',
        status: user.subscriptionStatus === 'Active' ? 'Active' : 'Expired/None',
      };
    });

    return res.json({ success: true, data: formattedUsers });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// --- 3. Trends Management ---
router.get("/trends", async (req, res) => {
  try {
    const trends = await Trend.find().sort({ volume: -1 });
    return res.json({ success: true, data: trends });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

router.post("/trends", async (req, res) => {
  try {
    const trend = await Trend.create(req.body);
    return res.json({ success: true, data: trend });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

// --- 4. Announcements ---
router.get("/notifications", async (req, res) => {
  try {
    const announcements = await Announcement.find().sort({ createdAt: -1 });
    return res.json({ success: true, data: announcements });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

router.post("/notifications", async (req, res) => {
  try {
    const item = await Announcement.create(req.body);
    return res.json({ success: true, data: item });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

// --- 5. Support Tickets ---
router.get("/tickets", async (req, res) => {
  try {
    const tickets = await Ticket.find().populate('user', 'name email').sort({ createdAt: -1 });
    
    const formattedTickets = tickets.map((t: any) => ({
      id: t._id,
      user: t.user ? t.user.name : 'Unknown User',
      issue: t.issue,
      priority: t.priority,
      status: t.status,
      time: t.createdAt
    }));

    return res.json({ success: true, data: formattedTickets });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

// --- 6. Revenue Data ---
router.get("/revenue", async (req, res) => {
  try {
    // In a full system this would query a Stripe or Payment collection.
    // For now, since Subscriptions are deferred, we simulate the MRR stats based on the User collection's active plans.
    const users = await User.find();
    
    let activePaidSubs = 0;
    let mrr = 0;
    
    users.forEach(userDocs => {
      const u = userDocs as any;
      if (u.planType === 'Premium' && u.subscriptionStatus === 'Active') {
        activePaidSubs++;
        mrr += 999;
      }
    });

    const totalRevenueYtd = mrr * new Date().getMonth(); // Naive approximation for YTD

    return res.json({ 
      success: true, 
      data: {
        totalRevenueYtd: Math.round(totalRevenueYtd),
        mrr: Math.round(mrr),
        activePaidSubs
      } 
    });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

// --- 7. Settings ---
router.get("/settings", async (req, res) => {
  try {
    // This could be fetched from a DB Config collection, returning mocked env structure.
    return res.json({ 
      success: true, 
      data: {
        maintenanceMode: false,
        platformName: 'KonnectMedia',
        require2FA: true,
        openRouterKeyConfigured: !!process.env.OPENROUTER_API_KEY,
      } 
    });
  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

// --- 8. Subscriptions Management ---
router.get("/subscriptions", async (req, res) => {
  try {
    const users = await User.find();
    
    let totalFree = 0;
    let totalPremium = 0;
    let expiredPremium = 0;
    let expiringSoon = 0; // Less than 7 days
    
    const now = new Date();
    const nextWeek = new Date();
    nextWeek.setDate(now.getDate() + 7);

    const recentSubscribers = [];

    for (const u of users) {
      if (u.planType === 'Premium') {
        totalPremium++;
        
        if (u.subscriptionStatus === 'Expired') {
          expiredPremium++;
        }
        
        if (u.subscriptionExpiryDate) {
          const expiry = new Date(u.subscriptionExpiryDate);
          if (expiry > now && expiry <= nextWeek) {
            expiringSoon++;
          }
        }
        
        if (u.subscriptionStartDate) {
          recentSubscribers.push({
            id: u._id,
            name: u.name,
            email: u.email,
            startDate: u.subscriptionStartDate,
            expiryDate: u.subscriptionExpiryDate,
            status: u.subscriptionStatus
          });
        }
      } else {
        totalFree++;
      }
    }
    
    // Sort recent subscribers by start date
    recentSubscribers.sort((a, b) => new Date(b.startDate).getTime() - new Date(a.startDate).getTime());

    return res.json({
      success: true,
      data: {
        totalFree,
        totalPremium,
        expiredPremium,
        expiringSoon,
        recentSubscribers: recentSubscribers.slice(0, 50)
      }
    });

  } catch (error) {
    return res.status(500).json({ success: false });
  }
});

export default router;
