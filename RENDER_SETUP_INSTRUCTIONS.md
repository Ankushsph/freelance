# Render Environment Variables Setup

## 🔒 Security Note
Your environment variables are stored locally in `api/.env` file. 
**Never commit this file to Git!**

## 📋 Setup Instructions

### Step 1: Go to Render Dashboard
1. Visit: https://dashboard.render.com
2. Sign in
3. Click on your backend service: **konnectmedia-api**
4. Click **"Environment"** tab on the left

### Step 2: Copy Variables from Local .env

1. Open your local file: `api/.env`
2. For each variable in that file, add it to Render:
   - Click "Add Environment Variable"
   - Copy the KEY from .env
   - Copy the VALUE from .env
   - Click "Add"

### Step 3: Required Variables (32 total)

Make sure you have all these variables from your `api/.env` file:

#### Server Configuration (2)
- PORT
- PUBLIC_URL

#### Database (1)
- MONGO_URI

#### Authentication (1)
- JWT_SECRET

#### Email Service (3)
- MAIL_USER
- MAIL_PASS
- ADMIN_EMAIL

#### AI Service (2)
- OPENROUTER_API_KEY
- OPENROUTER_MODEL

#### Instagram API (3)
- INSTAGRAM_CLIENT_ID
- INSTAGRAM_CLIENT_SECRET
- INSTAGRAM_REDIRECT_URI

#### Facebook API (4)
- FACEBOOK_CLIENT_ID
- FACEBOOK_CLIENT_SECRET
- FACEBOOK_REDIRECT_URI
- FACEBOOK_API_VERSION

#### LinkedIn API (3)
- LINKEDIN_CLIENT_ID
- LINKEDIN_CLIENT_SECRET
- LINKEDIN_REDIRECT_URI

#### Twitter API (3)
- TWITTER_CLIENT_ID
- TWITTER_CLIENT_SECRET
- TWITTER_REDIRECT_URI

#### Razorpay Payment (2)
- RAZORPAY_KEY_ID
- RAZORPAY_KEY_SECRET

#### Feature Flags (4)
- ENABLE_INSTAGRAM
- ENABLE_FACEBOOK
- ENABLE_LINKEDIN
- ENABLE_TWITTER

#### Production Settings (4)
- NODE_ENV
- LOG_LEVEL
- RATE_LIMIT_WINDOW_MS
- RATE_LIMIT_MAX_REQUESTS

### Step 4: Save and Deploy
1. After adding all 32 variables, click **"Save Changes"**
2. Render will automatically redeploy (2-3 minutes)
3. Check logs to ensure deployment succeeds

---

## ✅ Verification

After deployment:
1. Visit: https://konnectmedia-api.onrender.com
2. Test in KonnectMedia app
3. Try connecting social accounts

---

## 🆘 Need Help?

If you need the exact values:
1. Check your local `api/.env` file
2. All values are there
3. Copy them one by one to Render

**Your app is production-ready!** 🚀
