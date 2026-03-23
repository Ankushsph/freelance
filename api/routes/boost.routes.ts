import express from 'express';
import Boost from '../models/Boost';
import Post from '../models/Post';
import { verifyToken, AuthRequest } from '../middleware/auth';
import { requirePremium } from '../middleware/premium';

const router = express.Router();

// CREATE boost campaign
router.post('/', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { postId, platform, budget, duration, targetAudience } = req.body;

    // Validate post exists and belongs to user
    const post = await Post.findOne({ _id: postId, userId });
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Validate budget
    if (!budget || budget < 10) {
      return res.status(400).json({ message: 'Minimum budget is $10' });
    }

    // Calculate dates
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + duration);

    // Create boost
    const boost = new Boost({
      userId,
      postId,
      platform,
      budget,
      duration,
      targetAudience: targetAudience || {},
      status: 'pending',
      startDate,
      endDate,
      stats: {
        impressions: 0,
        clicks: 0,
        spent: 0,
        reach: 0,
      },
    });

    await boost.save();

    // In production, this would integrate with platform APIs
    // For now, simulate activation
    setTimeout(async () => {
      boost.status = 'active';
      await boost.save();
    }, 2000);

    res.status(201).json({
      message: 'Boost campaign created successfully',
      boost,
    });
  } catch (error: any) {
    console.error('Error creating boost:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET user's boost campaigns
router.get('/', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { status, limit = 20, skip = 0 } = req.query;

    const query: any = { userId };
    if (status) {
      query.status = status;
    }

    const boosts = await Boost.find(query)
      .populate('postId', 'content mediaUrl platform')
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip(Number(skip));

    const total = await Boost.countDocuments(query);

    res.json({
      boosts,
      total,
      hasMore: total > Number(skip) + boosts.length,
    });
  } catch (error: any) {
    console.error('Error fetching boosts:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET boost campaign stats
router.get('/:id/stats', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const boost = await Boost.findOne({ _id: id, userId });
    if (!boost) {
      return res.status(404).json({ message: 'Boost campaign not found' });
    }

    // In production, fetch real-time stats from platform APIs
    // For now, simulate some growth
    if (boost.status === 'active') {
      const daysPassed = Math.floor(
        (Date.now() - boost.startDate.getTime()) / (1000 * 60 * 60 * 24)
      );
      const dailyBudget = boost.budget / boost.duration;
      
      boost.stats.spent = Math.min(dailyBudget * daysPassed, boost.budget);
      boost.stats.impressions = Math.floor(boost.stats.spent * 100);
      boost.stats.clicks = Math.floor(boost.stats.impressions * 0.02);
      boost.stats.reach = Math.floor(boost.stats.impressions * 0.7);
      
      await boost.save();
    }

    res.json({
      boost,
      performance: {
        ctr: boost.stats.impressions > 0 
          ? ((boost.stats.clicks / boost.stats.impressions) * 100).toFixed(2) + '%'
          : '0%',
        cpc: boost.stats.clicks > 0
          ? (boost.stats.spent / boost.stats.clicks).toFixed(2)
          : '0',
        cpm: boost.stats.impressions > 0
          ? ((boost.stats.spent / boost.stats.impressions) * 1000).toFixed(2)
          : '0',
      },
    });
  } catch (error: any) {
    console.error('Error fetching boost stats:', error);
    res.status(500).json({ message: error.message });
  }
});

// UPDATE boost campaign (pause/resume)
router.put('/:id', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;
    const { status, budget, targetAudience } = req.body;

    const boost = await Boost.findOne({ _id: id, userId });
    if (!boost) {
      return res.status(404).json({ message: 'Boost campaign not found' });
    }

    // Update allowed fields
    if (status && ['active', 'paused'].includes(status)) {
      boost.status = status;
    }
    if (budget && budget >= 10) {
      boost.budget = budget;
    }
    if (targetAudience) {
      boost.targetAudience = { ...boost.targetAudience, ...targetAudience };
    }

    await boost.save();

    res.json({
      message: 'Boost campaign updated successfully',
      boost,
    });
  } catch (error: any) {
    console.error('Error updating boost:', error);
    res.status(500).json({ message: error.message });
  }
});

// DELETE/CANCEL boost campaign
router.delete('/:id', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const boost = await Boost.findOne({ _id: id, userId });
    if (!boost) {
      return res.status(404).json({ message: 'Boost campaign not found' });
    }

    // Can only cancel if not completed
    if (boost.status === 'completed') {
      return res.status(400).json({ message: 'Cannot cancel completed campaign' });
    }

    boost.status = 'cancelled';
    await boost.save();

    res.json({
      message: 'Boost campaign cancelled successfully',
      refund: boost.budget - boost.stats.spent,
    });
  } catch (error: any) {
    console.error('Error cancelling boost:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET boost summary/overview
router.get('/summary', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;

    const [active, total, totalSpent] = await Promise.all([
      Boost.countDocuments({ userId, status: 'active' }),
      Boost.countDocuments({ userId }),
      Boost.aggregate([
        { $match: { userId: userId } },
        { $group: { _id: null, total: { $sum: '$stats.spent' } } },
      ]),
    ]);

    const recentBoosts = await Boost.find({ userId })
      .populate('postId', 'content mediaUrl')
      .sort({ createdAt: -1 })
      .limit(5);

    res.json({
      summary: {
        activeCampaigns: active,
        totalCampaigns: total,
        totalSpent: totalSpent[0]?.total || 0,
      },
      recentBoosts,
    });
  } catch (error: any) {
    console.error('Error fetching boost summary:', error);
    res.status(500).json({ message: error.message });
  }
});

export default router;
