# 📊 KonnectMedia Analytics - Complete Guide

## ✅ What's Already Implemented

Your app **ALREADY HAS** a fully functional analytics feature that fetches REAL data from Instagram and Facebook APIs!

### Current Features:

1. **Real-time Analytics Dashboard**
   - Impressions (how many times posts were seen)
   - Reach (unique users who saw posts)
   - Engagement (likes, comments, shares, saves)
   - Followers count

2. **Time Range Selection**
   - Last 7 days
   - Last 30 days

3. **Visual Charts**
   - Line graphs showing trends over time
   - Interactive metric selection (Reach/Impressions/Engagement)

4. **Post-Level Analytics**
   - Individual post performance
   - Detailed metrics per post
   - Post type indicators (Image/Video/Reels/Carousel)

5. **Platform Support**
   - ✅ Instagram (fully implemented)
   - ✅ Facebook (fully implemented)
   - 🚧 LinkedIn (coming soon)
   - 🚧 X/Twitter (coming soon)

---

## 🎯 What You See in Meta Business Suite = What Your App Shows

The analytics in your app fetch the EXACT SAME data that you see in Meta Business Suite:

| Meta Business Suite | Your KonnectMedia App |
|---------------------|----------------------|
| Accounts Reached | ✅ Reach |
| Impressions | ✅ Impressions |
| Engagement | ✅ Engagement (Likes + Comments + Shares) |
| Followers | ✅ Followers |
| Post Performance | ✅ Individual Post Analytics |
| Time Range Filter | ✅ 7 Days / 30 Days |

---

## 🔧 How to Get Analytics Working

### Step 1: Get Meta Developer Credentials

1. Go to https://developers.facebook.com/
2. Create an app (if you haven't)
3. Get your App ID and App Secret
4. Add to `.env`:
   ```bash
   INSTAGRAM_CLIENT_ID=your_app_id
   INSTAGRAM_CLIENT_SECRET=your_app_secret
   FACEBOOK_CLIENT_ID=your_app_id
   FACEBOOK_CLIENT_SECRET=your_app_secret
   ```

### Step 2: Request Analytics Permissions

In Meta Developer Dashboard:

1. Go to **App Review** → **Permissions and Features**
2. Request these permissions:

**For Instagram:**
- `instagram_basic` - Get Advanced Access
- `instagram_manage_insights` - Get Advanced Access
- `pages_read_engagement` - Get Advanced Access

**For Facebook:**
- `pages_show_list` - Get Advanced Access
- `pages_read_engagement` - Get Advanced Access
- `pages_read_user_content` - Get Advanced Access
- `read_insights` - Get Advanced Access

### Step 3: Connect Your Account

1. Open your KonnectMedia app
2. Go to Home screen
3. Connect your Instagram/Facebook account
4. Grant all permissions when prompted

### Step 4: View Analytics

1. Tap on **Analytics** in bottom navigation
2. Select time range (7 or 30 days)
3. View your real data!

---

## 📱 What Data You'll See

### Overview Metrics

```
┌─────────────────────────────────────┐
│  IMPRESSIONS        REACH           │
│     12.5K            8.2K           │
│                                     │
│  ENGAGEMENT       FOLLOWERS         │
│     1.8K            2.5K            │
└─────────────────────────────────────┘
```

### Trend Chart

```
Reach Trend (Last 7 Days)
    ╱╲
   ╱  ╲    ╱╲
  ╱    ╲  ╱  ╲
 ╱      ╲╱    ╲
```

### Recent Posts

```
┌─────────────────────────────────────┐
│ 📷 Check out our new product!       │
│    IMAGE • 2.5K reach • 450 engage  │
├─────────────────────────────────────┤
│ 🎥 Behind the scenes video          │
│    REELS • 8.1K reach • 1.2K engage │
├─────────────────────────────────────┤
│ 📸 Summer collection launch         │
│    CAROUSEL • 3.2K reach • 680 eng  │
└─────────────────────────────────────┘
```

---

## 🔍 How It Works (Technical)

### Backend API Calls

Your app makes these API calls to fetch real data:

**1. Instagram Account Insights**
```
GET https://graph.instagram.com/{instagram-user-id}/insights
?metric=impressions,reach,profile_views
&period=day
&since={timestamp}
&until={timestamp}
```

**2. Instagram Media (Posts)**
```
GET https://graph.instagram.com/{instagram-user-id}/media
?fields=id,caption,media_type,timestamp,like_count,comments_count
```

**3. Instagram Media Insights**
```
GET https://graph.instagram.com/{media-id}/insights
?metric=impressions,reach,engagement,saved
```

**4. Facebook Page Insights**
```
GET https://graph.facebook.com/{page-id}/insights
?metric=page_impressions,page_reach,page_engaged_users
&since={timestamp}
&until={timestamp}
```

**5. Facebook Page Posts**
```
GET https://graph.facebook.com/{page-id}/posts
?fields=message,created_time,insights.metric(post_impressions,post_engaged_users)
```

### Data Flow

```
User Opens Analytics Screen
         ↓
Flutter App calls ApiService.getAnalytics()
         ↓
Backend /api/analytics/:platform endpoint
         ↓
analytics.service.ts fetches from Meta APIs
         ↓
Real data returned to app
         ↓
Charts and metrics displayed
```

---

## ⚠️ Important Notes

### Development Mode Limitations

While your app is in **Development Mode**:

- ✅ You (app admin) can see analytics
- ✅ Test users can see analytics
- ❌ Public users cannot see analytics until app is approved

### Business Account Required

For Instagram analytics:
- Must be an **Instagram Business** or **Creator** account
- Personal accounts don't have access to insights API
- Convert at: Instagram Settings → Account → Switch to Professional Account

### Facebook Page Required

For Facebook analytics:
- Must have a **Facebook Page** (not personal profile)
- Page must be connected to your app
- Create page at: https://www.facebook.com/pages/create

### Permissions Review

Some permissions require Meta's approval:
- Submit for App Review when ready for production
- Provide demo video showing how you use the data
- Explain use case: "Social media management tool"
- Approval takes 3-5 business days

---

## 🐛 Troubleshooting

### "Permissions Error" Message

**Problem:** App shows "Analytics Permissions Required"

**Solution:**
1. Check if you're added as app Administrator
2. Verify permissions are requested in App Review
3. Make sure account is Business/Creator (Instagram)
4. Ensure you have a Facebook Page (Facebook)

### "No Data Available"

**Problem:** Analytics show 0 for all metrics

**Possible Causes:**
1. No posts in selected time range
2. Account just connected (data takes time to populate)
3. Personal Instagram account (needs Business account)
4. Permissions not granted during OAuth

**Solution:**
- Post some content first
- Wait 24-48 hours for data to populate
- Reconnect account and grant all permissions

### "Failed to Load Analytics"

**Problem:** Error message when loading

**Solution:**
1. Check backend is running (http://localhost:4000)
2. Verify access token is valid (reconnect account)
3. Check backend logs for specific error
4. Ensure API credentials in `.env` are correct

---

## 🚀 Testing Analytics

### Quick Test Steps:

1. **Connect Instagram Business Account**
   ```
   Home → Tap Instagram icon → Connect → Grant permissions
   ```

2. **Post Some Content**
   ```
   Create 2-3 posts on Instagram
   Wait 1-2 hours for data to populate
   ```

3. **View Analytics**
   ```
   Tap Analytics → Select Instagram → View metrics
   ```

4. **Check Individual Posts**
   ```
   Scroll to "Recent Posts" → Tap any post → See detailed metrics
   ```

---

## 📊 Sample Analytics Response

Here's what real data looks like from the API:

```json
{
  "success": true,
  "data": {
    "platform": "instagram",
    "connected": true,
    "overview": {
      "impressions": 12543,
      "reach": 8234,
      "engagement": 1876,
      "followers": 2543
    },
    "history": [
      {
        "date": "2026-03-13",
        "impressions": 1823,
        "reach": 1234,
        "engagement": 267
      },
      {
        "date": "2026-03-14",
        "impressions": 2145,
        "reach": 1456,
        "engagement": 312
      }
    ],
    "posts": [
      {
        "id": "18123456789",
        "caption": "Check out our new product! 🚀",
        "created_time": "2026-03-14T10:30:00+0000",
        "media_type": "IMAGE",
        "insights": {
          "impressions": 2543,
          "reach": 1876,
          "engagement": 456,
          "likes": 389,
          "comments": 67,
          "saved": 23
        }
      }
    ]
  }
}
```

---

## 🎓 Understanding Metrics

### Impressions
- **What:** Total number of times your content was displayed
- **Example:** If same person sees your post 3 times = 3 impressions
- **Use:** Measure content visibility

### Reach
- **What:** Number of unique accounts that saw your content
- **Example:** If same person sees post 3 times = 1 reach
- **Use:** Measure audience size

### Engagement
- **What:** Total interactions (likes + comments + shares + saves)
- **Example:** 100 likes + 20 comments + 5 shares = 125 engagement
- **Use:** Measure content effectiveness

### Engagement Rate
- **Formula:** (Engagement / Reach) × 100
- **Good Rate:** 3-6% is average, 6%+ is excellent
- **Use:** Compare post performance

---

## 🔮 Future Enhancements

Planned features:

1. **LinkedIn Analytics** (when API credentials added)
2. **X/Twitter Analytics** (when API credentials added)
3. **Competitor Analysis**
4. **Best Time to Post** recommendations
5. **Hashtag Performance** tracking
6. **Story Analytics** (Instagram)
7. **Export Reports** (PDF/CSV)
8. **Email Reports** (weekly/monthly)

---

## ✅ Summary

Your KonnectMedia app **ALREADY HAS** real analytics that fetch data from Instagram and Facebook APIs. The same data you see in Meta Business Suite will appear in your app once you:

1. ✅ Add Meta Developer credentials to `.env`
2. ✅ Request analytics permissions
3. ✅ Connect your Instagram Business/Facebook Page
4. ✅ Grant permissions during OAuth

The feature is production-ready and waiting for your API credentials!

---

Need help with any specific part? Let me know!
