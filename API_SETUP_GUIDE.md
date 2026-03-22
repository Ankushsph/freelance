# 🔑 Complete API Setup Guide - KonnectMedia

This guide will walk you through getting ALL the API keys and credentials needed for the project.

---

## 📋 What You Need to Collect

1. ✅ OpenRouter AI API (Already configured)
2. ⚠️ Razorpay Payment Gateway
3. ⚠️ Instagram/Facebook API (Meta)
4. ⚠️ Twitter/X API
5. ⚠️ LinkedIn API
6. ✅ Gmail SMTP (Already configured)
7. ✅ MongoDB (Already configured)

---

## 1. ✅ OpenRouter AI API (DONE)

**Status:** Already configured and working

**Current Key:** `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`

**No action needed** - This is working!

---

## 2. 💳 Razorpay Payment Gateway (REQUIRED FOR REAL PAYMENTS)

**Current Status:** Demo mode active (bypassed)

**When to set up:** When you want real payment processing

### Step-by-Step:

#### Step 1: Create Razorpay Account
1. Go to: https://razorpay.com/
2. Click "Sign Up" (top right)
3. Choose "I'm a Business Owner"
4. Fill in details:
   - Business Name: KonnectMedia
   - Email: konnectmediaapp@gmail.com
   - Phone: Your business phone
5. Verify email and phone

#### Step 2: Complete KYC
1. After login, go to "Settings" → "Account & Settings"
2. Complete KYC verification:
   - Business PAN card
   - Business address proof
   - Bank account details
3. Wait for approval (1-2 business days)

#### Step 3: Get API Keys
1. Go to "Settings" → "API Keys"
2. Click "Generate Test Keys" (for testing)
3. Copy:
   - **Key ID** (starts with `rzp_test_`)
   - **Key Secret** (starts with `rzp_test_`)
4. For production, click "Generate Live Keys" after KYC approval

#### Step 4: Add to Project
Update `api/.env`:
```env
RAZORPAY_KEY_ID=rzp_test_XXXXXXXXXXXX
RAZORPAY_KEY_SECRET=XXXXXXXXXXXXXXXX
```

#### Step 5: Remove Demo Mode
In `ui_app/lib/screens/subscription/subscription_screen.dart`:
- Uncomment the Razorpay code (lines marked with `// ORIGINAL RAZORPAY CODE`)
- Remove the demo payment code

**Cost:** Free for testing, 2% transaction fee for live payments

---

## 3. 📱 Instagram/Facebook API (Meta Developer)

**Current Status:** Placeholders only

**Required for:** Posting to Instagram/Facebook, fetching profiles

### Step-by-Step:

#### Step 1: Create Meta Developer Account
1. Go to: https://developers.facebook.com/
2. Click "Get Started" (top right)
3. Login with Facebook account (or create one)
4. Complete registration:
   - Accept terms
   - Verify email

#### Step 2: Create App
1. Click "My Apps" → "Create App"
2. Choose "Business" type
3. Fill in details:
   - App Name: KonnectMedia
   - Contact Email: konnectmediaapp@gmail.com
   - Business Account: Create new or select existing
4. Click "Create App"

#### Step 3: Add Instagram Basic Display
1. In your app dashboard, click "Add Product"
2. Find "Instagram Basic Display" → Click "Set Up"
3. Click "Create New App" → "Create App"
4. Go to "Basic Display" → "Settings"
5. Fill in:
   - **Valid OAuth Redirect URIs:**
     ```
     https://konnectmedia-api.onrender.com/api/callback/instagram
     http://localhost:4000/api/callback/instagram
     ```
   - **Deauthorize Callback URL:**
     ```
     https://konnectmedia-api.onrender.com/api/callback/instagram/deauth
     ```
   - **Data Deletion Request URL:**
     ```
     https://konnectmedia-api.onrender.com/api/callback/instagram/delete
     ```
6. Click "Save Changes"
7. Copy:
   - **Instagram App ID**
   - **Instagram App Secret**

#### Step 4: Add Facebook Login
1. In app dashboard, click "Add Product"
2. Find "Facebook Login" → Click "Set Up"
3. Choose "Web" platform
4. Enter Site URL: `https://konnectmedia-api.onrender.com`
5. Go to "Facebook Login" → "Settings"
6. Add Valid OAuth Redirect URIs:
   ```
   https://konnectmedia-api.onrender.com/api/callback/facebook
   http://localhost:4000/api/callback/facebook
   ```
7. Click "Save Changes"

#### Step 5: Get App Credentials
1. Go to "Settings" → "Basic"
2. Copy:
   - **App ID**
   - **App Secret** (click "Show")

#### Step 6: Add to Project
Update `api/.env`:
```env
# Instagram
INSTAGRAM_CLIENT_ID=your_instagram_app_id
INSTAGRAM_CLIENT_SECRET=your_instagram_app_secret

# Facebook
FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret
```

#### Step 7: Submit for Review (For Production)
1. Go to "App Review" → "Permissions and Features"
2. Request these permissions:
   - `instagram_basic`
   - `instagram_content_publish`
   - `pages_read_engagement`
   - `pages_manage_posts`
3. Provide:
   - App description
   - Privacy policy URL
   - Demo video showing app usage
4. Wait for approval (1-2 weeks)

**Cost:** Free

**Note:** Test mode works with your own account only. Production requires review.

---

## 4. 🐦 Twitter/X API

**Current Status:** Disabled (ENABLE_TWITTER=false)

**Required for:** Posting to Twitter/X, fetching profiles

### Step-by-Step:

#### Step 1: Create Twitter Developer Account
1. Go to: https://developer.twitter.com/
2. Click "Sign up" (top right)
3. Login with Twitter account
4. Click "Apply for a developer account"
5. Choose "Hobbyist" → "Making a bot"
6. Fill in details:
   - Account name: KonnectMedia
   - Primary use: Building a social media management tool
   - Describe in detail: "Social media scheduling and management platform for businesses"
7. Accept terms and submit

#### Step 2: Wait for Approval
- Check email for approval (usually 1-2 days)
- May need to provide more details

#### Step 3: Create Project & App
1. After approval, go to Developer Portal
2. Click "Projects & Apps" → "Create Project"
3. Fill in:
   - Project Name: KonnectMedia
   - Use Case: Making a bot
   - Description: Social media management platform
4. Click "Next" → "Create App"
5. App Name: konnectmedia-app

#### Step 4: Get API Keys
1. After creating app, you'll see:
   - **API Key** (Client ID)
   - **API Secret Key** (Client Secret)
   - **Bearer Token**
2. Copy and save these securely

#### Step 5: Set Up OAuth 2.0
1. Go to your app settings
2. Click "User authentication settings" → "Set up"
3. Enable "OAuth 2.0"
4. App permissions: "Read and write"
5. Type of App: "Web App"
6. Fill in:
   - **Callback URI:**
     ```
     https://konnectmedia-api.onrender.com/api/callback/twitter
     http://localhost:4000/api/callback/twitter
     ```
   - **Website URL:** `https://konnectmedia-api.onrender.com`
7. Click "Save"

#### Step 6: Add to Project
Update `api/.env`:
```env
TWITTER_CLIENT_ID=your_twitter_api_key
TWITTER_CLIENT_SECRET=your_twitter_api_secret
ENABLE_TWITTER=true
```

**Cost:** 
- Free tier: 1,500 tweets/month
- Basic: $100/month for more features
- Pro: $5,000/month for full access

**Note:** Free tier is very limited. Consider if you really need Twitter integration.

---

## 5. 💼 LinkedIn API

**Current Status:** Disabled (ENABLE_LINKEDIN=false)

**Required for:** Posting to LinkedIn, fetching profiles

### Step-by-Step:

#### Step 1: Create LinkedIn App
1. Go to: https://www.linkedin.com/developers/
2. Click "Create app"
3. Fill in:
   - App name: KonnectMedia
   - LinkedIn Page: (You need a LinkedIn Company Page first)
   - Privacy policy URL: Your privacy policy
   - App logo: Upload logo
4. Check "I have read and agree to these terms"
5. Click "Create app"

#### Step 2: Create LinkedIn Company Page (If you don't have one)
1. Go to: https://www.linkedin.com/company/setup/new/
2. Fill in company details
3. Create page (free)

#### Step 3: Verify App
1. After creating app, go to "Settings" tab
2. Click "Verify" next to your company page
3. LinkedIn will generate a verification URL
4. Add this URL to your company page
5. Click "Verify"

#### Step 4: Request API Access
1. Go to "Products" tab
2. Request access to:
   - "Sign In with LinkedIn"
   - "Share on LinkedIn"
3. Fill in use case details
4. Wait for approval (1-2 weeks)

#### Step 5: Get Credentials
1. Go to "Auth" tab
2. Copy:
   - **Client ID**
   - **Client Secret**
3. Add Redirect URLs:
   ```
   https://konnectmedia-api.onrender.com/api/callback/linkedin
   http://localhost:4000/api/callback/linkedin
   ```

#### Step 6: Add to Project
Update `api/.env`:
```env
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
ENABLE_LINKEDIN=true
```

**Cost:** Free

**Note:** Requires company page and verification. Approval can take time.

---

## 6. ✅ Gmail SMTP (DONE)

**Status:** Already configured

**Current Credentials:**
- Email: konnectmediaapp@gmail.com
- App Password: njuqtmmdgwhmndfm

**No action needed** - This is working!

---

## 7. ✅ MongoDB Atlas (DONE)

**Status:** Already configured and connected

**Current Connection:**
```
URI: mongodb+srv://ankush:ankush66@cluster0.wvivwbg.mongodb.net/konnect
```

**No action needed** - This is working!

---

## 📝 Priority Order

Based on importance, here's the recommended order:

### High Priority (Do First):
1. ✅ OpenRouter AI - DONE
2. ✅ MongoDB - DONE
3. ✅ Gmail SMTP - DONE
4. 💳 **Razorpay** - Needed for real payments (currently in demo mode)

### Medium Priority (Do When Ready):
5. 📱 **Meta (Instagram/Facebook)** - Most users will want this
6. 🐦 **Twitter/X** - If you need Twitter integration

### Low Priority (Optional):
7. 💼 **LinkedIn** - Less commonly used, takes time to approve

---

## 🎯 Quick Start Recommendation

**For immediate testing:**
- Everything works in demo mode
- You can test all features without real API keys
- Premium subscription works (bypassed)
- AI chatbot works (OpenRouter configured)

**For production:**
1. Set up Razorpay first (for real payments)
2. Then Meta APIs (Instagram/Facebook are most popular)
3. Twitter/LinkedIn only if specifically needed

---

## 📞 Support Links

- **Razorpay Support:** https://razorpay.com/support/
- **Meta Developer Support:** https://developers.facebook.com/support/
- **Twitter Developer Support:** https://developer.twitter.com/en/support
- **LinkedIn Developer Support:** https://www.linkedin.com/help/linkedin/answer/a1342443

---

## ⚠️ Important Notes

1. **Test Mode First:** Always use test/sandbox keys first before going live
2. **Keep Secrets Safe:** Never commit API keys to GitHub
3. **Environment Variables:** Always use `.env` file for credentials
4. **Rate Limits:** Each API has rate limits - check documentation
5. **Costs:** Most APIs are free for testing, but have costs for production use

---

## 🔄 After Getting API Keys

Once you have the keys:

1. Update `api/.env` file with new credentials
2. Restart backend server
3. Test each integration
4. Let me know if you need help configuring anything

---

Need help with any specific API setup? Let me know which one you want to start with!
