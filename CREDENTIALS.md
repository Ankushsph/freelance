# 🔐 KonnectMedia - All Credentials

## 📱 Flutter App (User Login)

### Method 1: Create New Account
1. Open app
2. Tap "Sign Up"
3. Enter any email (e.g., `test@example.com`)
4. Enter password
5. Verify OTP (check backend console for OTP)
6. Login

### Method 2: Use Existing Account
If you already created an account, use those credentials.

---

## 👨‍💼 Admin Portal

**URL:** http://localhost:5173

**Credentials:**
```
Email: konnectmediaapp@gmail.com
Password: #jain1191
```

**Note:** Email is case-insensitive now - works with both:
- `konnectmediaapp@gmail.com` ✅
- `Konnectmediaapp@gmail.com` ✅
- `KONNECTMEDIAAPP@GMAIL.COM` ✅

---

## 🗄️ Database

**MongoDB Atlas:**
```
URI: mongodb+srv://ankush:ankush66@cluster0.wvivwbg.mongodb.net/konnect
Database: konnect
```

**Collections:**
- users
- posts
- subscriptions
- trends
- conversations
- messages
- announcements
- tickets
- boosts

---

## 🔑 API Keys (Current Status)

### OpenRouter AI (✅ Active)
```
API Key: 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
Model: meta-llama/llama-3.2-1b-instruct:free
```

### Razorpay (✅ Test Keys Added)
```
Key ID: rzp_test_STRzCGTESz1pM7
Key Secret: GkvoEbJBuLKx11r2zHt14XhC
Status: Test mode - ready for testing on Android devices
```

**Test Cards:**
- Success: 4111 1111 1111 1111 (CVV: 123, Expiry: 12/25)
- Failure: 4000 0000 0000 0002
- UPI: success@razorpay

### Instagram API (⚠️ Needs Setup)
```
Client ID: your_instagram_app_id (placeholder)
Client Secret: your_instagram_app_secret (placeholder)
Redirect URI: http://localhost:4000/api/callback/instagram
Status: Needs Meta Developer credentials
```

### Facebook API (⚠️ Needs Setup)
```
Client ID: your_facebook_app_id (placeholder)
Client Secret: your_facebook_app_secret (placeholder)
Redirect URI: http://localhost:4000/api/callback/facebook
Status: Needs Meta Developer credentials
```

### LinkedIn API (❌ Disabled)
```
Status: Disabled in .env (ENABLE_LINKEDIN=false)
```

### Twitter/X API (❌ Disabled)
```
Status: Disabled in .env (ENABLE_TWITTER=false)
```

---

## 🚀 Service URLs

### Backend API
```
URL: http://localhost:4000
Status: Running
Health Check: http://localhost:4000/api/health
```

### Admin Portal
```
URL: http://localhost:5173
Status: Running
Login: konnectmediaapp@gmail.com / #jain1191
```

### Flutter App
```
Platform: Windows Desktop
Status: Running
Backend: http://localhost:4000
```

---

## 🧪 Test Accounts

### Premium User (Demo)
After clicking "Upgrade Now" in app:
- Plan: Premium
- Status: Active
- Expires: 30 days from activation
- Features: All unlocked

### Free User (Default)
Any new signup:
- Plan: Free
- Status: Active
- Features: Schedule, Basic Dashboard

---

## 📝 Environment Variables

**Location:** `api/.env`

**Current Configuration:**
```bash
# Server
PORT=4000
PUBLIC_URL=http://localhost:4000

# Database
MONGO_URI=mongodb+srv://ankush:ankush66@cluster0.wvivwbg.mongodb.net/konnect?retryWrites=true&w=majority&appName=Cluster0

# Auth
JWT_SECRET=konnect_dev_secret_key_2024_change_in_production

# Email (Placeholder)
MAIL_USER=konnectapp.test@gmail.com
MAIL_PASS=test_app_password
ADMIN_EMAIL=admin@konnectapp.com

# AI
OPENROUTER_API_KEY=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
OPENROUTER_MODEL=meta-llama/llama-3.2-1b-instruct:free

# Social Media (Placeholders)
INSTAGRAM_CLIENT_ID=your_instagram_app_id
INSTAGRAM_CLIENT_SECRET=your_instagram_app_secret
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret

# Payment (Demo Mode)
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Feature Flags
ENABLE_INSTAGRAM=true
ENABLE_FACEBOOK=true
ENABLE_LINKEDIN=false
ENABLE_TWITTER=false
```

---

## 🔧 Quick Start Commands

### Start Backend
```bash
cd api
npm run dev:tsx
```

### Start Admin Portal
```bash
cd admin
npm run dev
```

### Start Flutter App
```bash
cd ui_app
flutter run -d windows
```

---

## 🐛 Troubleshooting

### Admin Login Not Working
- Make sure you're using: `konnectmediaapp@gmail.com` (lowercase k)
- Password: `#jain1191` (exact match, case-sensitive)
- Clear browser cache if needed

### App Features Not Showing After Premium Upgrade
- Close and reopen the app
- Subscription should load automatically
- Check "My Subscription" to verify Premium status

### Backend Not Starting
- Check if port 4000 is available
- Verify MongoDB connection
- Check `.env` file exists

### Flutter App Razorpay Errors
- Normal on Windows desktop
- Razorpay only works on Android/iOS
- Demo mode bypasses Razorpay

---

## 📊 Database Access

### Using MongoDB Compass
```
Connection String: mongodb+srv://ankush:ankush66@cluster0.wvivwbg.mongodb.net/konnect
```

### Using MongoDB Atlas Web
1. Go to: https://cloud.mongodb.com/
2. Login with: ankush / ankush66
3. Select: Cluster0
4. Browse Collections

---

## 🎯 Summary

✅ **Admin Portal:** konnectmediaapp@gmail.com / #jain1191
✅ **Backend API:** http://localhost:4000
✅ **Admin Web:** http://localhost:5173
✅ **Database:** MongoDB Atlas (connected)
✅ **Subscription:** Demo mode (no payment needed)
⚠️ **Social APIs:** Need Meta Developer credentials
⚠️ **Payment:** Demo mode (Razorpay credentials needed for production)

---

Need help with anything? All services are running and ready to test!
