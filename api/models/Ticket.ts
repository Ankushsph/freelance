import mongoose, { Schema, Document } from 'mongoose';

export interface ITicket extends Document {
  userId: mongoose.Types.ObjectId;
  subject: string;
  message: string;
  category: 'technical' | 'billing' | 'feature' | 'other';
  status: 'open' | 'in_progress' | 'resolved' | 'closed';
  priority: 'low' | 'medium' | 'high';
  responses: {
    from: 'user' | 'support';
    message: string;
    createdAt: Date;
  }[];
  createdAt: Date;
  updatedAt: Date;
}

const TicketSchema: Schema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    subject: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    category: {
      type: String,
      enum: ['technical', 'billing', 'feature', 'other'],
      default: 'other',
    },
    status: {
      type: String,
      enum: ['open', 'in_progress', 'resolved', 'closed'],
      default: 'open',
      index: true,
    },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium',
    },
    responses: [
      {
        from: {
          type: String,
          enum: ['user', 'support'],
          required: true,
        },
        message: {
          type: String,
          required: true,
        },
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  {
    timestamps: true,
  }
);

// Indexes
TicketSchema.index({ userId: 1, status: 1 });
TicketSchema.index({ createdAt: -1 });

export default mongoose.model<ITicket>('Ticket', TicketSchema);
