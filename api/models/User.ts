import { Schema, model, Document } from "mongoose";

export interface IUser extends Document {
  name: string;
  email: string;
  number?: number;
  password?: string;
  
  // Instagram
  instagramAccessToken?: string;
  instagramUserId?: string;
  instagramOAuthState?: string;
  
  // Facebook
  facebookAccessToken?: string;
  facebookUserId?: string;
  facebookOAuthState?: string;
  facebookPageId?: string; // Selected page to post to
  
  // LinkedIn
  linkedinAccessToken?: string;
  linkedinRefreshToken?: string;
  linkedinUserId?: string; // Person URN
  linkedinCompanyId?: string; // Optional: default company page
  linkedinOAuthState?: string;
  
  // Twitter/X
  twitterAccessToken?: string;
  twitterRefreshToken?: string;
  twitterUserId?: string;
  twitterOAuthState?: string;
  
  // Subscription
  planType: 'Free' | 'Premium';
  subscriptionStatus: 'Active' | 'Expired' | 'None';
  subscriptionStartDate?: Date;
  subscriptionExpiryDate?: Date;
  razorpayPaymentId?: string;
  razorpayOrderId?: string;
  razorpaySignature?: string;

  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    number: { type: Number, required: false },
    password: { type: String, required: false },
    
    // Instagram
    instagramAccessToken: { type: String },
    instagramUserId: { type: String },
    instagramOAuthState: { type: String },
    
    // Facebook
    facebookAccessToken: {type: String},
    facebookUserId: {type: String},
    facebookOAuthState: {type: String},
    facebookPageId: {type: String},
    
    // LinkedIn
    linkedinAccessToken: { type: String },
    linkedinRefreshToken: { type: String },
    linkedinUserId: { type: String },
    linkedinCompanyId: { type: String },
    linkedinOAuthState: { type: String },
    
    // Twitter/X
    twitterAccessToken: { type: String },
    twitterRefreshToken: { type: String },
    twitterUserId: { type: String },
    twitterOAuthState: { type: String },
    
    // Subscription
    planType: { type: String, enum: ['Free', 'Premium'], default: 'Free' },
    subscriptionStatus: { type: String, enum: ['Active', 'Expired', 'None'], default: 'None' },
    subscriptionStartDate: { type: Date },
    subscriptionExpiryDate: { type: Date },
    razorpayPaymentId: { type: String },
    razorpayOrderId: { type: String },
    razorpaySignature: { type: String },
  },
  { timestamps: true }
);

export const User = model<IUser>("User", UserSchema);
