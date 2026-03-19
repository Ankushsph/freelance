import { Router } from 'express';
import { Trend } from '../models/Trend.js';
import { SavedTrend } from '../models/SavedTrend.js';

const router = Router();

// Mock data for demo
const mockTrends = {
  instagram: {
    reels: [
      {
        title: 'Ashley Graham',
        handle: '@Ashley Graham #Ashley Graham',
        thumbnail: 'https://via.placeholder.com/150?text=Ashley+Graham',
        creator: { name: 'Ashley Graham', handle: '@Ashley Graham', avatar: 'https://via.placeholder.com/50?text=AG' },
        engagement: { likes: 12000, comments: 2000, views: 2000000 },
        category: 'reels',
        platform: 'instagram'
      },
      {
        title: 'Kendall Jenner',
        handle: 'Mallorca',
        thumbnail: 'https://via.placeholder.com/150?text=Kendall+Jenner',
        creator: { name: 'Kendall Jenner', handle: '@kendalljenner', avatar: 'https://via.placeholder.com/50?text=KJ' },
        engagement: { likes: 15000, comments: 1000, views: 5000000 },
        category: 'reels',
        platform: 'instagram'
      },
      {
        title: 'Gigi Hadid',
        handle: 'Just added *sunkisser*',
        thumbnail: 'https://via.placeholder.com/150?text=Gigi+Hadid',
        creator: { name: 'Gigi Hadid', handle: '@gigihadid', avatar: 'https://via.placeholder.com/50?text=GH' },
        engagement: { likes: 11000, comments: 3000, views: 7000000 },
        category: 'reels',
        platform: 'instagram'
      },
      {
        title: 'Riswan_freestyle',
        handle: 'Freestyle football trick at waterfall',
        thumbnail: 'https://via.placeholder.com/150?text=Freestyle',
        creator: { name: 'Riswan_freestyle', handle: '@riswan_freestyle', avatar: 'https://via.placeholder.com/50?text=RF' },
        engagement: { likes: 32000, comments: 29000, views: 232000000 },
        category: 'reels',
        platform: 'instagram'
      },
      {
        title: 'Samsung AD by BTS',
        handle: "J-Hope's selfie",
        thumbnail: 'https://via.placeholder.com/150?text=Samsung+BTS',
        creator: { name: 'Samsung', handle: '@samsung', avatar: 'https://via.placeholder.com/50?text=Samsung' },
        engagement: { likes: 35000, comments: 37000, views: 345000000 },
        category: 'reels',
        platform: 'instagram'
      }
    ],
    audio: [
      {
        title: 'At My Worst',
        artist: 'Pink Sweats',
        duration: '2:50',
        thumbnail: 'https://via.placeholder.com/100?text=At+My+Worst',
        creator: { name: 'Pink Sweats', handle: '@pinksweatsjr', avatar: 'https://via.placeholder.com/50?text=PS' },
        engagement: { likes: 50000, comments: 5000, views: 10000000 },
        category: 'audio',
        platform: 'instagram'
      },
      {
        title: 'The Night We Met',
        artist: 'Lord Huron',
        duration: '3:28',
        thumbnail: 'https://via.placeholder.com/100?text=Night+We+Met',
        creator: { name: 'Lord Huron', handle: '@lordhuron', avatar: 'https://via.placeholder.com/50?text=LH' },
        engagement: { likes: 45000, comments: 4000, views: 9000000 },
        category: 'audio',
        platform: 'instagram'
      },
      {
        title: 'Be Alright',
        artist: 'Dean Lewis',
        duration: '3:16',
        thumbnail: 'https://via.placeholder.com/100?text=Be+Alright',
        creator: { name: 'Dean Lewis', handle: '@deanlewis', avatar: 'https://via.placeholder.com/50?text=DL' },
        engagement: { likes: 48000, comments: 4500, views: 8500000 },
        category: 'audio',
        platform: 'instagram'
      }
    ]
  },
  facebook: {
    reels: [
      {
        title: 'Meta Connect 2024',
        handle: '@Meta',
        thumbnail: 'https://via.placeholder.com/150?text=Meta+Connect',
        creator: { name: 'Meta', handle: '@meta', avatar: 'https://via.placeholder.com/50?text=Meta' },
        engagement: { likes: 45000, comments: 8000, views: 12000000 },
        category: 'reels',
        platform: 'facebook'
      },
      {
        title: 'Mark Zuckerberg',
        handle: 'New AI Features Drop',
        thumbnail: 'https://via.placeholder.com/150?text=Zuckerberg',
        creator: { name: 'Mark Zuckerberg', handle: '@zuck', avatar: 'https://via.placeholder.com/50?text=MZ' },
        engagement: { likes: 120000, comments: 22000, views: 50000000 },
        category: 'reels',
        platform: 'facebook'
      },
      {
        title: 'National Geographic',
        handle: 'Amazon Rainforest Deep Dive',
        thumbnail: 'https://via.placeholder.com/150?text=NatGeo',
        creator: { name: 'National Geographic', handle: '@natgeo', avatar: 'https://via.placeholder.com/50?text=NG' },
        engagement: { likes: 89000, comments: 14000, views: 30000000 },
        category: 'reels',
        platform: 'facebook'
      },
      {
        title: 'NASA',
        handle: 'James Webb Telescope New Images',
        thumbnail: 'https://via.placeholder.com/150?text=NASA',
        creator: { name: 'NASA', handle: '@nasa', avatar: 'https://via.placeholder.com/50?text=NASA' },
        engagement: { likes: 200000, comments: 35000, views: 80000000 },
        category: 'reels',
        platform: 'facebook'
      },
      {
        title: 'BBC News',
        handle: 'Breaking: Climate Summit 2024',
        thumbnail: 'https://via.placeholder.com/150?text=BBC+News',
        creator: { name: 'BBC News', handle: '@bbcnews', avatar: 'https://via.placeholder.com/50?text=BBC' },
        engagement: { likes: 67000, comments: 19000, views: 25000000 },
        category: 'reels',
        platform: 'facebook'
      }
    ],
    audio: [
      {
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        duration: '3:54',
        thumbnail: 'https://via.placeholder.com/100?text=Shape+of+You',
        creator: { name: 'Ed Sheeran', handle: '@edsheeran', avatar: 'https://via.placeholder.com/50?text=ES' },
        engagement: { likes: 310000, comments: 42000, views: 150000000 },
        category: 'audio',
        platform: 'facebook'
      },
      {
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        duration: '3:20',
        thumbnail: 'https://via.placeholder.com/100?text=Blinding+Lights',
        creator: { name: 'The Weeknd', handle: '@theweeknd', avatar: 'https://via.placeholder.com/50?text=TW' },
        engagement: { likes: 280000, comments: 38000, views: 120000000 },
        category: 'audio',
        platform: 'facebook'
      },
      {
        title: 'As It Was',
        artist: 'Harry Styles',
        duration: '2:37',
        thumbnail: 'https://via.placeholder.com/100?text=As+It+Was',
        creator: { name: 'Harry Styles', handle: '@harrystyles', avatar: 'https://via.placeholder.com/50?text=HS' },
        engagement: { likes: 195000, comments: 27000, views: 90000000 },
        category: 'audio',
        platform: 'facebook'
      }
    ],
    posts: [
      {
        title: 'NASA Artemis Mission Update',
        handle: '@NASA',
        thumbnail: 'https://via.placeholder.com/150?text=Artemis',
        creator: { name: 'NASA', handle: '@nasa', avatar: 'https://via.placeholder.com/50?text=NASA' },
        engagement: { likes: 450000, comments: 62000, views: 200000000 },
        category: 'posts',
        platform: 'facebook'
      },
      {
        title: 'World Cup 2026 Preview',
        handle: '@FIFA',
        thumbnail: 'https://via.placeholder.com/150?text=FIFA+2026',
        creator: { name: 'FIFA', handle: '@fifaworldcup', avatar: 'https://via.placeholder.com/50?text=FIFA' },
        engagement: { likes: 890000, comments: 130000, views: 500000000 },
        category: 'posts',
        platform: 'facebook'
      }
    ]
  },
  twitter: {
    posts: [
      {
        title: 'Elon Musk on AI',
        handle: '@elonmusk',
        thumbnail: 'https://via.placeholder.com/150?text=Elon+Musk',
        creator: { name: 'Elon Musk', handle: '@elonmusk', avatar: 'https://via.placeholder.com/50?text=EM' },
        engagement: { likes: 320000, comments: 45000, views: 40000000 },
        category: 'posts',
        platform: 'twitter'
      },
      {
        title: 'Breaking News: Tech Layoffs',
        handle: '@TechCrunch',
        thumbnail: 'https://via.placeholder.com/150?text=TechCrunch',
        creator: { name: 'TechCrunch', handle: '@techcrunch', avatar: 'https://via.placeholder.com/50?text=TC' },
        engagement: { likes: 78000, comments: 12000, views: 8000000 },
        category: 'posts',
        platform: 'twitter'
      },
      {
        title: 'OpenAI Launches GPT-5',
        handle: '@OpenAI',
        thumbnail: 'https://via.placeholder.com/150?text=OpenAI',
        creator: { name: 'OpenAI', handle: '@openai', avatar: 'https://via.placeholder.com/50?text=OAI' },
        engagement: { likes: 512000, comments: 98000, views: 60000000 },
        category: 'posts',
        platform: 'twitter'
      },
      {
        title: 'NBA Finals Highlights',
        handle: '@NBA',
        thumbnail: 'https://via.placeholder.com/150?text=NBA',
        creator: { name: 'NBA', handle: '@nba', avatar: 'https://via.placeholder.com/50?text=NBA' },
        engagement: { likes: 230000, comments: 41000, views: 25000000 },
        category: 'posts',
        platform: 'twitter'
      },
      {
        title: 'Apple WWDC Recap',
        handle: '@Apple',
        thumbnail: 'https://via.placeholder.com/150?text=Apple',
        creator: { name: 'Apple', handle: '@apple', avatar: 'https://via.placeholder.com/50?text=Apple' },
        engagement: { likes: 410000, comments: 67000, views: 45000000 },
        category: 'posts',
        platform: 'twitter'
      }
    ],
    threads: [
      {
        title: 'Thread: How to build in public',
        handle: '@levelsio',
        thumbnail: 'https://via.placeholder.com/150?text=Build+Public',
        creator: { name: 'Pieter Levels', handle: '@levelsio', avatar: 'https://via.placeholder.com/50?text=PL' },
        engagement: { likes: 45000, comments: 8200, views: 5000000 },
        category: 'threads',
        platform: 'twitter'
      },
      {
        title: 'Thread: 10 things I learned founding a startup',
        handle: '@paulg',
        thumbnail: 'https://via.placeholder.com/150?text=YC+Startup',
        creator: { name: 'Paul Graham', handle: '@paulg', avatar: 'https://via.placeholder.com/50?text=PG' },
        engagement: { likes: 92000, comments: 15000, views: 12000000 },
        category: 'threads',
        platform: 'twitter'
      }
    ]
  },
  linkedin: {
    posts: [
      {
        title: 'How I grew my B2B SaaS to $1M ARR',
        handle: '@Justin Welsh',
        thumbnail: 'https://via.placeholder.com/150?text=Justin+Welsh',
        creator: { name: 'Justin Welsh', handle: '@justinwelsh', avatar: 'https://via.placeholder.com/50?text=JW' },
        engagement: { likes: 34000, comments: 2800, views: 1500000 },
        category: 'posts',
        platform: 'linkedin'
      },
      {
        title: 'Microsoft CEO on the future of work',
        handle: '@Satya Nadella',
        thumbnail: 'https://via.placeholder.com/150?text=Satya+Nadella',
        creator: { name: 'Satya Nadella', handle: '@satyanadella', avatar: 'https://via.placeholder.com/50?text=SN' },
        engagement: { likes: 89000, comments: 7200, views: 4000000 },
        category: 'posts',
        platform: 'linkedin'
      },
      {
        title: '5 habits of highly effective leaders',
        handle: '@Simon Sinek',
        thumbnail: 'https://via.placeholder.com/150?text=Simon+Sinek',
        creator: { name: 'Simon Sinek', handle: '@simonsinek', avatar: 'https://via.placeholder.com/50?text=SS' },
        engagement: { likes: 120000, comments: 9800, views: 6000000 },
        category: 'posts',
        platform: 'linkedin'
      },
      {
        title: 'I got rejected 100 times before landing my dream job',
        handle: '@Career Coach',
        thumbnail: 'https://via.placeholder.com/150?text=Career+Story',
        creator: { name: 'Lara Martin', handle: '@laramartin', avatar: 'https://via.placeholder.com/50?text=LM' },
        engagement: { likes: 210000, comments: 18000, views: 10000000 },
        category: 'posts',
        platform: 'linkedin'
      }
    ],
    articles: [
      {
        title: 'The Future of Generative AI in Enterprise',
        handle: 'Harvard Business Review',
        thumbnail: 'https://via.placeholder.com/150?text=HBR+AI',
        creator: { name: 'Harvard Business Review', handle: '@hbr', avatar: 'https://via.placeholder.com/50?text=HBR' },
        engagement: { likes: 55000, comments: 4200, views: 2500000 },
        category: 'articles',
        platform: 'linkedin'
      },
      {
        title: 'Remote Work Is Here to Stay: New Data',
        handle: 'McKinsey & Company',
        thumbnail: 'https://via.placeholder.com/150?text=McKinsey',
        creator: { name: 'McKinsey & Company', handle: '@mckinsey', avatar: 'https://via.placeholder.com/50?text=MK' },
        engagement: { likes: 43000, comments: 3100, views: 2000000 },
        category: 'articles',
        platform: 'linkedin'
      }
    ]
  }
};

// GET Popular trends
router.get('/popular', async (req, res) => {
  try {
    const { platform = 'instagram', category = 'reels' } = req.query;

    // Try to fetch from DB first
    let trends = await Trend.find({
      platform,
      category,
      userCategory: null
    }).sort({ trendScore: -1 }).limit(10);

    // If no trends in DB, use mock data
    if (trends.length === 0) {
      const mockData = mockTrends[platform as keyof typeof mockTrends];
      if (mockData && mockData[category as keyof typeof mockData]) {
        const data = mockData[category as keyof typeof mockData];
        return res.json({
          success: true,
          data: Array.isArray(data) ? data : []
        });
      }
    }

    res.json({ success: true, data: trends });
  } catch (error) {
    console.error('Error fetching popular trends:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET For You (personalized trends)
router.get('/for-you', async (req, res) => {
  try {
    const { platform = 'instagram', userId, category = 'reels' } = req.query;

    // Fetch user's saved trends to understand preferences
    const savedTrends = await SavedTrend.find({ userId }).select('category');
    const userCategories = savedTrends.map(t => t.category);

    // Fetch personalized trends
    let trends = await Trend.find({
      platform,
      category,
      $or: [
        { userCategory: { $in: userCategories } },
        { tags: { $in: userCategories } }
      ]
    }).sort({ trendScore: -1 }).limit(10);

    // Fallback to popular if no personalized trends
    if (trends.length === 0) {
      trends = await Trend.find({
        platform,
        category
      }).sort({ trendScore: -1 }).limit(10);
    }

    res.json({ success: true, data: trends });
  } catch (error) {
    console.error('Error fetching for-you trends:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// GET Saved trends
router.get('/saved', async (req, res) => {
  try {
    const { userId, platform = 'instagram' } = req.query;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId required' });
    }

    const savedTrends = await SavedTrend.find({ userId, platform })
      .populate('trendId')
      .sort({ savedAt: -1 });

    const trends = savedTrends.map(st => st.trendId);

    res.json({ success: true, data: trends });
  } catch (error) {
    console.error('Error fetching saved trends:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// POST Save trend
router.post('/save', async (req, res) => {
  try {
    const { userId, trendId, platform, category } = req.body;

    if (!userId || !trendId) {
      return res.status(400).json({ success: false, message: 'userId and trendId required' });
    }

    // Check if already saved
    const existing = await SavedTrend.findOne({ userId, trendId });
    if (existing) {
      return res.json({ success: true, message: 'Already saved', data: existing });
    }

    const savedTrend = await SavedTrend.create({
      userId,
      trendId,
      platform,
      category
    });

    res.json({ success: true, data: savedTrend });
  } catch (error) {
    console.error('Error saving trend:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// DELETE Unsave trend
router.delete('/unsave/:savedTrendId', async (req, res) => {
  try {
    const { savedTrendId } = req.params;

    await SavedTrend.findByIdAndDelete(savedTrendId);

    res.json({ success: true, message: 'Trend unsaved' });
  } catch (error) {
    console.error('Error unsaving trend:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;
