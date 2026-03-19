# 🚀 Admin Portal Deployment Guide

## Deploy to Vercel (Recommended - Free)

### Step 1: Sign Up / Login to Vercel
1. Go to https://vercel.com
2. Sign up with GitHub account
3. Authorize Vercel to access your GitHub repositories

### Step 2: Import Project
1. Click "Add New..." → "Project"
2. Select your repository: `Ankushsph/freelance`
3. Click "Import"

### Step 3: Configure Project
1. **Framework Preset:** Vite
2. **Root Directory:** `admin` (IMPORTANT!)
3. **Build Command:** `npm run build`
4. **Output Directory:** `dist`
5. **Install Command:** `npm install`

### Step 4: Environment Variables
Add this environment variable:
```
VITE_API_URL=https://konnectmedia-api.onrender.com/api
```

### Step 5: Deploy
1. Click "Deploy"
2. Wait 2-3 minutes for build to complete
3. Your admin portal will be live!

### Step 6: Get Your URL
After deployment, you'll get a URL like:
```
https://your-project-name.vercel.app
```

---

## Alternative: Deploy to Netlify (Also Free)

### Step 1: Sign Up / Login to Netlify
1. Go to https://netlify.com
2. Sign up with GitHub account

### Step 2: Import Project
1. Click "Add new site" → "Import an existing project"
2. Choose GitHub
3. Select repository: `Ankushsph/freelance`

### Step 3: Configure Build Settings
1. **Base directory:** `admin`
2. **Build command:** `npm run build`
3. **Publish directory:** `admin/dist`

### Step 4: Environment Variables
Go to Site settings → Environment variables → Add:
```
VITE_API_URL=https://konnectmedia-api.onrender.com/api
```

### Step 5: Deploy
1. Click "Deploy site"
2. Wait for build to complete
3. Your admin portal will be live!

---

## Admin Login Credentials

Once deployed, login with:
```
Email: konnectmediaapp@gmail.com
Password: #jain1191
```

---

## Features Available

✅ Dashboard with analytics
✅ User management
✅ Subscription tracking
✅ Revenue reports
✅ Trend monitoring
✅ Support tickets
✅ Notifications/Announcements
✅ Activity logs
✅ Settings

---

## Troubleshooting

### Build Fails
- Make sure Root Directory is set to `admin`
- Check that environment variable is set correctly

### API Not Working
- Verify `VITE_API_URL` environment variable
- Make sure backend is running on Render
- Check browser console for CORS errors

### Login Not Working
- Clear browser cache
- Use exact credentials (case-sensitive password)
- Check browser console for errors

---

## Local Development

To run admin portal locally:

```bash
cd admin
npm install
npm run dev
```

Access at: http://localhost:5173

---

## Production URLs

- **Backend API:** https://konnectmedia-api.onrender.com/api
- **Admin Portal:** (Will be available after Vercel deployment)
- **GitHub Repo:** https://github.com/Ankushsph/freelance

---

Need help? Check the deployment logs in Vercel/Netlify dashboard!
