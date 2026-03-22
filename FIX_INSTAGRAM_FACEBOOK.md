# 🔧 Fix Instagram & Facebook API Connection

## 🎯 Current Issue

The Instagram and Facebook APIs are configured in the backend, but the redirect URIs need to be properly set up in Meta Developer Dashboard to work with localhost.

---

## ✅ STEP 1: Configure Instagram App in Meta Dashboard

### 1.1 Go to Instagram App Settings
1. Open: https://developers.facebook.com/apps/1512868990235137/
2. Login with your Facebook account
3. Click on "Instagram" in left sidebar
4. Click "Basic Display" or "Instagram Basic Display"

### 1.2 Add Redirect URIs
1. Find "Valid OAuth Redirect URIs" section
2. Add these URLs:
   ```
   http://localhost:4000/api/callback/instagram
   http://localhost:4000/api/instagram/callback
   https://konnectmedia-api.onrender.com/api/callback/instagram
   https://konnectmedia-api.onrender.com/api/instagram/callback
   ```
3. Click "Save Changes"

### 1.3 Add Deauthorize Callback URL
1. Find "Deauthorize Callback URL"
2. Add: `http://localhost:4000/api/instagram/deauthorize`
3. Click "Save Changes"

### 1.4 Add Data Deletion Request URL
1. Find "Data Deletion Request URL"
2. Add: `http://localhost:4000/api/instagram/data-deletion`
3. Click "Save Changes"

---

## ✅ STEP 2: Configure Facebook App in Meta Dashboard

### 2.1 Go to Facebook App Settings
1. Open: https://developers.facebook.com/apps/940079272291310/
2. Click on "Facebook Login" in left sidebar
3. Click "Settings"

### 2.2 Add Redirect URIs
1. Find "Valid OAuth Redirect URIs" section
2. Add these URLs:
   ```
   http://localhost:4000/api/callback/facebook
   http://localhost:4000/api/facebook/callback
   https://konnectmedia-api.onrender.com/api/callback/facebook
   https://konnectmedia-api.onrender.com/api/facebook/callback
   ```
3. Click "Save Changes"

### 2.3 Configure Client OAuth Settings
1. Scroll to "Client OAuth Settings"
2. Enable:
   - ✅ Client OAuth Login
   - ✅ Web OAuth Login
   - ✅ Force Web OAuth Reauthentication
3. Click "Save Changes"

---

## ✅ STEP 3: Update Backend Environment Variables

Your `.env` file already has the correct values:

```env
# Instagram
INSTAGRAM_CLIENT_ID=1512868990235137
INSTAGRAM_CLIENT_SECRET=8428a27ff30d4b008ccb4dedde726748
INSTAGRAM_REDIRECT_URI=http://localhost:4000/api/callback/instagram

# Facebook
FACEBOOK_CLIENT_ID=940079272291310
FACEBOOK_CLIENT_SECRET=3fdc5523ee8bd55a57ff60719d01ff5f
FACEBOOK_REDIRECT_URI=http://localhost:4000/api/callback/facebook
```

✅ No changes needed!

---

## ✅ STEP 4: Test Instagram Connection

### 4.1 In Chrome App (http://localhost:3000)
1. Login to the app
2. Go to Profile → Connected Accounts
3. Click "Connect Instagram"
4. ✅ Should redirect to Instagram OAuth page
5. Login with your Instagram
6. Authorize the app
7. ✅ Should redirect back with success message

### 4.2 Verify Connection
1. Go back to app
2. Refresh the page
3. Go to Profile → Connected Accounts
4. ✅ Instagram should show as "Connected"

---

## ✅ STEP 5: Test Facebook Connection

### 5.1 In Chrome App
1. Go to Profile → Connected Accounts
2. Click "Connect Facebook"
3. ✅ Should redirect to Facebook OAuth page
4. Login with Facebook
5. Authorize the app
6. ✅ Should redirect back with success message

### 5.2 Verify Connection
1. Go back to app
2. Refresh the page
3. Go to Profile → Connected Accounts
4. ✅ Facebook should show as "Connected"

---

## ✅ STEP 6: Fix Analytics Data

The analytics are currently showing dummy data. To get real data:

### Option 1: Use Dummy Data (Current)
- Already implemented
- Shows realistic sample data
- Good for testing UI/UX

### Option 2: Connect Real Instagram Business API
1. Convert Instagram account to Business account
2. Connect to Facebook Page
3. Request Instagram Graph API permissions
4. Wait for Meta approval (1-2 weeks)
5. Update backend to fetch real analytics

**For now, dummy data is fine for testing!**

---

## 🐛 Common Issues & Fixes

### Issue 1: "Redirect URI Mismatch"
**Fix:** Make sure the redirect URI in Meta Dashboard EXACTLY matches the one in `.env`

### Issue 2: "App Not Approved"
**Fix:** Add yourself as a tester in Meta Dashboard:
1. Go to App Roles → Roles
2. Add yourself as "Administrator" or "Developer"
3. For Instagram: Add as "Instagram Tester"

### Issue 3: "Invalid OAuth State"
**Fix:** Clear browser cookies and try again

### Issue 4: "Access Token Invalid"
**Fix:** 
1. Disconnect the account
2. Reconnect with fresh OAuth flow

---

## 📊 Check Backend Logs

While testing, watch the backend terminal for logs:

```
[Instagram] Exchanging code for token...
[Instagram] Fetching user profile...
[Instagram] User 123abc connected successfully
```

If you see errors, they'll show here!

---

## ✅ Verification Checklist

After completing all steps:

- [ ] Instagram redirect URIs added in Meta Dashboard
- [ ] Facebook redirect URIs added in Meta Dashboard
- [ ] Backend is running (http://localhost:4000)
- [ ] Chrome app is running (http://localhost:3000)
- [ ] Can click "Connect Instagram" button
- [ ] Instagram OAuth page opens
- [ ] Can authorize and redirect back
- [ ] Instagram shows as "Connected"
- [ ] Can click "Connect Facebook" button
- [ ] Facebook OAuth page opens
- [ ] Can authorize and redirect back
- [ ] Facebook shows as "Connected"

---

## 🎯 Expected Behavior After Fix

### Instagram Connected:
- ✅ Profile shows Instagram username
- ✅ Can view Instagram analytics (dummy data)
- ✅ Can schedule posts to Instagram
- ✅ Can post immediately to Instagram

### Facebook Connected:
- ✅ Profile shows Facebook name
- ✅ Can select Facebook Page
- ✅ Can schedule posts to Facebook
- ✅ Can post immediately to Facebook

---

## 🚀 Next Steps

1. **Complete Steps 1-2** in Meta Dashboard (5 minutes)
2. **Test connections** in Chrome app (2 minutes)
3. **Verify** everything works
4. **Start testing** post scheduling and publishing!

---

## 💡 Pro Tips

1. **Use Chrome DevTools** to see network requests and errors
2. **Check backend logs** for detailed error messages
3. **Clear browser cache** if OAuth flow gets stuck
4. **Test on mobile** for full Instagram/Facebook experience

---

## 📞 Still Having Issues?

If connections still fail after following this guide:

1. Check backend logs for specific error messages
2. Verify all redirect URIs match exactly
3. Ensure you're added as a tester in Meta Dashboard
4. Try using incognito/private browsing mode
5. Check if Instagram account is Business account

---

The APIs are properly configured in the backend. You just need to add the redirect URIs in Meta Dashboard and you're good to go! 🎉
