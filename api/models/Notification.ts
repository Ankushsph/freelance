import mongoose, { Schema, Document } from 'mongoose';

export interface INotification extends Document {
  userId: mongoose.Types.ObjectId;
  type: 'post_published' | 'post_failed' | 'post_scheduled' | 'subscription' | 'boost' | 'analytics' | 'system';
  title: string;
  message: string;
  data?: any;
  read: boolean;
  actionUrl?: string;
  createdAt: Date;
}

const NotificationSchema: Schema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['post_published', 'post_failed', 'post_scheduled', 'subscription', 'boost', 'analytics', 'system'],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    data: {
      type: Schema.Types.Mixed,
    },
    read: {
      type: Boolean,
      default: false,
      index: true,
    },
    actionUrl: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for efficient queries
NotificationSchema.index({ userId: 1, read: 1, createdAt: -1 });
NotificationSchema.index({ userId: 1, type: 1 });

// Helper method to create notification
NotificationSchema.statics.createNotification = async function(
  userId: mongoose.Types.ObjectId,
  type: string,
  title: string,
  message: string,
  data?: any,
  actionUrl?: string
) {
  return await this.create({
    userId,
    type,
    title,
    message,
    data,
    actionUrl,
    read: false,
  });
};

export default mongoose.model<INotification>('Notification', NotificationSchema);
