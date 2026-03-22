# 🧪 LOCAL TESTING GUIDE - KonnectMedia

## ✅ What's Already Configured

All credentials are set in `api/.env`:
- ✅ Gmail SMTP (njuqtmmdgwhmndfm)
- ✅ Razorpay Test Keys (rzp_test_STRzCGTESz1pM7)
- ✅ Instagram App (1512868990235137)
- ✅ Facebook App (940079272291310)
- ✅ OpenRouter AI (configured)
- ✅ MongoDB Atlas (connected)

Flutter app configured to use: `http://localhost:4000/api`

---

## 🚀 STEP 1: Start Backend Server

Open terminal in project root:

```bash
cd api
npm install
npm start
```

**Expected Output:**
```
🚀 Server running on http://localhost:4000
✅ MongoDB Connected
```

**Keep this terminal open!**

---

## 🧪 STEP 2: Test Backend APIs

Open browser or Postman and test:

### Test 1: Health Check
```
http://localhost:4000/api
```
Should return: API info

### Test 2: Signup (No OTP needed - bypassed)
```
POST http://localhost:4000/api/auth/signup
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test@123",
  "name": "Test User"
}
```
Should return: User created with token

### Test 3: Login
```
POST http://localhost:4000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test@123"
}
```
Should return: Login successful with token

### Test 4: AI Chat
```
POST http://localhost:4000/api/ai/chat
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN_HERE

{
  "message": "Write a caption for my post"
}
```
Should return: AI generated response

---

## 📱 STEP 3: Run Flutter App

### Option A: Android Emulator

Open new terminal:
```bash
cd ui_app
flutter pub get
flutter run
```

### Option B: Physical Android Device

1. Enable USB Debugging on phone
2. Connect via USB
3. Run:
```bash
cd ui_app
flutter devices
flutter run
```

### Option C: Build APK for Testing
```bash
cd ui_app
flutter build apk --debug
```
APK location: `ui_app/build/app/outputs/flutter-apk/app-debug.apk`

---

## ✅ STEP 4: Test All Features in App

### 1. Authentication
- [ ] Open app
- [ ] Click "Sign Up"
- [ ] Enter email, password, name
- [ ] Click "Sign Up" (no OTP needed - instant signup)
- [ ] Should login automatically

### 2. AI Chatbot
- [ ] Go to Home screen
- [ ] Click "AI Assistant" or chat icon
- [ ] Type: "Write a caption for my post"
- [ ] Should get AI response

### 3. Subscription (Test Mode)
- [ ] Go to Profile → Subscription
- [ ] Click "Upgrade to Premium"
- [ ] Razorpay payment screen should open
- [ ] Use test card: 4111 1111 1111 1111
- [ ] CVV: Any 3 digits
- [ ] Expiry: Any future date
- [ ] Should upgrade to Premium

### 4. Premium Features
After upgrading:
- [ ] AI Captions should work
- [ ] Analytics should show data
- [ ] Trends should load
- [ ] Boost should be accessible

### 5. Instagram Connection
- [ ] Go to Profile → Connected Accounts
- [ ] Click "Connect Instagram"
- [ ] Should redirect to Instagram OAuth
- [ ] Login and authorize
- [ ] Should connect successfully

**Note:** You must be added as Instagram Tester for this to work!

---

## 🔍 STEP 5: Check Instagram Testers

### Add Yourself as Tester First:

1. Go to: https://developers.facebook.com/apps/940079272291310/
2. Login with Facebook
3. Left sidebar → Click "App roles" or "Roles"
4. Scroll to "Instagram Testers"
5. Click "Add Instagram Testers"
6. Enter YOUR Instagram username
7. Click Submit

### Accept Invitation:

1. Open Instagram app on phone
2. Profile → Menu (☰) → Settings
3. Security → Apps and Websites
4. Look for "Tester Invites"
5. Find "KonnectMedia-IG"
6. Click "Accept"

### Verify:

Go back to Meta Dashboard → App roles → Instagram Testers
- If you see your username with "Active" status = ✅ Ready to test
- If "Pending" = You haven't accepted yet

---

## 🧪 STEP 6: Test Instagram Features

After connecting Instagram:

### Test Posting:
- [ ] Go to Schedule screen
- [ ] Click "+" on a future date
- [ ] Select Instagram
- [ ] Add caption, image
- [ ] Schedule post
- [ ] Should save successfully

### Test Trends:
- [ ] Go to Trends screen
- [ ] Should load Instagram reels/audio
- [ ] Click on a trend
- [ ] Should show details

### Test Analytics:
- [ ] Go to Analytics screen
- [ ] Should show dummy data (for testing)
- [ ] Charts should render

---

## 🎯 STEP 7: Test with 5 Users

### Add 5 Test Users as Instagram Testers:

1. Get Instagram usernames from your 5 customers
2. Add each one in Meta Dashboard (same process as above)
3. Each customer must accept invitation
4. Share debug APK with them for testing

### Share Debug APK:
```bash
cd ui_app
flutter build apk --debug
```

Send them: `ui_app/build/app/outputs/flutter-apk/app-debug.apk`

**Installation Instructions for Testers:**
```
1. Download APK
2. Install on Android phone
3. Open app
4. Sign up with your email
5. Go to Profile → Connect Instagram
6. Login and authorize
7. Start testing!
```

---

## 📊 Monitor Backend Logs

While testing, watch backend terminal for:
- API requests
- Errors
- Database queries
- Payment webhooks

---

## 🐛 Common Issues & Fixes

### Issue 1: Backend not starting
```bash
cd api
rm -rf node_modules
npm install
npm start
```

### Issue 2: Flutter app not connecting
- Check `ui_app/.env` has `http://localhost:4000/api`
- Restart Flutter app
- Check backend is running

### Issue 3: Instagram connection fails
- Verify you're added as tester
- Check you accepted invitation
- Ensure Instagram is Business account

### Issue 4: Razorpay test payment fails
- Use test card: 4111 1111 1111 1111
- Check Razorpay test keys in `api/.env`
- Check backend logs for errors

### Issue 5: AI not responding
- Check OpenRouter API key in `api/.env`
- Check backend logs
- Verify internet connection

---

## ✅ Local Testing Checklist

Before going to production:

- [ ] Backend starts without errors
- [ ] Signup/Login works (no OTP)
- [ ] AI chatbot responds
- [ ] Razorpay test payment works
- [ ] Instagram connection works (as tester)
- [ ] Schedule post saves
- [ ] Trends load
- [ ] Analytics shows data
- [ ] All 5 users added as Instagram testers
- [ ] All 5 users accepted invitations
- [ ] Tested with at least 2-3 users

---

## 🚀 After Local Testing Success

1. **Update Render with all environment variables**
2. **Get Razorpay LIVE keys** (if KYC approved)
3. **Build production APK:**
   ```bash
   cd ui_app
   flutter clean
   flutter pub get
   flutter build apk --release
   ```
4. **Update `ui_app/.env` back to production:**
   ```
   API_BASE_URL=https://konnectmedia-api.onrender.com/api
   ```
5. **Rebuild APK with production URL**
6. **Share with customers**

---

## 🎉 You're Ready!

Local testing ensures everything works before going live.

**Time Required:** 1-2 hours for complete testing

**Next:** Once local testing passes, deploy to production!
