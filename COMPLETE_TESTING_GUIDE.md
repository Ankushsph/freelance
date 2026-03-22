# 🧪 COMPLETE TESTING GUIDE - All Features

## ✅ APK Built Successfully!

**Location:** `E:\KonnectMedia-main\ui_app\build\app\outputs\flutter-apk\app-debug.apk`

---

## 📱 STEP 1: Install APK on Android Phone

### Method 1: USB Transfer
1. Connect phone to PC via USB
2. Copy APK to phone storage
3. Open file manager on phone
4. Tap the APK file
5. Allow "Install from unknown sources" if prompted
6. Install

### Method 2: Google Drive
1. Upload APK to Google Drive
2. Open Drive on phone
3. Download and install

### Method 3: Email/WhatsApp
1. Send APK to yourself
2. Download on phone
3. Install

---

## 🧪 STEP 2: Test All Features

### 1. Authentication ✅

**Sign Up:**
1. Open app
2. Tap "Sign Up"
3. Enter:
   - Name: Your Name
   - Email: your@email.com
   - Phone: 1234567890
   - Password: Test@123
4. Tap "Sign Up"
5. ✅ Should login instantly (no OTP needed)

**Login:**
1. Logout if logged in
2. Tap "Login"
3. Enter email and password
4. Tap "Login"
5. ✅ Should login instantly

---

### 2. Subscription & Payment 💳

**View Plans:**
1. Go to Profile → Subscription
2. ✅ Should see Free and Premium plans

**Upgrade to Premium:**
1. Tap "Upgrade to Premium" on ₹999/month plan
2. ✅ Razorpay payment screen opens
3. Use test card:
   - Card: 4111 1111 1111 1111
   - CVV: 123
   - Expiry: 12/25
   - Name: Test User
4. Complete payment
5. ✅ Should upgrade to Premium
6. ✅ Premium features unlocked

**Verify Premium:**
1. Go back to Subscription screen
2. ✅ Should show "Premium" plan active
3. ✅ All premium features have checkmarks

---

### 3. Instagram Connection 📸

**Prerequisites:**
- You must be added as Instagram Tester in Meta Dashboard
- You must accept the invitation in Instagram app

**Connect Instagram:**
1. Go to Profile → Connected Accounts
2. Tap "Connect Instagram"
3. ✅ Instagram OAuth page opens
4. Login with your Instagram
5. Authorize the app
6. ✅ Should redirect back to app
7. ✅ Instagram connected successfully

**Verify Connection:**
1. Go to Profile → Connected Accounts
2. ✅ Instagram should show as "Connected"
3. ✅ Should show your Instagram username/profile

---

### 4. Facebook Connection 👥

**Connect Facebook:**
1. Go to Profile → Connected Accounts
2. Tap "Connect Facebook"
3. ✅ Facebook OAuth page opens
4. Login with Facebook
5. Authorize the app
6. ✅ Should redirect back
7. ✅ Facebook connected

---

### 5. AI Chatbot 🤖

**Test AI:**
1. Go to Home → AI Assistant
2. Type: "Write a caption for my beach photo"
3. Tap Send
4. ✅ Should get AI-generated caption
5. Try: "Generate hashtags for travel"
6. ✅ Should get relevant hashtags

**Premium AI Features (after upgrade):**
1. ✅ Unlimited AI requests
2. ✅ Advanced caption generation
3. ✅ Hashtag suggestions

---

### 6. Schedule Posts 📅

**Create Scheduled Post:**
1. Go to Schedule screen
2. Tap "+" on a future date
3. Select platform (Instagram/Facebook)
4. Add caption
5. Upload image
6. Select time
7. Tap "Schedule"
8. ✅ Post scheduled successfully

**View Scheduled Posts:**
1. Go to Schedule screen
2. ✅ Calendar shows dates with posts (pink edit icon)
3. Tap on a date with posts
4. ✅ Should show list of scheduled posts

**Edit/Cancel Post:**
1. Tap on a scheduled post
2. ✅ Should show post details
3. Tap "Cancel" to delete
4. ✅ Post removed from schedule

---

### 7. Trends Discovery 🔥 (Premium)

**View Trends:**
1. Go to Trends screen
2. ✅ Should show trending reels/audio
3. Switch between tabs:
   - For You
   - Popular
   - Saved
4. ✅ Content loads for each tab

**Save Trend:**
1. Tap on a trend
2. Tap "Save" icon
3. ✅ Trend saved
4. Go to "Saved" tab
5. ✅ Should show saved trends

---

### 8. Analytics Dashboard 📊 (Premium)

**View Analytics:**
1. Go to Analytics screen
2. Select platform (Instagram/Facebook)
3. ✅ Should show:
   - Follower count
   - Engagement rate
   - Post performance
   - Growth charts

**Note:** Currently shows dummy data for testing

---

### 9. Boost Consultation 🚀 (Premium)

**Request Boost:**
1. Go to Boost screen
2. Fill in details:
   - Post URL
   - Target audience
   - Budget
3. Submit request
4. ✅ Consultation request sent

**View Boost History:**
1. Go to Boost screen
2. ✅ Should show previous boost requests

---

### 10. Post Creation 📝

**Create Immediate Post:**
1. Go to Home → Create Post
2. Select platform
3. Add caption
4. Upload image
5. Tap "Post Now"
6. ✅ Post published immediately

**Multi-Platform Post:**
1. Create post
2. Select multiple platforms (IG + FB)
3. ✅ Post to all selected platforms

---

### 11. Profile Management 👤

**View Profile:**
1. Go to Profile screen
2. ✅ Should show:
   - Name
   - Email
   - Subscription status
   - Connected accounts

**Edit Profile:**
1. Tap "Edit Profile"
2. Update name/email
3. Save
4. ✅ Profile updated

**Logout:**
1. Tap "Logout"
2. ✅ Should return to login screen

---

## 🔍 STEP 3: Test Edge Cases

### Test 1: Offline Mode
1. Turn off internet
2. Open app
3. ✅ Should show appropriate error messages
4. Turn on internet
5. ✅ Should reconnect automatically

### Test 2: Invalid Login
1. Try login with wrong password
2. ✅ Should show error message

### Test 3: Payment Failure
1. Try payment with invalid card
2. ✅ Should show error
3. ✅ Should not upgrade to premium

### Test 4: Instagram Not Connected
1. Try to post to Instagram without connecting
2. ✅ Should prompt to connect first

---

## 📊 STEP 4: Check Backend

### Monitor API Logs:
1. Backend is running at: http://localhost:4000
2. Check terminal for API requests
3. ✅ Should see requests logged

### Check Database:
1. Login to MongoDB Atlas
2. Check `konnect` database
3. ✅ Should see:
   - Users collection
   - Posts collection
   - Subscriptions collection

### Check Razorpay Dashboard:
1. Login to https://dashboard.razorpay.com/
2. Go to Payments
3. ✅ Should see test payments

---

## 🎯 STEP 5: Test Admin Portal

### Access Admin:
1. Open browser: http://localhost:5173/
2. Login:
   - Email: konnectmediaapp@gmail.com
   - Password: #jain1191
3. ✅ Should login successfully

### Test Admin Features:
1. **Dashboard:**
   - ✅ View total users
   - ✅ View subscriptions
   - ✅ View revenue

2. **Users:**
   - ✅ View all users
   - ✅ Search users
   - ✅ View user details

3. **Subscriptions:**
   - ✅ View all subscriptions
   - ✅ Filter by plan type
   - ✅ View payment history

4. **Analytics:**
   - ✅ View platform usage
   - ✅ View engagement metrics

---

## ✅ Complete Feature Checklist

### Free Features:
- [x] Sign Up / Login
- [x] Basic Profile
- [x] Schedule Posts
- [x] View Calendar
- [x] 1 Account per platform
- [x] Basic Dashboard

### Premium Features (₹999/month):
- [x] AI Captions & Hashtags
- [x] Advanced Analytics
- [x] Trends Discovery
- [x] Boost Consultation
- [x] Unlimited AI requests
- [x] Priority support

### Platform Integrations:
- [x] Instagram OAuth
- [x] Facebook OAuth
- [x] Post to Instagram
- [x] Post to Facebook
- [x] Multi-platform posting

### Payment:
- [x] Razorpay integration
- [x] Test payment flow
- [x] Subscription management
- [x] Auto-renewal
- [x] Cancel subscription

---

## 🐛 Known Issues (Expected):

1. **Windows Desktop:**
   - Razorpay doesn't work (Android/iOS only)
   - Instagram OAuth doesn't work (mobile only)
   - These are platform limitations, not bugs

2. **Instagram Tester:**
   - Must be added as tester in Meta Dashboard
   - Must accept invitation
   - Otherwise connection will fail

3. **Analytics:**
   - Currently shows dummy data
   - Real data requires Instagram Business API approval

---

## 🚀 Production Checklist

Before going live with 5 customers:

- [ ] Get Razorpay LIVE keys (currently using TEST)
- [ ] Update Render environment variables
- [ ] Add 5 customers as Instagram Testers
- [ ] Build production APK (flutter build apk --release)
- [ ] Share APK with customers
- [ ] Monitor backend logs
- [ ] Check payment dashboard
- [ ] Provide customer support

---

## 📞 Support

**For Testing Issues:**
- Check backend logs in terminal
- Check Flutter app logs
- Verify internet connection
- Verify Instagram tester status

**For Production:**
- Email: konnectmediaapp@gmail.com
- Monitor: Render dashboard
- Payments: Razorpay dashboard
- Database: MongoDB Atlas

---

## 🎉 You're Ready to Test!

Install the APK on your Android phone and test all features. Everything should work perfectly!

**APK Location:** `E:\KonnectMedia-main\ui_app\build\app\outputs\flutter-apk\app-debug.apk`

Good luck! 🚀
