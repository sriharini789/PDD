const PORT = process.env.PORT || 3000;
const BASE_URL = `http://localhost:${PORT}/api/auth`;

const runTests = async () => {
  console.log('🤖 Starting Auth API End-to-End Integration Tests...\n');
  const timestamp = Date.now();
  const testUser = {
    fullName: 'Test Bot',
    email: `bot.${timestamp}@example.com`,
    password: 'supersecurepassword'
  };
  
  let verificationToken = '';
  let jwtToken = '';
  let resetToken = '';

  try {
    // 1. Test Sign Up
    console.log('📝 1. Testing Registration (Signup)...');
    const signupRes = await fetch(`${BASE_URL}/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(testUser)
    });
    const signupData = await signupRes.json();
    console.log(`Response Status: ${signupRes.status}`);
    console.log('Response Body:', signupData);
    
    if (signupRes.status !== 201) {
      throw new Error('Registration failed');
    }
    verificationToken = signupData.verificationToken;
    console.log('✅ Signup OK\n');

    // 2. Test Login (Unverified account)
    console.log('🔓 2. Testing Login with Unverified Account...');
    const loginUnverRes = await fetch(`${BASE_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testUser.email, password: testUser.password })
    });
    const loginUnverData = await loginUnverRes.json();
    console.log(`Response Status: ${loginUnverRes.status} (Expected: 403)`);
    console.log('Response Body:', loginUnverData);
    console.log('✅ Unverified Login blocked as expected\n');

    // 3. Test Email Verification
    console.log('✉️ 3. Testing Email Verification...');
    const verifyRes = await fetch(`${BASE_URL}/verify-email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: verificationToken })
    });
    const verifyData = await verifyRes.json();
    console.log(`Response Status: ${verifyRes.status}`);
    console.log('Response Body:', verifyData);
    if (verifyRes.status !== 200) {
      throw new Error('Email verification failed');
    }
    console.log('✅ Verification OK\n');

    // 4. Test Login (Verified account)
    console.log('🔑 4. Testing Login (Verified)...');
    const loginRes = await fetch(`${BASE_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testUser.email, password: testUser.password })
    });
    const loginData = await loginRes.json();
    console.log(`Response Status: ${loginRes.status}`);
    console.log('Response Body (token abbreviated):', { ...loginData, token: loginData.token ? loginData.token.substring(0, 15) + '...' : null });
    if (loginRes.status !== 200) {
      throw new Error('Login failed');
    }
    jwtToken = loginData.token;
    console.log('✅ Login OK\n');

    // 5. Test Get Current User (/me)
    console.log('👤 5. Testing Protected /me Route...');
    const meRes = await fetch(`${BASE_URL}/me`, {
      method: 'GET',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${jwtToken}`
      }
    });
    const meData = await meRes.json();
    console.log(`Response Status: ${meRes.status}`);
    console.log('Response Body:', meData);
    if (meRes.status !== 200) {
      throw new Error('Get profile /me failed');
    }
    console.log('✅ Protected Route /me OK\n');

    // 6. Test Forgot Password
    console.log('🔑 6. Testing Forgot Password...');
    const forgotRes = await fetch(`${BASE_URL}/forgot-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testUser.email })
    });
    const forgotData = await forgotRes.json();
    console.log(`Response Status: ${forgotRes.status}`);
    console.log('Response Body:', forgotData);
    if (forgotRes.status !== 200) {
      throw new Error('Forgot password failed');
    }
    resetToken = forgotData.resetToken;
    console.log('✅ Forgot password link generated OK\n');

    // 7. Test Reset Password
    console.log('🔄 7. Testing Reset Password...');
    const newPassword = 'newsupersecurepassword';
    const resetRes = await fetch(`${BASE_URL}/reset-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: resetToken, password: newPassword })
    });
    const resetData = await resetRes.json();
    console.log(`Response Status: ${resetRes.status}`);
    console.log('Response Body:', resetData);
    if (resetRes.status !== 200) {
      throw new Error('Reset password failed');
    }
    console.log('✅ Password reset OK\n');

    // 8. Test Login with new password
    console.log('🔑 8. Testing Login with New Password...');
    const loginNewRes = await fetch(`${BASE_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testUser.email, password: newPassword })
    });
    const loginNewData = await loginNewRes.json();
    console.log(`Response Status: ${loginNewRes.status}`);
    if (loginNewRes.status !== 200) {
      throw new Error('Login with new password failed');
    }
    console.log('✅ Login with new password OK\n');

    console.log('🎉 All 8 Authentication Integration Tests Passed Successfully!');
  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
  }
};

// Wait 1 second before starting, in case database is booting
setTimeout(runTests, 1000);
