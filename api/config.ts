import dotenv from "dotenv";

// Load environment variables before accessing them anywhere in this file
dotenv.config();

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    console.error(`❌ Missing required environment variable: ${name}`);
    process.exit(1);
  }
  return value;
}

function getEnv(name: string, defaultValue: string): string {
  return process.env[name] || defaultValue;
}

function getBoolEnv(name: string, defaultValue: boolean = false): boolean {
  const value = process.env[name];
  if (!value) return defaultValue;
  return value.toLowerCase() === 'true' || value === '1';
}

export const SERVER = {
  PORT: parseInt(getEnv('PORT', '4000')),
  PUBLIC_URL: getEnv('PUBLIC_URL', 'http://localhost:4000'),
};

export const DATABASE = {
  MONGO_URI: requireEnv('MONGO_URI'),
};

export const AUTH = {
  JWT_SECRET: requireEnv('JWT_SECRET'),
};

export const EMAIL = {
  USER: getEnv('MAIL_USER', ''),
  PASS: getEnv('MAIL_PASS', ''),
  ADMIN_EMAIL: getEnv('ADMIN_EMAIL', ''),
};

export const AI = {
  URL: getEnv('AI_URL', 'http://localhost:11434'),
  MODEL: getEnv('AI_MODEL', 'phi3:mini'),
};

export const INSTAGRAM = {
  ENABLED: getBoolEnv('ENABLE_INSTAGRAM', true),
  CLIENT_ID: getEnv('INSTAGRAM_CLIENT_ID', 'demo_client_id'),
  CLIENT_SECRET: getEnv('INSTAGRAM_CLIENT_SECRET', 'demo_client_secret'),
  REDIRECT_URI: getEnv('INSTAGRAM_REDIRECT_URI', 'http://localhost:4000/api/callback/instagram'),
  GRAPH_API_VERSION: 'v24.0',
  GRAPH_BASE_URL: 'https://graph.instagram.com',
  OAUTH_BASE_URL: 'https://www.instagram.com/oauth/authorize',
  TOKEN_URL: 'https://api.instagram.com/oauth/access_token',
  SCOPES: [
    'instagram_business_basic',
    'instagram_business_manage_messages',
    'instagram_business_manage_comments',
    'instagram_business_content_publish',
    'instagram_business_manage_insights'
  ].join(','),
};

export const FACEBOOK = {
  ENABLED: getBoolEnv('ENABLE_FACEBOOK', true),
  CLIENT_ID: getEnv('FACEBOOK_CLIENT_ID', 'demo_client_id'),
  CLIENT_SECRET: getEnv('FACEBOOK_CLIENT_SECRET', 'demo_client_secret'),
  REDIRECT_URI: getEnv('FACEBOOK_REDIRECT_URI', 'http://localhost:4000/api/callback/facebook'),
  API_VERSION: getEnv('FACEBOOK_API_VERSION', 'v19.0'),
  get GRAPH_API_URL() {
    return `https://graph.facebook.com/${this.API_VERSION}`;
  },
  get OAUTH_URL() {
    return `https://www.facebook.com/${this.API_VERSION}/dialog/oauth`;
  },
  get TOKEN_URL() {
    return `https://graph.facebook.com/${this.API_VERSION}/oauth/access_token`;
  },
  SCOPES: [
    'pages_show_list',
    'pages_manage_posts',
    'public_profile',
    'email',
    'read_insights',
    'pages_read_engagement'
  ].join(','),
};

export const LINKEDIN = {
  ENABLED: getBoolEnv('ENABLE_LINKEDIN', false),
  CLIENT_ID: getEnv('LINKEDIN_CLIENT_ID', ''),
  CLIENT_SECRET: getEnv('LINKEDIN_CLIENT_SECRET', ''),
  REDIRECT_URI: getEnv('LINKEDIN_REDIRECT_URI', `${SERVER.PUBLIC_URL}/api/linkedin/callback`),
  API_VERSION: '202411',
  BASE_URL: 'https://api.linkedin.com',
  OAUTH_URL: 'https://www.linkedin.com/oauth/v2/authorization',
  TOKEN_URL: 'https://www.linkedin.com/oauth/v2/accessToken',
  SCOPES: [
    'openid',
    'profile',
    'email',
    'w_member_social'
  ].join(' '),
};

export const TWITTER = {
  ENABLED: getBoolEnv('ENABLE_TWITTER', false),
  CLIENT_ID: getEnv('TWITTER_CLIENT_ID', ''),
  CLIENT_SECRET: getEnv('TWITTER_CLIENT_SECRET', ''),
  REDIRECT_URI: getEnv('TWITTER_REDIRECT_URI', `${SERVER.PUBLIC_URL}/api/twitter/callback`),
  API_VERSION: '2',
  BASE_URL: 'https://api.x.com',
  OAUTH_URL: 'https://x.com/i/oauth2/authorize',
  TOKEN_URL: 'https://api.x.com/2/oauth2/token',
  SCOPES: [
    'tweet.read',
    'tweet.write',
    'users.read',
    'offline.access'
  ].join(' '),
  OAUTH1: {
    CONSUMER_KEY: getEnv('TWITTER_OAUTH1_CONSUMER_KEY', ''),
    CONSUMER_SECRET: getEnv('TWITTER_OAUTH1_CONSUMER_SECRET', ''),
    ACCESS_TOKEN: getEnv('TWITTER_OAUTH1_ACCESS_TOKEN', ''),
    ACCESS_TOKEN_SECRET: getEnv('TWITTER_OAUTH1_ACCESS_TOKEN_SECRET', ''),
  }
};

export const FEATURES = {
  INSTAGRAM: INSTAGRAM.ENABLED,
  FACEBOOK: FACEBOOK.ENABLED,
  LINKEDIN: LINKEDIN.ENABLED,
  TWITTER: TWITTER.ENABLED,
};

export function validateConfig(): void {
  console.log('🔧 Validating configuration...\n');

  const required = [
    ['SERVER.PUBLIC_URL', SERVER.PUBLIC_URL],
    ['DATABASE.MONGO_URI', DATABASE.MONGO_URI],
    ['AUTH.JWT_SECRET', AUTH.JWT_SECRET ? '***SET***' : ''],
  ];

  if (FEATURES.INSTAGRAM) {
    required.push(
      ['INSTAGRAM.CLIENT_ID', INSTAGRAM.CLIENT_ID ? '***SET***' : ''],
      ['INSTAGRAM.CLIENT_SECRET', INSTAGRAM.CLIENT_SECRET ? '***SET***' : '']
    );
  }

  if (FEATURES.FACEBOOK) {
    required.push(
      ['FACEBOOK.CLIENT_ID', FACEBOOK.CLIENT_ID ? '***SET***' : ''],
      ['FACEBOOK.CLIENT_SECRET', FACEBOOK.CLIENT_SECRET ? '***SET***' : '']
    );
  }

  let hasErrors = false;
  
  for (const [name, value] of required) {
    if (!value) {
      console.error(`  ❌ ${name}: MISSING`);
      hasErrors = true;
    } else {
      console.log(`  ✅ ${name}: ${value}`);
    }
  }

  console.log('\n📱 Enabled Platforms:');
  console.log(`  Instagram: ${FEATURES.INSTAGRAM ? '✅' : '❌'}`);
  console.log(`  Facebook: ${FEATURES.FACEBOOK ? '✅' : '❌'}`);
  console.log(`  LinkedIn: ${FEATURES.LINKEDIN ? '✅' : '❌'}`);
  console.log(`  Twitter: ${FEATURES.TWITTER ? '✅' : '❌'}`);

  if (hasErrors) {
    console.error('\n❌ Configuration validation failed. Please check your .env file.');
    process.exit(1);
  }

  console.log('\n✅ Configuration validated successfully!\n');
}
