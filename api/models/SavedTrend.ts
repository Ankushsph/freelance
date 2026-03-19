import mongoose from 'mongoose';

const savedTrendSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  trendId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Trend',
    required: true
  },
  platform: {
    type: String,
    enum: ['instagram', 'facebook', 'linkedin', 'x'],
    required: true
  },
  category: String,
  savedAt: {
    type: Date,
    default: Date.now
  }
});

export const SavedTrend = mongoose.model('SavedTrend', savedTrendSchema);
