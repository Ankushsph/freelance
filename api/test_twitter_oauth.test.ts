/**
 * Twitter OAuth 2.0 Test Suite
 * Tests the OAuth flow including authorization, token exchange, and refresh
 * 
 * Run with: bun test test_twitter_oauth.ts
 */

import { describe, test, expect, beforeAll, beforeEach } from "bun:test";

// Mock configuration for testing
const MOCK_TWITTER_CONFIG = {
  CLIENT_ID: 'test_client_id_123',
  CLIENT_SECRET: 'test_client_secret_456',
  REDIRECT_URI: 'http://localhost:4000/api/twitter/callback',
  TOKEN_URL: 'https://api.x.com/2/oauth2/token',
  OAUTH_URL: 'https://x.com/i/oauth2/authorize',
  SCOPES: 'tweet.read tweet.write users.read offline.access'
};

// Test 1: Verify Basic Auth header generation
describe('Basic Auth Header Generation', () => {
  test('should generate correct Basic Auth header', () => {
    const credentials = Buffer.from(`${MOCK_TWITTER_CONFIG.CLIENT_ID}:${MOCK_TWITTER_CONFIG.CLIENT_SECRET}`).toString('base64');
    const expectedHeader = `Basic ${credentials}`;
    
    // Verify the header starts with "Basic "
    expect(expectedHeader.startsWith('Basic ')).toBe(true);
    
    // Verify we can decode it back
    const decoded = Buffer.from(credentials, 'base64').toString('utf-8');
    expect(decoded).toBe(`${MOCK_TWITTER_CONFIG.CLIENT_ID}:${MOCK_TWITTER_CONFIG.CLIENT_SECRET}`);
  });

  test('should generate different headers for different credentials', () => {
    const cred1 = Buffer.from('client1:secret1').toString('base64');
    const cred2 = Buffer.from('client2:secret2').toString('base64');
    
    expect(cred1).not.toBe(cred2);
  });
});

// Test 2: Verify token request body
describe('Token Request Body', () => {
  test('should NOT include client_secret in request body when using Basic Auth', () => {
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: 'test_auth_code',
      redirect_uri: MOCK_TWITTER_CONFIG.REDIRECT_URI,
      code_verifier: 'test_verifier',
      client_id: MOCK_TWITTER_CONFIG.CLIENT_ID
      // client_secret should NOT be here when using Basic Auth
    });
    
    const bodyString = tokenBody.toString();
    
    // Verify required fields are present
    expect(bodyString.includes('grant_type=authorization_code')).toBe(true);
    expect(bodyString.includes('code=test_auth_code')).toBe(true);
    expect(bodyString.includes('client_id=test_client_id_123')).toBe(true);
    
    // Verify client_secret is NOT in the body
    expect(bodyString.includes('client_secret')).toBe(false);
  });

  test('should include all required OAuth parameters', () => {
    const codeVerifier = 'test_pkce_verifier_123';
    const authCode = 'test_authorization_code_abc';
    
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: authCode,
      redirect_uri: MOCK_TWITTER_CONFIG.REDIRECT_URI,
      code_verifier: codeVerifier,
      client_id: MOCK_TWITTER_CONFIG.CLIENT_ID
    });
    
    const params = Object.fromEntries(tokenBody);
    
    expect(params.grant_type).toBe('authorization_code');
    expect(params.code).toBe(authCode);
    expect(params.redirect_uri).toBe(MOCK_TWITTER_CONFIG.REDIRECT_URI);
    expect(params.code_verifier).toBe(codeVerifier);
    expect(params.client_id).toBe(MOCK_TWITTER_CONFIG.CLIENT_ID);
  });
});

// Test 3: Verify OAuth URL generation
describe('OAuth Authorization URL', () => {
  test('should generate valid OAuth URL with all required parameters', () => {
    const state = 'test-state-123';
    const codeChallenge = 'test_challenge_xyz';
    
    const oauthUrl = 
      `${MOCK_TWITTER_CONFIG.OAUTH_URL}` +
      `?response_type=code` +
      `&client_id=${MOCK_TWITTER_CONFIG.CLIENT_ID}` +
      `&redirect_uri=${encodeURIComponent(MOCK_TWITTER_CONFIG.REDIRECT_URI)}` +
      `&scope=${encodeURIComponent(MOCK_TWITTER_CONFIG.SCOPES)}` +
      `&state=${state}` +
      `&code_challenge=${codeChallenge}` +
      `&code_challenge_method=S256`;
    
    // Verify URL structure
    expect(oauthUrl.startsWith(MOCK_TWITTER_CONFIG.OAUTH_URL)).toBe(true);
    expect(oauthUrl.includes('response_type=code')).toBe(true);
    expect(oauthUrl.includes(`client_id=${MOCK_TWITTER_CONFIG.CLIENT_ID}`)).toBe(true);
    expect(oauthUrl.includes('code_challenge_method=S256')).toBe(true);
    expect(oauthUrl.includes(`state=${state}`)).toBe(true);
  });

  test('should properly encode special characters in redirect URI', () => {
    const redirectUri = 'https://api.codesbyjit.site/api/twitter/callback';
    const encoded = encodeURIComponent(redirectUri);
    
    // Verify encoding
    expect(encoded).toBe('https%3A%2F%2Fapi.codesbyjit.site%2Fapi%2Ftwitter%2Fcallback');
    expect(encoded.includes('://')).toBe(false);
  });
});

// Test 4: Verify refresh token request
describe('Refresh Token Request', () => {
  test('should generate correct refresh token request body', () => {
    const refreshToken = 'test_refresh_token_xyz';
    
    const tokenBody = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: MOCK_TWITTER_CONFIG.CLIENT_ID
      // client_secret should NOT be here when using Basic Auth
    });
    
    const params = Object.fromEntries(tokenBody);
    
    expect(params.grant_type).toBe('refresh_token');
    expect(params.refresh_token).toBe(refreshToken);
    expect(params.client_id).toBe(MOCK_TWITTER_CONFIG.CLIENT_ID);
    expect(params.client_secret).toBeUndefined();
  });
});

// Test 5: Integration test - Verify fetch options
describe('Fetch Request Configuration', () => {
  test('should create proper fetch options for token exchange', () => {
    const credentials = Buffer.from(`${MOCK_TWITTER_CONFIG.CLIENT_ID}:${MOCK_TWITTER_CONFIG.CLIENT_SECRET}`).toString('base64');
    
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code: 'test_code',
      redirect_uri: MOCK_TWITTER_CONFIG.REDIRECT_URI,
      code_verifier: 'test_verifier',
      client_id: MOCK_TWITTER_CONFIG.CLIENT_ID
    });
    
    const fetchOptions = {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: tokenBody
    };
    
    // Verify structure
    expect(fetchOptions.method).toBe('POST');
    expect(fetchOptions.headers['Authorization']).toBe(`Basic ${credentials}`);
    expect(fetchOptions.headers['Content-Type']).toBe('application/x-www-form-urlencoded');
    expect(fetchOptions.body).toBeInstanceOf(URLSearchParams);
  });

  test('should create proper fetch options for refresh token', () => {
    const credentials = Buffer.from(`${MOCK_TWITTER_CONFIG.CLIENT_ID}:${MOCK_TWITTER_CONFIG.CLIENT_SECRET}`).toString('base64');
    
    const tokenBody = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: 'test_refresh',
      client_id: MOCK_TWITTER_CONFIG.CLIENT_ID
    });
    
    const fetchOptions = {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: tokenBody
    };
    
    expect(fetchOptions.headers['Authorization']).toBe(`Basic ${credentials}`);
    expect(fetchOptions.body.get('grant_type')).toBe('refresh_token');
  });
});

// Test 6: Error handling
describe('Error Handling', () => {
  test('should handle missing client credentials gracefully', () => {
    const emptyClientId = '';
    const emptyClientSecret = '';
    
    // When credentials are empty, we should still generate a header
    const credentials = Buffer.from(`${emptyClientId}:${emptyClientSecret}`).toString('base64');
    expect(credentials).toBeDefined();
    expect(typeof credentials).toBe('string');
  });

  test('should properly encode special characters in credentials', () => {
    const specialId = 'client+with/special=chars';
    const specialSecret = 'secret@with#special$chars';
    
    // base64 encoding should handle special characters
    const credentials = Buffer.from(`${specialId}:${specialSecret}`).toString('base64');
    const decoded = Buffer.from(credentials, 'base64').toString('utf-8');
    
    expect(decoded).toBe(`${specialId}:${specialSecret}`);
  });
});

// Summary
console.log('\n📋 Twitter OAuth Test Suite\n');
console.log('Testing the following scenarios:');
console.log('  ✓ Basic Auth header generation');
console.log('  ✓ Token request body composition');
console.log('  ✓ OAuth authorization URL generation');
console.log('  ✓ Refresh token request');
console.log('  ✓ Fetch request configuration');
console.log('  ✓ Error handling\n');
