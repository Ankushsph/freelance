import mongoose, { Schema, Document } from 'mongoose';

export interface IBoost extends Document {
  userId: mongoose.Types.ObjectId;
  postId: mongoose.Types.ObjectId | null;
  platform: 'instagram' | 'facebook' | 'linkedin' | 'twitter' | 'consultation';
  budget: number;
  duration: number; // days
  targetAudience: {
    ageRange?: string;
    gender?: string;
    locations?: string[];
    interests?: string[];
  };
  status: 'pending' | 'active' | 'paused' | 'completed' | 'cancelled';
  stats: {
    impressions: number;
    clicks: number;
    spent: number;
    reach: number;
  };
  startDate: Date;
  endDate: Date;
  createdAt: Date;
  updatedAt: Date;
}

const BoostSchema: Schema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    postId: {
      type: Schema.Types.ObjectId,
      ref: 'Post',
      required: false,
      default: null,
    },
    platform: {
      type: String,
      enum: ['instagram', 'facebook', 'linkedin', 'twitter', 'consultation'],
      required: true,
    },
    budget: {
      type: Number,
      required: true,
      min: 0,
    },
    duration: {
      type: Number,
      required: true,
      min: 1,
      max: 30,
    },
    targetAudience: {
      ageRange: String,
      gender: {
        type: String,
        enum: ['all', 'male', 'female', 'other'],
        default: 'all',
      },
      locations: [String],
      interests: [String],
    },
    status: {
      type: String,
      enum: ['pending', 'active', 'paused', 'completed', 'cancelled'],
      default: 'pending',
      index: true,
    },
    stats: {
      impressions: { type: Number, default: 0 },
      clicks: { type: Number, default: 0 },
      spent: { type: Number, default: 0 },
      reach: { type: Number, default: 0 },
    },
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for efficient queries
BoostSchema.index({ userId: 1, status: 1 });
BoostSchema.index({ postId: 1 });
BoostSchema.index({ endDate: 1, status: 1 });

export default mongoose.model<IBoost>('Boost', BoostSchema);
