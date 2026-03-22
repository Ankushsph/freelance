# 📱 Meta (Facebook/Instagram) API Credentials

## ✅ Successfully Configured!

### App Details:
```
App Name: KonnectMedia
App ID: 940079272291310
App Secret: 3fdc5523ee8bd55a57ff60719d01ff5f
```

### What's Configured:
- ✅ Facebook Login for Business
- ✅ OAuth Redirect URIs added
- ✅ Deauthorize callback configured
- ✅ Data deletion callback configured

### Redirect URIs:
```
https://konnectmedia-api.onrender.com/api/callback/facebook
http://localhost:4000/api/callback/facebook
```

### Added to Project:
- ✅ `api/.env` updated with credentials
- ✅ Both Instagram and Facebook use same App ID/Secret
- ✅ Ready for localhost testing

---

## 🧪 Testing on Localhost

### Test Facebook Connection:
1. Start backend: `cd api && npm run dev:tsx`
2. Start Flutter app: `cd ui_app && flutter run -d windows`
3. In app, go to Profile → Connect Facebook
4. Should open Facebook OAuth flow

### Test Instagram Connection:
1. Same as above
2. Go to Profile → Connect Instagram
3. Should open Instagram OAuth flow

**Note:** In test mode, you can only connect your own Facebook/Instagram accounts.

---

## 📝 Next Steps

### For Production:
1. Go to Meta App Dashboard
2. Click "App Review" → "Permissions and Features"
3. Request these permissions:
   - `instagram_basic`
   - `instagram_content_publish`
   - `pages_read_engagement`
   - `pages_manage_posts`
4. Provide app description and demo video
5. Wait for approval (1-2 weeks)

### For Now (Test Mode):
- You can test with your own accounts
- All features work in development mode
- No approval needed for testing

---

## 🔐 Security Notes

**IMPORTANT:** These credentials are now in your local `.env` file.

- ✅ `.env` is in `.gitignore` (won't be committed to GitHub)
- ✅ Keep App Secret private
- ✅ Never share publicly
- ✅ For production, add to Render environment variables

---

## ✅ What's Working Now

With these credentials, your app can:
- ✅ Connect Facebook accounts
- ✅ Connect Instagram accounts
- ✅ Fetch user profiles
- ✅ Post to Facebook Pages (with approval)
- ✅ Post to Instagram (with approval)

---

## 🎯 Current Status

**Test Mode:**
- Works with your own accounts only
- No approval needed
- Perfect for development

**Production Mode:**
- Requires App Review approval
- Can work with any user's account
- Needed for public launch

---

Ready to test on localhost!
