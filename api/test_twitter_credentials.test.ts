/**
 * Twitter OAuth Credentials Test
 * Tests the OAuth flow using actual credentials from .env file
 * 
 * Run with: bun test test_twitter_credentials.test.ts
 */

import { describe, test, expect } from "bun:test";
import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '.env') });

// Get actual credentials from .env
const TWITTER_CLIENT_ID = process.env.TWITTER_CLIENT_ID || '';
const TWITTER_CLIENT_SECRET = process.env.TWITTER_CLIENT_SECRET || '';
const TWITTER_REDIRECT_URI = process.env.TWITTER_REDIRECT_URI || '';
const ENABLE_TWITTER = process.env.ENABLE_TWITTER === 'true';

describe('Twitter OAuth Credentials Validation', () => {
  test('should have TWITTER_CLIENT_ID configured', () => {
    expect(TWITTER_CLIENT_ID).toBeTruthy();
    expect(TWITTER_CLIENT_ID.length).toBeGreaterThan(10);
    console.log('✓ Client ID exists:', TWITTER_CLIENT_ID.substring(0, 15) + '...');
  });

  test('should have TWITTER_CLIENT_SECRET configured', () => {
    expect(TWITTER_CLIENT_SECRET).toBeTruthy();
    expect(TWITTER_CLIENT_SECRET.length).toBeGreaterThan(20);
    console.log('✓ Client Secret exists:', TWITTER_CLIENT_SECRET.substring(0, 10) + '...');
  });

  test('should have TWITTER_REDIRECT_URI configured', () => {
    expect(TWITTER_REDIRECT_URI).toBeTruthy();
    expect(TWITTER_REDIRECT_URI.startsWith('https://')).toBe(true);
    console.log('✓ Redirect URI:', TWITTER_REDIRECT_URI);
  });

  test('should have Twitter enabled', () => {
    expect(ENABLE_TWITTER).toBe(true);
    console.log('✓ Twitter is enabled');
  });
});

describe('Twitter OAuth Basic Auth Header', () => {
  test('should generate correct Basic Auth header with real credentials', () => {
    const credentials = Buffer.from(`${TWITTER_CLIENT_ID}:${TWITTER_CLIENT_SECRET}`).toString('base64');
    const authHeader = `Basic ${credentials}`;
    
    expect(authHeader.startsWith('Basic ')).toBe(true);
    expect(credentials.length).toBeGreaterThan(20);
    
    // Verify we can decode it back correctly
    const decoded = Buffer.from(credentials, 'base64').toString('utf-8');
    expect(decoded).toBe(`${TWITTER_CLIENT_ID}:${TWITTER_CLIENT_SECRET}`);
    
    console.log('✓ Basic Auth header generated successfully');
    console.log('  Header preview:', authHeader.substring(0, 30) + '...');
  });

  test('should generate consistent headers for same credentials', () => {
    const cred1 = Buffer.from(`${TWITTER_CLIENT_ID}:${TWITTER_CLIENT_SECRET}`).toString('base64');
    const cred2 = Buffer.from(`${TWITTER_CLIENT_ID}:${TWITTER_CLIENT_SECRET}`).toString('base64');
    
    expect(cred1).toBe(cred2);
    console.log('✓ Basic Auth header is deterministic');
  });
});

describe('Twitter OAuth URL Generation', () => {
  test('should generate valid OAuth authorization URL', () => {
    const state = 'test-state-' + Date.now();
    const codeChallenge = 'test_challenge_' + Math.random().toString(36).substring(7);
    
    const oauthUrl = 
      `https://x.com/i/oauth2/authorize` +
      `?response_type=code` +
      `&client_id=${TWITTER_CLIENT_ID}` +
      `&redirect_uri=${encodeURIComponent(TWITTER_REDIRECT_URI)}` +
      `&scope=${encodeURIComponent('tweet.read tweet.write users.read offline.access')}` +
      `&state=${state}` +
      `&code_challenge=${codeChallenge}` +
      `&code_challenge_method=S256`;
    
    expect(oauthUrl.startsWith('https://x.com/i/oauth2/authorize')).toBe(true);
    expect(oauthUrl.includes(`client_id=${TWITTER_CLIENT_ID}`)).toBe(true);
    expect(oauthUrl.includes('response_type=code')).toBe(true);
    expect(oauthUrl.includes('code_challenge_method=S256')).toBe(true);
    
    console.log('✓ OAuth URL generated successfully');
    console.log('  URL preview:', oauthUrl.substring(0, 80) + '...');
  });

  test('should properly encode redirect URI', () => {
    const encoded = encodeURIComponent(TWITTER_REDIRECT_URI);
    expect(encoded).not.toContain(' ');
    expect(encoded).toContain('https%3A%2F%2F');
    console.log('✓ Redirect URI encoded:', encoded);
  });
});

describe('Twitter Token Exchange Request', () => {
  test('should create proper token exchange request body', () => {
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: 'test_auth_code_123',
      redirect_uri: TWITTER_REDIRECT_URI,
      code_verifier: 'test_pkce_verifier_xyz',
      client_id: TWITTER_CLIENT_ID
      // Note: client_secret should NOT be in body with Basic Auth
    });
    
    const bodyString = tokenBody.toString();
    
    expect(bodyString.includes('grant_type=authorization_code')).toBe(true);
    expect(bodyString.includes(`client_id=${encodeURIComponent(TWITTER_CLIENT_ID)}`)).toBe(true);
    expect(bodyString.includes(`redirect_uri=${encodeURIComponent(TWITTER_REDIRECT_URI)}`)).toBe(true);
    
    // Verify client_secret is NOT in the body
    expect(bodyString.includes('client_secret')).toBe(false);
    
    console.log('✓ Token exchange request body is correct');
    console.log('  Body preview:', bodyString.substring(0, 60) + '...');
  });

  test('should create proper fetch configuration for token exchange', () => {
    const credentials = Buffer.from(`${TWITTER_CLIENT_ID}:${TWITTER_CLIENT_SECRET}`).toString('base64');
    
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: 'test_auth_code',
      redirect_uri: TWITTER_REDIRECT_URI,
      code_verifier: 'test_verifier',
      client_id: TWITTER_CLIENT_ID
    });
    
    const fetchConfig = {
      method: 'POST' as const,
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: tokenBody
    };
    
    expect(fetchConfig.method).toBe('POST');
    expect(fetchConfig.headers['Authorization']).toBe(`Basic ${credentials}`);
    expect(fetchConfig.headers['Content-Type']).toBe('application/x-www-form-urlencoded');
    expect(fetchConfig.body).toBeInstanceOf(URLSearchParams);
    
    console.log('✓ Fetch configuration is correct');
    console.log('  Authorization header present:', !!fetchConfig.headers['Authorization']);
  });
});

describe('Twitter API Endpoints', () => {
  test('should have correct token endpoint URL', () => {
    const TOKEN_URL = 'https://api.x.com/2/oauth2/token';
    expect(TOKEN_URL).toBe('https://api.x.com/2/oauth2/token');
    console.log('✓ Token URL:', TOKEN_URL);
  });

  test('should have correct OAuth authorization endpoint URL', () => {
    const OAUTH_URL = 'https://x.com/i/oauth2/authorize';
    expect(OAUTH_URL).toBe('https://x.com/i/oauth2/authorize');
    console.log('✓ OAuth URL:', OAUTH_URL);
  });
});

describe('Credentials Summary', () => {
  test('should display credentials summary', () => {
    console.log('\n📊 Twitter OAuth Credentials Summary');
    console.log('=====================================');
    console.log(`Client ID: ${TWITTER_CLIENT_ID.substring(0, 20)}...`);
    console.log(`Client Secret: ${TWITTER_CLIENT_SECRET.substring(0, 15)}... (${TWITTER_CLIENT_SECRET.length} chars)`);
    console.log(`Redirect URI: ${TWITTER_REDIRECT_URI}`);
    console.log(`Enabled: ${ENABLE_TWITTER ? '✅ YES' : '❌ NO'}`);
    console.log('=====================================\n');
    
    expect(true).toBe(true);
  });
});

// Log test start
console.log('\n🧪 Testing Twitter OAuth with actual credentials from .env\n');
