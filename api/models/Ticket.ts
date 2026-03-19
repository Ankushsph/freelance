import mongoose, { Schema, Document } from 'mongoose';

export interface ITicket extends Document {
  user: mongoose.Types.ObjectId;
  issue: string;
  priority: 'Low' | 'Medium' | 'High';
  status: 'Open' | 'In Progress' | 'Resolved';
  createdAt: Date;
  updatedAt: Date;
}

const TicketSchema: Schema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  issue: { type: String, required: true },
  priority: { 
    type: String, 
    enum: ['Low', 'Medium', 'High'], 
    default: 'Medium' 
  },
  status: { 
    type: String, 
    enum: ['Open', 'In Progress', 'Resolved'], 
    default: 'Open' 
  }
}, { timestamps: true });

export const Ticket = mongoose.model<ITicket>('Ticket', TicketSchema);
