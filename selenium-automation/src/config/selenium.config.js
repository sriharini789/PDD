require('dotenv').config();
const path = require('path');
const localMockPath = 'file:///' + path.resolve(__dirname, '../../mock/login.html').replace(/\\/g, '/');

module.exports = {
  appUrl: process.env.APP_URL || localMockPath,
  browser: process.env.BROWSER || 'chrome',
  headless: process.env.HEADLESS === 'true',
  testEmail: process.env.TEST_EMAIL || 'validuser@example.com',
  testPassword: process.env.TEST_PASSWORD || 'ValidPass123!'
};
