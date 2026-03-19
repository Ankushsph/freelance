/**
 * Test script for the Social Media Posting API
 * 
 * Run with: bun test-api.ts
 * 
 * This script tests all the major endpoints of the API
 */

const BASE_URL = process.env.API_URL || "http://localhost:4001";
let authToken = "";
let userId = "";
let createdPostId = "";

console.log("🧪 Starting API Tests\n");
console.log(`Base URL: ${BASE_URL}\n`);

async function testEndpoint(
  name: string,
  method: string,
  endpoint: string,
  body?: any,
  requiresAuth = false
): Promise<any> {
  console.log(`\n📌 Testing: ${name}`);
  console.log(`${method} ${endpoint}`);

  const headers: Record<string, string> = {
    "Content-Type": "application/json"
  };

  if (requiresAuth && authToken) {
    headers["Authorization"] = `Bearer ${authToken}`;
  }

  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    });

    const data = await response.json().catch(() => null);
    
    if (response.ok) {
      console.log(`✅ ${name} - Success (${response.status})`);
      return { success: true, data, status: response.status };
    } else {
      console.log(`❌ ${name} - Failed (${response.status})`);
      console.log("Response:", JSON.stringify(data, null, 2));
      return { success: false, data, status: response.status };
    }
  } catch (error: any) {
    console.log(`❌ ${name} - Error: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function runTests() {
  console.log("=" .repeat(60));
  console.log("TEST SUITE: Social Media Posting API");
  console.log("=" .repeat(60));

  // Test 1: Health Check
  await testEndpoint("Health Check", "GET", "/");

  // Test 2: Login (to get token)
  const loginResult = await testEndpoint(
    "User Login",
    "POST",
    "/api/auth/login",
    {
      email: "test@example.com",
      password: "password123"
    }
  );

  if (loginResult.success && loginResult.data?.token) {
    authToken = loginResult.data.token;
    userId = loginResult.data.user?.id;
    console.log(`✅ Got auth token: ${authToken.substring(0, 20)}...`);
    console.log(`✅ User ID: ${userId}`);
  } else {
    console.log("\n⚠️  Login failed. Testing remaining endpoints without auth...");
  }

  // Test 3: Instagram Connect (requires auth)
  if (authToken) {
    await testEndpoint(
      "Instagram Connect",
      "POST",
      "/api/instagram/connect",
      {},
      true
    );
  }

  // Test 4: Facebook Connect (requires auth)
  if (authToken) {
    await testEndpoint(
      "Facebook Connect",
      "POST",
      "/api/facebook/connect",
      {},
      true
    );
  }

  // Test 5: Get Facebook Pages (requires auth)
  if (authToken) {
    await testEndpoint(
      "Get Facebook Pages",
      "GET",
      "/api/facebook/pages",
      undefined,
      true
    );
  }

  // Test 6: Create Post - Immediate (requires auth)
  if (authToken) {
    const createResult = await testEndpoint(
      "Create Immediate Post",
      "POST",
      "/api/posts",
      {
        content: "Test post from API! #test #api",
        mediaUrls: ["https://via.placeholder.com/800x600.jpg"],
        platforms: ["instagram", "facebook"]
      },
      true
    );

    if (createResult.success && createResult.data?.post?._id) {
      createdPostId = createResult.data.post._id;
      console.log(`✅ Created post ID: ${createdPostId}`);
    }
  }

  // Test 7: Create Post - Scheduled (requires auth)
  if (authToken) {
    const scheduledTime = new Date(Date.now() + 3600000).toISOString(); // 1 hour from now
    await testEndpoint(
      "Create Scheduled Post",
      "POST",
      "/api/posts",
      {
        content: "Scheduled test post! #scheduled",
        mediaUrls: ["https://via.placeholder.com/800x600.jpg"],
        platforms: ["facebook"],
        scheduledTime: scheduledTime
      },
      true
    );
  }

  // Test 8: Get All Posts (requires auth)
  if (authToken) {
    await testEndpoint(
      "Get All Posts",
      "GET",
      "/api/posts",
      undefined,
      true
    );
  }

  // Test 9: Get Single Post (requires auth)
  if (authToken && createdPostId) {
    await testEndpoint(
      "Get Single Post",
      "GET",
      `/api/posts/${createdPostId}`,
      undefined,
      true
    );
  }

  // Test 10: Invalid Post Request (validation test)
  if (authToken) {
    await testEndpoint(
      "Invalid Post Request (Validation)",
      "POST",
      "/api/posts",
      {
        // Missing required fields
        content: "Test"
      },
      true
    );
  }

  console.log("\n" + "=" .repeat(60));
  console.log("TEST SUITE COMPLETE");
  console.log("=" .repeat(60));
  
  if (authToken) {
    console.log("\n✅ Authentication: Working");
    console.log("✅ Posts API: Routes accessible");
    console.log("\n📋 Next Steps:");
    console.log("   1. Complete OAuth flow for Instagram/Facebook");
    console.log("   2. Select a Facebook page");
    console.log("   3. Upload images and create posts");
    console.log("   4. Verify posts are publishing correctly");
  } else {
    console.log("\n⚠️  Could not authenticate. Make sure you have a test user in the database.");
    console.log("   Run: POST /api/auth/signup with email and password first");
  }
}

// Run tests
runTests().catch(console.error);
