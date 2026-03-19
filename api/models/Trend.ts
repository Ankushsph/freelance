import mongoose from 'mongoose';

const trendSchema = new mongoose.Schema({
  platform: {
    type: String,
    enum: ['instagram', 'facebook', 'linkedin', 'x'],
    required: true
  },
  category: {
    type: String,
    enum: ['reels', 'posts', 'audio', 'videos', 'articles'],
    required: true
  },
  contentType: {
    type: String,
    enum: ['reel', 'post', 'audio', 'video', 'article'],
    required: true
  },
  title: String,
  description: String,
  creator: {
    name: String,
    handle: String,
    avatar: String
  },
  content: {
    url: String,
    thumbnail: String,
    duration: Number // for audio/video
  },
  engagement: {
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    views: { type: Number, default: 0 }
  },
  trendScore: {
    type: Number,
    default: 0
  },
  tags: [String],
  userCategory: String, // for personalization
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

export const Trend = mongoose.model('Trend', trendSchema);
