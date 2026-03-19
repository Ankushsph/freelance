import mongoose, { Schema, Document } from 'mongoose';

export interface IAnnouncement extends Document {
  title: string;
  body: string;
  type: 'Info' | 'Warning' | 'Alert';
  audience: string;
  createdAt: Date;
}

const AnnouncementSchema: Schema = new Schema({
  title: { type: String, required: true },
  body: { type: String, required: true },
  type: { 
    type: String, 
    enum: ['Info', 'Warning', 'Alert'], 
    default: 'Info' 
  },
  audience: { type: String, default: 'All Users' },
  createdAt: { type: Date, default: Date.now }
});

export const Announcement = mongoose.model<IAnnouncement>('Announcement', AnnouncementSchema);
