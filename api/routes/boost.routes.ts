import express, { type Response } from 'express';
import Boost from '../models/Boost.js';
import { Post } from '../models/Post.js';
import { verifyToken, type AuthRequest } from '../middleware/auth.js';
import { requirePremium } from '../middleware/premium.js';
import { transporter } from '../utils/mailer.js';
import { boostEmailTemplate } from '../utils/boostTemplate.js';

const router = express.Router();

// SEND boost consultation request (book a slot with expert)
router.post('/send', verifyToken, requirePremium, async (req: AuthRequest, res) => {
  try {
    const { userId, name, contact, timeSlot, message } = req.body;

    // Validate required fields
    if (!name || !contact || !timeSlot) {
      return res.status(400).json({ 
        success: false,
        message: 'Name, contact, and time slot are required' 
      });
    }

    // Validate time slot is in the future
    const slotDate = new Date(timeSlot);
    if (slotDate < new Date()) {
      return res.status(400).json({ 
        success: false,
        message: 'Time slot must be in the future' 
      });
    }

    // Create boost consultation request
    const boost = new Boost({
      userId: req.user!.id,
      postId: null, // No post associated with consultation
      platform: 'consultation' as any, // Special type for consultation
      budget: 0, // No budget for consultation
      duration: 1, // 1 day default
      targetAudience: {},
      status: 'pending',
      startDate: slotDate,
      endDate: slotDate,
      stats: {
        impressions: 0,
        clicks: 0,
        spent: 0,
        reach: 0,
      },
    });

    await boost.save();

    // Send email notification to admin
    try {
      const emailHtml = boostEmailTemplate({
        id: boost._id.toString(),
        name,
        userId: req.user!.id,
        contact,
        timeSlot: slotDate.toLocaleString(),
        message: message || null,
      });

      await transporter.sendMail({
        from: process.env.MAIL_USER || 'noreply@konnectmedia.com',
        to: process.env.ADMIN_EMAIL || process.env.MAIL_USER,
        subject: '🚀 New Boost Consultation Request',
        html: emailHtml,
      });

      console.log('✅ Boost consultation email sent to admin');
    } catch (emailError: any) {
      console.error('⚠️  Failed to send boost email:', emailError.message);
      // Don't fail the request if email fails
    }

    res.status(201).json({
      success: true,
      message: 'Consultation request sent successfully',
      data: {
        id: boost._id,
        timeSlot: slotDate,
        status: 'pending',
      },
    });
  } catch (error: any) {
    console.error('Error creating boost consultation:', error);
    res.status(500).json({ 
      success: false,
      message: error.message || 'Failed to send consultation request'
    });
  }
});

// GET boost action (approve/reject) - for admin email links
router.get('/action', async (req, res) => {
  try {
    const { id, type } = req.query;

    if (!id || !type) {
      return res.status(400).send('Missing parameters');
    }

    const boost = await Boost.findById(id);
    if (!boost) {
      return res.status(404).send('Consultation request not found');
    }

    if (type === 'approve') {
      boost.status = 'active';
      await boost.save();
      res.send(`
        <html>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: #22c55e;">✅ Approved</h1>
            <p>Consultation request has been approved.</p>
            <p>The user will be notified.</p>
          </body>
        </html>
      `);
    } else if (type === 'reject') {
      boost.status = 'cancelled';
      await boost.save();
      res.send(`
        <html>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: #ef4444;">❌ Rejected</h1>
            <p>Consultation request has been rejected.</p>
            <p>The user will be notified.</p>
          </body>
        </html>
      `);
    } else {
      res.status(400).send('Invalid action type');
    }
  } catch (error: any) {
    console.error('Error processing boost action:', error);
    res.status(500).send('Server error');
  }
});

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
