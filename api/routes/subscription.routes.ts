import { Router } from 'express';
import { Subscription } from '../models/Subscription.js';
import { verifyToken } from '../middleware/auth.js';
import type { Request } from 'express';
import crypto from 'crypto';

interface AuthRequest extends Request {
  user?: { id: string };
}

const router = Router();

// Razorpay configuration
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || '';
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || '';

// Premium plan price (in paise - ₹999 = 99900 paise)
const PREMIUM_PRICE = 99900;

// Health check endpoint for Razorpay
router.get('/razorpay-status', (req, res) => {
  res.json({
    success: true,
    razorpay: {
      keyIdConfigured: !!RAZORPAY_KEY_ID,
      keySecretConfigured: !!RAZORPAY_KEY_SECRET,
      keyIdPrefix: RAZORPAY_KEY_ID ? RAZORPAY_KEY_ID.substring(0, 8) + '...' : 'Not set',
      usingRestApi: true
    }
  });
});

// GET user's current subscription
router.get('/me', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    let subscription = await Subscription.findOne({ userId });
    
    // Create free subscription if doesn't exist
    if (!subscription) {
      subscription = await Subscription.create({
        userId,
        planType: 'free',
        subscriptionStatus: 'active'
      });
    }
    
    // Check if premium subscription expired
    if (subscription.planType === 'premium' && subscription.expiryDate) {
      if (new Date() > subscription.expiryDate) {
        subscription.subscriptionStatus = 'expired';
        subscription.planType = 'free';
        await subscription.save();
      }
    }
    
    res.json({
      success: true,
      data: subscription
    });
  } catch (error) {
    console.error('Error fetching subscription:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// CREATE Razorpay order
router.post('/create-order', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    console.log('Creating order for user:', userId);
    console.log('Razorpay Key ID:', RAZORPAY_KEY_ID ? 'Present' : 'Missing');
    console.log('Razorpay Key Secret:', RAZORPAY_KEY_SECRET ? 'Present' : 'Missing');
    
    // Validate Razorpay credentials
    if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
      console.error('Razorpay credentials missing');
      return res.status(500).json({ 
        success: false, 
        message: 'Razorpay credentials not configured' 
      });
    }
    
    // Use Razorpay REST API directly instead of SDK
    const orderData = {
      amount: PREMIUM_PRICE,
      currency: 'INR',
      receipt: `rcpt_${Date.now()}`, // Keep it short - max 40 chars
      notes: {
        userId: userId,
        planType: 'premium'
      }
    };
    
    console.log('Creating order via REST API with data:', orderData);
    
    try {
      // Make direct HTTP request to Razorpay API
      const auth = Buffer.from(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`).toString('base64');
      
      const response = await fetch('https://api.razorpay.com/v1/orders', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(orderData)
      });
      
      const responseData: any = await response.json();
      
      if (!response.ok) {
        console.error('Razorpay API error:', responseData);
        return res.status(500).json({ 
          success: false, 
          message: `Order creation failed: ${responseData.error?.description || 'API error'}`,
          error: responseData.error?.description
        });
      }
      
      console.log('Razorpay order created successfully:', responseData.id);
      
      res.json({
        success: true,
        data: {
          orderId: responseData.id,
          amount: responseData.amount,
          currency: responseData.currency,
          keyId: RAZORPAY_KEY_ID
        }
      });
    } catch (apiError: any) {
      console.error('Razorpay API request failed:', apiError);
      return res.status(500).json({ 
        success: false, 
        message: `API request failed: ${apiError.message}`,
        error: apiError.message
      });
    }
  } catch (error: any) {
    console.error('Error in create-order endpoint:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to create subscription order' 
    });
  }
});

// VERIFY payment and activate subscription
router.post('/verify-payment', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;
    
    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
      return res.status(400).json({ success: false, message: 'Missing payment details' });
    }
    
    // Check if this is a demo payment (for testing without Razorpay credentials)
    const isDemoPayment = razorpayOrderId.startsWith('demo_order_') || 
                         razorpayPaymentId.startsWith('demo_payment_');
    
    // Verify signature only for real Razorpay payments
    if (!isDemoPayment && RAZORPAY_KEY_SECRET && RAZORPAY_KEY_SECRET !== 'your_razorpay_key_secret') {
      const text = `${razorpayOrderId}|${razorpayPaymentId}`;
      const expectedSignature = crypto
        .createHmac('sha256', RAZORPAY_KEY_SECRET as string)
        .update(text)
        .digest('hex');
      
      if (expectedSignature !== razorpaySignature) {
        return res.status(400).json({ success: false, message: 'Invalid payment signature' });
      }
    }
    
    // Calculate expiry date (30 days from now)
    const startDate = new Date();
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);
    
    // Update or create subscription
    let subscription = await Subscription.findOne({ userId });
    
    if (subscription) {
      subscription.planType = 'premium';
      subscription.subscriptionStatus = 'active';
      subscription.startDate = startDate;
      subscription.expiryDate = expiryDate;
      subscription.razorpayOrderId = razorpayOrderId;
      subscription.razorpayPaymentId = razorpayPaymentId;
      subscription.razorpaySignature = razorpaySignature;
      subscription.amount = PREMIUM_PRICE / 100; // Convert paise to rupees
      await subscription.save();
    } else {
      subscription = await Subscription.create({
        userId,
        planType: 'premium',
        subscriptionStatus: 'active',
        startDate,
        expiryDate,
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
        amount: PREMIUM_PRICE / 100
      });
    }
    
    const message = isDemoPayment 
      ? 'Premium subscription activated successfully (Demo Mode)'
      : 'Premium subscription activated successfully';
    
    res.json({
      success: true,
      message,
      data: subscription
    });
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({ success: false, message: 'Payment verification failed' });
  }
});

// CANCEL subscription
router.post('/cancel', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    const subscription = await Subscription.findOne({ userId });
    
    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }
    
    subscription.subscriptionStatus = 'cancelled';
    subscription.planType = 'free';
    await subscription.save();
    
    res.json({
      success: true,
      message: 'Subscription cancelled successfully',
      data: subscription
    });
  } catch (error) {
    console.error('Error cancelling subscription:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// CHECK feature access
router.get('/check-feature/:feature', verifyToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { feature } = req.params;
    
    if (!feature) {
      return res.status(400).json({ success: false, message: 'Feature parameter required' });
    }
    
    const subscription = await Subscription.findOne({ userId });
    
    // Free features available to all
    const freeFeatures = ['schedule', 'basic_dashboard'];
    
    // Premium features
    const premiumFeatures = ['ai_captions', 'advanced_analytics', 'trends', 'boost'];
    
    if (freeFeatures.includes(feature)) {
      return res.json({ success: true, hasAccess: true });
    }
    
    if (premiumFeatures.includes(feature)) {
      const hasAccess = subscription?.planType === 'premium' && 
                       subscription?.subscriptionStatus === 'active';
      
      return res.json({ 
        success: true, 
        hasAccess,
        requiresUpgrade: !hasAccess
      });
    }
    
    res.json({ success: true, hasAccess: false });
  } catch (error) {
    console.error('Error checking feature access:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

export default router;
