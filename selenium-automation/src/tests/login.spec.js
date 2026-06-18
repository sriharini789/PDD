const { expect } = require('chai');
const config = require('../config/selenium.config');
const LoginPage = require('../pages/loginPage');
const HomePage = require('../pages/homePage');
const { testContext, setup, handleTestResult, finalize } = require('./helpers/testContext');
const { addTestCase, addExecutionLog } = require('../utils/reportManager');

describe('Web App E2E - Login and Navigation', function () {
  this.timeout(180000);

  before(async () => {
    await setup();
  });

  afterEach(async function () {
    await handleTestResult(this.currentTest);
  });

  after(async () => {
    await finalize();
  });

  it('should navigate to the web application login page', async () => {
    const startTime = Date.now();
    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Navigation',
      step: 'Navigate to appUrl',
      result: 'Started',
      remarks: `Navigating to ${config.appUrl}`
    });

    await testContext.driver.get(config.appUrl);

    addTestCase({
      testId: 'TC_WEB_001',
      module: 'Navigation',
      scenario: 'Navigate to App Url',
      status: 'Passed',
      browser: config.browser,
      duration: `${Math.round((Date.now() - startTime) / 1000)}s`
    });

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Navigation',
      step: 'Open URL',
      result: 'Passed',
      remarks: 'Application login page loaded successfully'
    });
  });

  it('should show validation messages when login fields are empty', async () => {
    const startTime = Date.now();
    const loginPage = new LoginPage(testContext.driver);

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Login Validation',
      step: 'Click Login with empty fields',
      result: 'Started',
      remarks: 'Submitting login without input values'
    });

    await loginPage.submitLogin();

    const emailError = await loginPage.getEmailError();
    const passwordError = await loginPage.getPasswordError();

    expect(emailError).to.include('required');
    expect(passwordError).to.include('required');

    addTestCase({
      testId: 'TC_WEB_002',
      module: 'Authentication',
      scenario: 'Empty login fields show validation',
      status: 'Passed',
      browser: config.browser,
      duration: `${Math.round((Date.now() - startTime) / 1000)}s`
    });

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Login Validation',
      step: 'Verify validation messages',
      result: 'Passed',
      remarks: `Email Error: "${emailError}", Password Error: "${passwordError}"`
    });
  });

  it('should reject invalid credentials and show error message', async () => {
    const startTime = Date.now();
    const loginPage = new LoginPage(testContext.driver);

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Invalid Login',
      step: 'Enter invalid credentials and submit',
      result: 'Started',
      remarks: 'Submitting credentials for wronguser@example.com'
    });

    await loginPage.enterEmail('wronguser@example.com');
    await loginPage.enterPassword('incorrectpass');
    await loginPage.submitLogin();

    const emailError = await loginPage.getEmailError();
    expect(emailError).to.include('Invalid');

    addTestCase({
      testId: 'TC_WEB_003',
      module: 'Authentication',
      scenario: 'Invalid credentials show error',
      status: 'Passed',
      browser: config.browser,
      duration: `${Math.round((Date.now() - startTime) / 1000)}s`
    });

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Invalid Login',
      step: 'Verify invalid credential error',
      result: 'Passed',
      remarks: `Error text displayed: "${emailError}"`
    });
  });

  it('should login successfully and validate home navigation', async () => {
    const startTime = Date.now();
    const loginPage = new LoginPage(testContext.driver);
    const homePage = new HomePage(testContext.driver);

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Valid Login',
      step: 'Enter valid credentials and submit',
      result: 'Started',
      remarks: `Logging in with ${config.testEmail}`
    });

    await loginPage.enterEmail(config.testEmail);
    await loginPage.enterPassword(config.testPassword);
    await loginPage.submitLogin();

    const homeLoaded = await homePage.isLoaded();
    expect(homeLoaded).to.be.true;

    addTestCase({
      testId: 'TC_WEB_004',
      module: 'Authentication',
      scenario: 'Valid login navigates to home',
      status: 'Passed',
      browser: config.browser,
      duration: `${Math.round((Date.now() - startTime) / 1000)}s`
    });

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Valid Login',
      step: 'Verify dashboard loaded',
      result: 'Passed',
      remarks: 'Dashboard page displayed welcome message successfully'
    });
  });

  it('should logout and return to login screen', async () => {
    const startTime = Date.now();
    const homePage = new HomePage(testContext.driver);
    const loginPage = new LoginPage(testContext.driver);

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Logout',
      step: 'Click logout button',
      result: 'Started',
      remarks: 'Attempting to log out from dashboard'
    });

    await homePage.logout();

    const isLoginVisible = await loginPage.isDisplayed(loginPage.loginButton);
    expect(isLoginVisible).to.be.true;

    addTestCase({
      testId: 'TC_WEB_005',
      module: 'Authentication',
      scenario: 'Logout returns to login page',
      status: 'Passed',
      browser: config.browser,
      duration: `${Math.round((Date.now() - startTime) / 1000)}s`
    });

    addExecutionLog({
      timestamp: new Date().toISOString(),
      testName: 'Logout',
      step: 'Verify login page loaded',
      result: 'Passed',
      remarks: 'Login button is displayed back on screen'
    });
  });
});
