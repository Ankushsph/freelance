# 🏠 Localhost Testing Guide

Complete guide to test everything on your local machine before deploying.

---

## 📋 Prerequisites

Make sure you have:
- ✅ Node.js installed
- ✅ Flutter installed
- ✅ MongoDB connection (already configured)
- ✅ Razorpay test keys (already added to `.env`)

---

## 🚀 Step 1: Start Backend Server

### Open Terminal 1:

```bash
cd E:\KonnectMedia-main\api
npm install
npm run dev:tsx
```

**Expected Output:**
```
🚀 Server running on http://localhost:4000
✅ MongoDB Connected
```

**If you see errors:**
- Check if port 4000 is already in use
- Make sure MongoDB URI is correct in `.env`
- Check if all dependencies are installed

**Keep this terminal running!**

---

## 🎨 Step 2: Start Admin Portal (Optional)

### Open Terminal 2:

```bash
cd E:\KonnectMedia-main\admin
npm install
npm run dev
```

**Expected Output:**
```
VITE ready in XXX ms
Local: http://localhost:5173
```

**Test Admin Portal:**
1. Open browser: http://localhost:5173
2. Login with:
   - Email: `konnectmediaapp@gmail.com`
   - Password: `#jain1191`
3. You should see the dashboard

**Keep this terminal running if you want to use admin portal!**

---

## 📱 Step 3: Update Flutter App to Use Localhost

### Update Backend URL:

Open `ui_app/.env` and change:

**FROM:**
```env
API_BASE_URL=https://konnectmedia-api.onrender.com/api
```

**TO:**
```env
API_BASE_URL=http://localhost:4000/api
```

---

## 🏃 Step 4: Run Flutter App

### Open Terminal 3:

```bash
cd E:\KonnectMedia-main\ui_app
flutter run -d windows
```

**Expected Output:**
```
Launching lib\main.dart on Windows in debug mode...
Built build\windows\x64\runner\Debug\ui_app.exe
```

**App will open on Windows desktop**

---

## ✅ Step 5: Test Features on Localhost

### Test 1: Signup/Login
1. Open app
2. Click "Sign up"
3. Fill in details:
   - Name: Test User
   - Email: test@example.com
   - Mobile: 1234567890
   - Password: test123
4. Click "Sign up"
5. ✅ Should create account instantly (no OTP)
6. ✅ Should navigate to home screen

### Test 2: Premium Upgrade
1. Go to Profile (bottom nav)
2. Click "My Subscription"
3. Click "Upgrade Now" on Premium plan
4. ✅ Should show "Premium subscription activated! (Demo Mode)"
5. ✅ Premium features should unlock

### Test 3: AI Chatbot (Premium Feature)
1. After upgrading to Premium
2. Go to home screen
3. Click "AI Bot" card
4. Type a message: "Hello"
5. ✅ AI should respond (using OpenRouter API)

### Test 4: Trends (Premium Feature)
1. After upgrading to Premium
2. Go to home screen
3. Click "Trends" card
4. ✅ Should show trending reels and audio
5. Browse "For You", "Popular", "Saved" tabs

### Test 5: Analytics (Premium Feature)
1. After upgrading to Premium
2. Go to home screen
3. Click "Analytics" card
4. ✅ Should show dummy analytics data

### Test 6: Schedule Posts
1. Go to Schedule tab (bottom nav)
2. Click "+" button on any future date
3. Fill in post details
4. ✅ Should save post to schedule

---

## 🔍 Step 6: Check Backend Logs

In Terminal 1 (backend), you should see logs like:

```
🔍 SIGNUP REQUEST: { name: 'Test User', email: 'test@example.com', ... }
✅ Creating new user: test@example.com
✅ User created successfully: 507f1f77bcf86cd799439011
```

This confirms backend is working!

---

## 🧪 Step 7: Test Razorpay (Demo Mode)

Currently in demo mode, so no real Razorpay screen appears.

**To test real Razorpay:**
1. You need Android device (Razorpay doesn't work on Windows)
2. Build APK and install on Android
3. Then real Razorpay payment screen will appear

**For now, demo mode is perfect for testing!**

---

## 🛠️ Troubleshooting

### Backend won't start:
```bash
# Check if port 4000 is in use
netstat -ano | findstr :4000

# Kill the process if needed
taskkill /PID <process_id> /F

# Try starting again
npm run dev:tsx
```

### Flutter app can't connect to backend:
1. Make sure backend is running (Terminal 1)
2. Check `ui_app/.env` has `http://localhost:4000/api`
3. Restart Flutter app

### MongoDB connection error:
1. Check internet connection
2. Verify MongoDB URI in `api/.env`
3. Check MongoDB Atlas dashboard

### Admin portal won't start:
```bash
cd admin
rm -rf node_modules
npm install
npm run dev
```

---

## 📊 What to Check

### Backend Health Check:
Open browser: http://localhost:4000/api/health

Should return:
```json
{
  "status": "ok",
  "message": "API is running"
}
```

### Test API Endpoints:

**Get Trends:**
```
GET http://localhost:4000/api/trends?platform=instagram&category=all
```

**Get Analytics:**
```
GET http://localhost:4000/api/analytics/dummy
```

You can test these in browser or Postman.

---

## 🎯 Success Checklist

- [ ] Backend running on http://localhost:4000
- [ ] Admin portal running on http://localhost:5173 (optional)
- [ ] Flutter app running on Windows
- [ ] Can signup/login without OTP
- [ ] Can upgrade to Premium (demo mode)
- [ ] AI chatbot responds
- [ ] Trends show data
- [ ] Analytics show data
- [ ] Can schedule posts

---

## 🔄 After Testing Locally

Once everything works on localhost:

1. **Update Flutter app back to production URL:**
   ```env
   API_BASE_URL=https://konnectmedia-api.onrender.com/api
   ```

2. **Build APK for Android testing:**
   ```bash
   flutter build apk --release
   ```

3. **Update Render environment variables** with Razorpay keys

4. **Test on Android device** for real Razorpay integration

---

## 💡 Tips

1. **Keep terminals organized:**
   - Terminal 1: Backend
   - Terminal 2: Admin (optional)
   - Terminal 3: Flutter app

2. **Check logs frequently:**
   - Backend logs show API requests
   - Flutter console shows app errors

3. **Use hot reload:**
   - Press `r` in Flutter terminal for hot reload
   - Press `R` for hot restart

4. **Test incrementally:**
   - Test one feature at a time
   - Check backend logs after each action

---

Ready to start? Let me know if you need help with any step!
