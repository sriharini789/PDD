const PORT = process.env.PORT || 3000;
const BASE_URL = `http://localhost:${PORT}/api`;

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

const runTests = async () => {
  console.log('🤖 Starting Profile & Dashboard API Integration Tests...\n');
  const timestamp = Date.now();
  const testUser = {
    fullName: 'Research Explorer',
    email: `explorer.${timestamp}@example.com`,
    password: 'securepassword123'
  };
  
  let token = '';
  let paperId = null;

  try {
    // 1. Signup & Verification & Login
    console.log('🔑 1. Setting up User Authentication...');
    const signupRes = await fetch(`${BASE_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(testUser)
    });
    const signupData = await signupRes.json();
    const verificationToken = signupData.verificationToken;

    await fetch(`${BASE_URL}/auth/verify-email`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: verificationToken })
    });

    const loginRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: testUser.email, password: testUser.password })
    });
    const loginData = await loginRes.json();
    token = loginData.token;
    console.log('✅ Auth Setup OK\n');

    // 2. Profile setup
    console.log('👤 2. Testing Profile Creation (Academic Level & Interests)...');
    const profileRes = await fetch(`${BASE_URL}/profile`, {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        academicLevel: 'Ph.D. Candidate',
        interests: ['NLP', 'Transformers', 'Self-Attention']
      })
    });
    const profileData = await profileRes.json();
    console.log(`Response Status: ${profileRes.status}`);
    console.log('Profile Response:', profileData);
    if (profileRes.status !== 200) throw new Error('Profile setup failed');
    console.log('✅ Profile Setup OK\n');

    // 3. Get profile
    console.log('👤 3. Testing Get Profile Details...');
    const getProfileRes = await fetch(`${BASE_URL}/profile`, {
      method: 'GET',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
    const getProfileData = await getProfileRes.json();
    console.log(`Response Status: ${getProfileRes.status}`);
    console.log('Get Profile Response:', getProfileData);
    if (getProfileRes.status !== 200) throw new Error('Get profile failed');
    console.log('✅ Get Profile OK\n');

    // 4. Upload paper
    console.log('📄 4. Testing Paper Upload Initiation...');
    const formData = new FormData();
    const mockPdfBlob = new Blob(['%PDF-1.4 mock pdf content'], { type: 'application/pdf' });
    formData.append('file', mockPdfBlob, 'attention_paper.pdf');

    const uploadRes = await fetch(`${BASE_URL}/papers/upload`, {
      method: 'POST',
      headers: { 
        'Authorization': `Bearer ${token}`
      },
      body: formData
    });
    const uploadData = await uploadRes.json();
    console.log(`Response Status: ${uploadRes.status}`);
    console.log('Upload Response:', uploadData);
    if (uploadRes.status !== 201) throw new Error('Upload paper failed');
    paperId = uploadData.paper.id;
    console.log('✅ Upload Initiation OK\n');

    // 5. Simulate background processing
    console.log('⏳ 5. Waiting 7 seconds for simulated AI processing to complete...');
    await delay(7000);
    console.log('✅ Wait complete\n');

    // 6. Fetch papers list
    console.log('📄 6. Testing Fetch Papers List (Dashboard display)...');
    const papersRes = await fetch(`${BASE_URL}/papers`, {
      method: 'GET',
      headers: { 
        'Authorization': `Bearer ${token}`
      }
    });
    const papersData = await papersRes.json();
    console.log(`Response Status: ${papersRes.status}`);
    console.log('Papers List Count:', papersData.papers.length);
    console.log('First Paper Status:', papersData.papers[0]?.status, '| Stage:', papersData.papers[0]?.processing_stage);
    if (papersRes.status !== 200 || papersData.papers.length === 0) throw new Error('Fetch papers list failed');
    console.log('✅ Fetch Papers List OK\n');

    // 7. Fetch single paper detail
    console.log('📄 7. Testing Fetch Paper Detail...');
    const paperDetailRes = await fetch(`${BASE_URL}/papers/${paperId}`, {
      method: 'GET',
      headers: { 
        'Authorization': `Bearer ${token}`
      }
    });
    const paperDetailData = await paperDetailRes.json();
    console.log(`Response Status: ${paperDetailRes.status}`);
    console.log('Paper Detail Summary:', paperDetailData.paper.summary.substring(0, 100) + '...');
    console.log('Paper Detail Topics:', paperDetailData.paper.topics);
    if (paperDetailRes.status !== 200) throw new Error('Fetch paper detail failed');
    console.log('✅ Fetch Paper Detail OK\n');

    // 8. Chat with paper
    console.log('💬 8. Testing Chat with Paper (Sending question)...');
    const question = 'What is the main contribution of this paper?';
    const chatRes = await fetch(`${BASE_URL}/papers/${paperId}/chat`, {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ message: question })
    });
    const chatData = await chatRes.json();
    console.log(`Response Status: ${chatRes.status}`);
    console.log('User Question:', chatData.userMessage.message);
    console.log('AI Answer:', chatData.aiMessage.message);
    if (chatRes.status !== 201) throw new Error('Chat with paper failed');
    console.log('✅ Chat with Paper OK\n');

    // 9. Fetch chat history
    console.log('💬 9. Testing Fetch Chat History...');
    const historyRes = await fetch(`${BASE_URL}/papers/${paperId}/chat`, {
      method: 'GET',
      headers: { 
        'Authorization': `Bearer ${token}`
      }
    });
    const historyData = await historyRes.json();
    console.log(`Response Status: ${historyRes.status}`);
    console.log('Message Count in History:', historyData.messages.length);
    if (historyRes.status !== 200 || historyData.messages.length < 2) throw new Error('Fetch chat history failed');
    console.log('✅ Fetch Chat History OK\n');

    console.log('🎉 All 9 Profile & Dashboard Integration Tests Passed Successfully!');
  } catch (error) {
    console.error('❌ Integration test failed with error:', error.message);
  }
};

setTimeout(runTests, 1000);
