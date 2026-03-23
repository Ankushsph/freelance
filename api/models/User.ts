import { Schema, model, Document } from "mongoose";

export interface IUser extends Document {
  name: string;
  username?: string;
  email: string;
  number?: number;
  phone?: string;
  password?: string;
  dateOfBirth?: string;
  profilePicture?: string;
  
  // Instagram
  instagramAccessToken?: string;
  instagramUserId?: string;
  instagramOAuthState?: string;
  instagramUsername?: string;
  
  // Facebook
  facebookAccessToken?: string;
  facebookUserId?: string;
  facebookOAuthState?: string;
  facebookPageId?: string; // Selected page to post to
  facebookUsername?: string;
  
  // LinkedIn
  linkedinAccessToken?: string;
  linkedinRefreshToken?: string;
  linkedinUserId?: string; // Person URN
  linkedinCompanyId?: string; // Optional: default company page
  linkedinOAuthState?: string;
  linkedinUsername?: string;
  
  // Twitter/X
  twitterAccessToken?: string;
  twitterRefreshToken?: string;
  twitterUserId?: string;
  twitterOAuthState?: string;
  twitterUsername?: string;
  
  // Subscription
  planType: 'Free' | 'Premium';
  subscriptionStatus: 'Active' | 'Expired' | 'None';
  subscriptionStartDate?: Date;
  subscriptionExpiryDate?: Date;
  razorpayPaymentId?: string;
  razorpayOrderId?: string;
  razorpaySignature?: string;

  // Active Platform
  activePlatform?: 'instagram' | 'facebook' | 'twitter' | 'linkedin';

  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    name: { type: String, required: true },
    username: { type: String },
    email: { type: String, required: true, unique: true },
    number: { type: Number, required: false },
    phone: { type: String },
    password: { type: String, required: false },
    dateOfBirth: { type: String },
    profilePicture: { type: String },
    
    // Instagram
    instagramAccessToken: { type: String },
    instagramUserId: { type: String },
    instagramOAuthState: { type: String },
    instagramUsername: { type: String },
    
    // Facebook
    facebookAccessToken: {type: String},
    facebookUserId: {type: String},
    facebookOAuthState: {type: String},
    facebookPageId: {type: String},
    facebookUsername: { type: String },
    
    // LinkedIn
    linkedinAccessToken: { type: String },
    linkedinRefreshToken: { type: String },
    linkedinUserId: { type: String },
    linkedinCompanyId: { type: String },
    linkedinOAuthState: { type: String },
    linkedinUsername: { type: String },
    
    // Twitter/X
    twitterAccessToken: { type: String },
    twitterRefreshToken: { type: String },
    twitterUserId: { type: String },
    twitterOAuthState: { type: String },
    twitterUsername: { type: String },
    
    // Subscription
    planType: { type: String, enum: ['Free', 'Premium'], default: 'Free' },
    subscriptionStatus: { type: String, enum: ['Active', 'Expired', 'None'], default: 'None' },
    subscriptionStartDate: { type: Date },
    subscriptionExpiryDate: { type: Date },
    razorpayPaymentId: { type: String },
    razorpayOrderId: { type: String },
    razorpaySignature: { type: String },
    
    // Active Platform
    activePlatform: { type: String, enum: ['instagram', 'facebook', 'twitter', 'linkedin'] },
  },
  { timestamps: true }
);

export const User = model<IUser>("User", UserSchema);
