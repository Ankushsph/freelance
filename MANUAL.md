# Konnect - Developer Manual

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Backend (API)](#backend-api)
4. [Frontend (Flutter)](#frontend-flutter)
5. [Environment Setup](#environment-setup)
6. [API Endpoints](#api-endpoints)
7. [Database Models](#database-models)
8. [Social Media Integration](#social-media-integration)
9. [Scheduling System](#scheduling-system)
10. [AI Features](#ai-features)

---

## Project Overview

Konnect is a social media management platform that enables users to manage multiple social media accounts from a unified dashboard. Users can schedule posts across platforms, connect their social accounts via OAuth, receive AI-powered assistance for content creation, and book expert consultations.

### Core Features
- Multi-platform social media posting (Instagram, Facebook, Twitter/X, LinkedIn)
- Post scheduling with automated publishing
- Social account connection via OAuth 2.0
- AI-powered chat assistant for content suggestions
- Expert consultation booking system
- Analytics and trending content tracking

### Tech Stack
- **Backend**: Node.js, Express, TypeScript, MongoDB
- **Frontend**: Flutter (Dart)
- **AI**: OpenRouter (free cloud AI)
- **Scheduler**: node-schedule

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│   Express API   │────▶│    MongoDB      │
│   (Frontend)    │     │   (Backend)     │     │   (Database)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│  Social APIs  │      │ OpenRouter AI │      │  SMTP/Email   │
│  (IG,FB,X,LI) │      │  (AI Bot)     │      │  (Mailer)     │
└───────────────┘      └───────────────┘      └───────────────┘
```

### Application Flow
1. User registers and logs in through the Flutter app
2. User connects social media accounts via OAuth flow
3. User creates posts with text, images, and selects target platforms
4. Posts can be published immediately or scheduled for later
5. Scheduler triggers at designated times to publish posts
6. AI assistant helps generate captions and content suggestions
7. Admin receives consultation booking notifications via email

---

## Backend (API)

### Structure
```
api/
├── index.ts              # Application entry point
├── config.ts             # Environment configuration
├── db.ts                 # MongoDB connection
├── models/               # Mongoose schemas
│   ├── User.ts
│   ├── Post.ts
│   ├── Boost.ts
│   ├── Conversation.ts
│   ├── Message.ts
│   └── TrendingPost.ts
├── routes/               # API endpoints
│   ├── auth.routes.ts
│   ├── posts.routes.ts
│   ├── boost.router.ts
│   ├── ai.router.ts
│   ├── instagram.routes.ts
│   ├── facebook.routers.ts
│   ├── twitter.routes.ts
│   ├── linkedin.routes.ts
│   ├── analytics.routes.ts
│   ├── trending.routes.ts
│   ├── conversation.routes.ts
│   ├── user.routes.ts
│   ├── upload.routes.ts
│   ├── otp.routes.ts
│   └── callback.routers.ts
├── services/             # Business logic
│   ├── post.ts
│   ├── scheduler.ts
│   ├── instagram.ts
│   ├── facebook.ts
│   ├── twitter.ts
│   ├── linkedin.ts
│   ├── analytics.ts
│   └── trending.ts
├── middleware/           # Express middleware
│   └── auth.ts
└── utils/                # Utilities
    ├── mailer.ts
    ├── boostTemplate.ts
    └── otpTemplate.ts
```

### Running the API
```bash
cd api
bun install
bun run dev        # Development mode
bun start          # Production mode
```

---

## Frontend (Flutter)

### Structure
```
ui_app/lib/
├── main.dart                     # Application entry point
├── models/                       # Data models
├── screens/                      # UI screens
│   ├── home_screen.dart
│   ├── launcher_screen.dart
│   ├── authentication/           # Login, Signup, OTP, Password reset
│   ├── post/                    # Post creation screens
│   ├── schedule/               # Schedule management
│   ├── profile/                # User profile screens
│   ├── social/                 # Social account management
│   ├── analytics/              # Analytics dashboard
│   ├── trend/                  # Trending content
│   ├── boost/                  # Consultation booking
│   └── ai/                     # AI chat assistant
├── services/                    # API clients
│   ├── api_service.dart
│   ├── auth_storage.dart
│   ├── social_connection_service.dart
│   ├── social_profile_mapper.dart
│   ├── mock_social_service.dart
│   └── ai/
├── providers/                    # State management
│   ├── schedule_provider.dart
│   └── platform_provider.dart
└── widgets/                      # Reusable widgets
    ├── bottom_nav_bar.dart
    ├── schedule_calendar.dart
    ├── k_textfield.dart
    ├── k_button.dart
    ├── stat_tile.dart
    └── profile_header.dart
```

### Running the App
```bash
cd ui_app
flutter pub get
flutter run
```

---

## Environment Setup

### API Environment Variables

Create `api/.env` file with the following configuration:

```env
PORT=4000
PUBLIC_URL=https://your-domain.com

MONGO_URI=mongodb://127.0.0.1:27017/Konnect

JWT_SECRET=your_super_secret_jwt_key_here

MAIL_USER=your_email@example.com
MAIL_PASS=your_app_password_here
ADMIN_EMAIL=admin@yourdomain.com

OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_MODEL=meta-llama/llama-3.2-1b-instruct

INSTAGRAM_CLIENT_ID=your_instagram_app_id
INSTAGRAM_CLIENT_SECRET=your_instagram_app_secret
INSTAGRAM_REDIRECT_URI=https://your-domain.com/api/instagram/callback

FACEBOOK_CLIENT_ID=your_facebook_app_id
FACEBOOK_CLIENT_SECRET=your_facebook_app_secret
FACEBOOK_REDIRECT_URI=https://your-domain.com/api/facebook/callback
FACEBOOK_API_VERSION=v19.0

LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
LINKEDIN_REDIRECT_URI=https://your-domain.com/api/linkedin/callback

TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret
TWITTER_REDIRECT_URI=https://your-domain.com/api/twitter/callback

TWITTER_OAUTH1_CONSUMER_KEY=your_twitter_oauth1_consumer_key
TWITTER_OAUTH1_CONSUMER_SECRET=your_twitter_oauth1_consumer_secret
TWITTER_OAUTH1_ACCESS_TOKEN=your_twitter_oauth1_access_token
TWITTER_OAUTH1_ACCESS_TOKEN_SECRET=your_twitter_oauth1_access_token_secret

ENABLE_INSTAGRAM=true
ENABLE_FACEBOOK=true
ENABLE_LINKEDIN=false
ENABLE_TWITTER=false
```

### Flutter Environment Variables

Create `ui_app/.env` file:

```env
API_BASE_URL=https://your-domain.com/api
AI_URL=https://your-domain.com/api/ai/chat
```

### Configuration Details

| Variable | Description | Example |
|----------|-------------|---------|
| PORT | Server port number | 4000 |
| PUBLIC_URL | Public domain for OAuth callbacks | https://api.yourdomain.com |
| MONGO_URI | MongoDB connection string | mongodb://127.0.0.1:27017/Konnect |
| JWT_SECRET | Secret key for JWT token generation | random_secure_string |
| MAIL_USER | SMTP email username | your_email@gmail.com |
| MAIL_PASS | SMTP app password | xxxx xxxx xxxx xxxx |
| ADMIN_EMAIL | Admin notification recipient | admin@yourdomain.com |
| OPENROUTER_API_KEY | OpenRouter API key (get from https://openrouter.ai/settings) | sk-or-v1-... |
| OPENROUTER_MODEL | OpenRouter model identifier | meta-llama/llama-3.2-1b-instruct |
| ENABLE_* | Feature flags for social platforms | true/false |

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password` | Reset password with OTP |
| POST | `/api/auth/otp/send` | Send OTP to email |
| POST | `/api/auth/otp/verify` | Verify OTP |

### Posts
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/posts` | Create new post |
| GET | `/api/posts` | Get user's posts |
| GET | `/api/posts/:id` | Get single post |
| DELETE | `/api/posts/:id` | Cancel scheduled post |
| POST | `/api/posts/:id/retry` | Retry failed post |

### Social Media OAuth
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/instagram/auth` | Instagram OAuth URL |
| GET | `/api/instagram/callback` | Instagram OAuth callback |
| GET | `/api/facebook/auth` | Facebook OAuth URL |
| GET | `/api/facebook/callback` | Facebook OAuth callback |
| GET | `/api/linkedin/auth` | LinkedIn OAuth URL |
| GET | `/api/linkedin/callback` | LinkedIn OAuth callback |
| GET | `/api/twitter/auth` | Twitter OAuth URL |
| GET | `/api/twitter/callback` | Twitter OAuth callback |

### AI Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/ai/chat` | Send message to AI |
| POST | `/api/ai/caption` | Generate post caption |
| GET | `/api/ai/history/:userId` | Get chat history |
| DELETE | `/api/ai/history/:userId` | Clear chat history |

### Boost (Expert Consultation)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/boost/send` | Book consultation slot |
| GET | `/api/boost/:userId` | Get user's bookings |
| PATCH | `/api/boost/status/:id` | Update booking status |

### Analytics
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/analytics/summary/:userId` | Get analytics summary |
| GET | `/api/analytics/platforms/:userId` | Get platform stats |

### Trending
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trending` | Get trending posts |
| GET | `/api/trending/:id` | Get trending post details |

### User
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/user/profile` | Get user profile |
| PATCH | `/api/user/profile` | Update user profile |

### Upload
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/upload` | Upload media file |

---

## Database Models

### User
```typescript
{
  name: string
  email: string
  password: string
  socialAccounts: {
    instagram?: { accessToken, userId, username }
    facebook?: { accessToken, userId }
    linkedin?: { accessToken, userId }
    twitter?: { accessToken, refreshToken, userId }
  }
  createdAt: Date
  updatedAt: Date
}
```

### Post
```typescript
{
  userId: string
  content: string
  platforms: string[]
  mediaUrls: string[]
  scheduledTime: Date
  status: 'pending' | 'scheduled' | 'publishing' | 'published' | 'failed' | 'partially_failed' | 'cancelled'
  publishResults: object
  createdAt: Date
  updatedAt: Date
}
```

### Boost
```typescript
{
  userId: string
  name: string
  contact: string
  timeSlot: string
  message: string
  status: 'pending' | 'approved' | 'rejected'
  createdAt: Date
  updatedAt: Date
}
```

### Conversation
```typescript
{
  userId: string
  title: string
  messages: Message[]
  createdAt: Date
  updatedAt: Date
}
```

### Message
```typescript
{
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}
```

### TrendingPost
```typescript
{
  platform: string
  content: string
  likes: number
  comments: number
  shares: number
  mediaUrl: string
  authorName: string
  authorUsername: string
  collectedAt: Date
}
```

### OTP
```typescript
{
  email: string
  otp: string
  expiresAt: Date
}
```

---

## Social Media Integration

### Instagram
- OAuth 2.0 authentication flow
- Posts images to Instagram Business accounts
- Requires Facebook Business connection
- Uses Instagram Graph API

### Facebook
- OAuth 2.0 authentication
- Posts to user profile or pages
- Supports images and videos
- Uses Facebook Graph API

### LinkedIn
- OAuth 2.0 authentication
- Posts to personal profile
- Supports articles and media
- Uses LinkedIn API v2

### Twitter/X
- OAuth 2.0 for authentication
- OAuth 1.0a for media uploads
- Posts tweets with media
- Character limit: 280 characters
- Uses Twitter API v2

---

## Scheduling System

The scheduling system uses `node-schedule` to manage post publishing:

1. User creates a post with `scheduledTime` in the future
2. Post is saved to MongoDB with status `scheduled`
3. Scheduler creates a cron job that triggers at the scheduled time
4. At trigger time, post status changes to `publishing`
5. Post is published to all selected platforms via respective APIs
6. Status updates based on result: `published`, `failed`, or `partially_failed`
7. Results are stored in `publishResults` field

### Scheduler Functions
- `initializeScheduler()` - Restores pending scheduled posts on server restart
- `schedulePost(post)` - Schedules a new post
- `cancelScheduledPost(postId)` - Cancels a scheduled post

---

## AI Features

### AI Chat Bot
- Powered by OpenRouter free AI models
- Provides social media advice and caption suggestions
- Maintains conversation history per user
- Context-aware responses based on selected platform

### Caption Generation
- Analyzes user input and generates optimized captions
- Platform-specific optimization (Instagram, Facebook, Twitter, LinkedIn)
- Returns hashtags automatically

### Supported AI Models
- **Free**: OpenRouter with meta-llama/llama-3.2-1b-instruct (recommended)
- **Alternative**: Other free models available at openrouter.ai

---

## File Upload

Media files are uploaded to `/uploads` directory:
- Supported formats: jpg, jpeg, png, gif, webp, mp4, mov
- Max size: 50MB (images), 100MB (videos)
- Files served statically with proper MIME types

---

## Email System

Uses Nodemailer with SMTP:
- Boost booking confirmations sent to admin
- OTP emails for password reset
- HTML email templates in `api/utils/`

---

## Testing

### API Tests
```bash
cd api
bun test
```

### Flutter Tests
```bash
cd ui_app
flutter test
```

---

## Deployment

### Backend Deployment
1. Set up MongoDB instance
2. Configure environment variables in .env file
3. Run `bun install`
4. Start with `bun start`
5. Use PM2 or similar for process management

### Flutter Deployment
1. Update `API_BASE_URL` in ui_app/.env to production URL
2. Run `flutter build apk` for Android
3. Run `flutter build ios` for iOS

---

## Troubleshooting

### Common Issues

**Posts not publishing:**
- Check social media tokens are valid
- Verify media URLs are accessible
- Check scheduler logs for errors

**Social auth failing:**
- Verify callback URLs match app settings in developer portals
- Check client IDs and secrets are correct
- Ensure OAuth scopes are properly configured

**Email not sending:**
- Verify SMTP credentials
- Check MAIL_USER and MAIL_PASS env vars
- Enable app password for Gmail accounts

**AI not responding:**
- Verify OPENROUTER_API_KEY is valid (get from https://openrouter.ai/settings)
- Check OPENROUTER_MODEL is set correctly
- Ensure API key has free credits available
