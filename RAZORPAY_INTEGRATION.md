# 💳 Razorpay Integration Guide

## 🔑 Your Razorpay Test Credentials

```
Key ID: rzp_test_STRzCGTESz1pM7
Key Secret: GkvoEbJBuLKx11r2zHt14XhC
```

**Mode:** Test (for testing payments without real money)

---

## 📝 Step 1: Update Backend Environment Variables

### Update `api/.env` file:

Replace these lines:
```env
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

With:
```env
RAZORPAY_KEY_ID=rzp_test_STRzCGTESz1pM7
RAZORPAY_KEY_SECRET=GkvoEbJBuLKx11r2zHt14XhC
```

---

## 📝 Step 2: Update Render Environment Variables

Since your backend is deployed on Render, you need to update environment variables there:

1. Go to: https://dashboard.render.com/
2. Login to your account
3. Click on your service: `konnectmedia-api`
4. Go to "Environment" tab
5. Find or add these variables:
   - **Key:** `RAZORPAY_KEY_ID`
   - **Value:** `rzp_test_STRzCGTESz1pM7`
   
   - **Key:** `RAZORPAY_KEY_SECRET`
   - **Value:** `GkvoEbJBuLKx11r2zHt14XhC`

6. Click "Save Changes"
7. Render will automatically redeploy your service

---

## 📝 Step 3: Enable Real Razorpay in Flutter App

Currently, the app is in demo mode (bypassing Razorpay). To enable real Razorpay:

### Option A: Keep Demo Mode (Recommended for Now)
- No changes needed
- App will continue to work without real payment
- Good for testing other features

### Option B: Enable Real Razorpay
You'll need to update the Flutter app code to use real Razorpay instead of demo mode.

**Note:** I recommend keeping demo mode for now since:
1. Razorpay doesn't work on Windows desktop (where you're testing)
2. Razorpay only works on Android/iOS devices
3. You can test real payments after deploying APK to Android device

---

## 🧪 How to Test Razorpay (Test Mode)

### Test Cards (No Real Money):

**Successful Payment:**
```
Card Number: 4111 1111 1111 1111
CVV: Any 3 digits (e.g., 123)
Expiry: Any future date (e.g., 12/25)
Name: Any name
```

**Failed Payment:**
```
Card Number: 4000 0000 0000 0002
CVV: Any 3 digits
Expiry: Any future date
```

**UPI (Test):**
```
UPI ID: success@razorpay
```

---

## 📱 Testing on Android Device

Once you install the APK on Android:

1. Open app
2. Go to Profile → My Subscription
3. Click "Upgrade Now" on Premium plan
4. Razorpay payment screen will open
5. Use test card details above
6. Payment will be processed
7. Premium features unlock

---

## 🔄 Backend Flow (Already Implemented)

Your backend already handles Razorpay properly:

1. **Create Order:** `/api/subscription/create-order`
   - Creates Razorpay order
   - Returns order ID and amount

2. **Verify Payment:** `/api/subscription/verify-payment`
   - Verifies payment signature
   - Activates premium subscription
   - Supports both demo and real payments

3. **Demo Mode Detection:**
   - Backend automatically detects demo payments (IDs starting with `demo_`)
   - Real Razorpay payments are verified with signature

---

## 🎯 Current Status

### ✅ What's Working:
- Backend has Razorpay integration code
- Demo mode active (bypasses payment)
- Subscription activation works
- Premium features unlock

### ⚠️ What's Not Active Yet:
- Real Razorpay payment flow (demo mode is active)
- Payment verification with real credentials

### 🔧 What You Need to Do:
1. ✅ Add credentials to `api/.env` (local)
2. ✅ Add credentials to Render environment variables (production)
3. ⏳ Test on Android device (after APK installation)

---

## 🚀 When to Switch from Demo to Real Razorpay

**Keep Demo Mode If:**
- Still testing features
- Testing on Windows desktop
- Not ready for real payments

**Switch to Real Razorpay When:**
- Ready to test real payment flow
- Testing on Android device
- Want to see actual Razorpay payment screen

---

## 💰 Razorpay Pricing

**Test Mode:** Free (no charges)

**Live Mode:**
- 2% transaction fee
- No setup fee
- No annual fee
- Instant settlements available

---

## 🔐 Security Notes

1. **Never expose Key Secret:**
   - Keep it in `.env` file only
   - Never commit to GitHub
   - Never share publicly

2. **Test vs Live Keys:**
   - Test keys start with `rzp_test_`
   - Live keys start with `rzp_live_`
   - Always test with test keys first

3. **Signature Verification:**
   - Backend verifies payment signature
   - Prevents payment tampering
   - Already implemented in your code

---

## 📞 Razorpay Dashboard

Access your Razorpay dashboard:
- URL: https://dashboard.razorpay.com/
- View all test transactions
- Check payment status
- Download reports

---

## ❓ FAQ

**Q: Can I test Razorpay on Windows?**
A: No, Razorpay Flutter plugin only works on Android/iOS. Use demo mode for Windows testing.

**Q: Will test payments charge real money?**
A: No, test mode uses fake payment gateway. No real money involved.

**Q: How to get live keys?**
A: Complete KYC verification in Razorpay dashboard, then generate live keys.

**Q: Can I use demo mode in production?**
A: No, demo mode is for testing only. Use real Razorpay for production.

---

## ✅ Next Steps

1. **Now:** Add credentials to Render environment variables
2. **Later:** Test on Android device with real Razorpay flow
3. **Production:** Complete KYC and get live keys

---

Need help with any step? Let me know!
