const { expect } = require('chai');
const LoginPage = require('../pages/loginPage');
const HomePage = require('../pages/homePage');
const { testContext, setup, handleTestResult, finalize } = require('./helpers/testContext');
const { findByText } = require('../utils/flutterFinder');
const { addTestCase } = require('../utils/reportManager');

describe('Flutter App E2E - Login and Navigation', function () {
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

  it('should show validation messages when login fields are empty', async () => {
    const loginPage = new LoginPage(testContext.driver);
    await loginPage.submitLogin();

    const emailError = await loginPage.getEmailError();
    const passwordError = await loginPage.getPasswordError();

    expect(emailError).to.exist.and.to.include('required');
    expect(passwordError).to.exist.and.to.include('required');

    addTestCase({
      testId: 'TC001',
      module: 'Authentication',
      scenario: 'Empty login fields show validation',
      status: 'Passed',
      device: process.env.DEVICE_NAME || 'Android Device',
      duration: 'N/A'
    });
  });

  it('should reject invalid credentials and show error message', async () => {
    const loginPage = new LoginPage(testContext.driver);
    await loginPage.enterEmail('baduser@example.com');
    await loginPage.enterPassword('incorrect');
    await loginPage.submitLogin();

    const error = await testContext.driver.$('android=new UiSelector().textContains("invalid")');
    const visible = await error.isDisplayed();

    expect(visible).to.be.true;

    addTestCase({
      testId: 'TC002',
      module: 'Authentication',
      scenario: 'Invalid credentials show error',
      status: 'Passed',
      device: process.env.DEVICE_NAME || 'Android Device',
      duration: 'N/A'
    });
  });

  it('should login successfully and validate home navigation', async () => {
    const loginPage = new LoginPage(testContext.driver);
    const homePage = new HomePage(testContext.driver);

    await loginPage.enterEmail('validuser@example.com');
    await loginPage.enterPassword('ValidPass123!');
    await loginPage.submitLogin();

    const homeLoaded = await homePage.isLoaded();
    expect(homeLoaded).to.be.true;

    addTestCase({
      testId: 'TC003',
      module: 'Authentication',
      scenario: 'Valid login navigates to home',
      status: 'Passed',
      device: process.env.DEVICE_NAME || 'Android Device',
      duration: 'N/A'
    });
  });

  it('should logout and return to login screen', async () => {
    const homePage = new HomePage(testContext.driver);
    await homePage.logout();

    const loginButton = await testContext.driver.findElement(findByText('Login'));
    expect(await loginButton.isDisplayed()).to.be.true;

    addTestCase({
      testId: 'TC004',
      module: 'Authentication',
      scenario: 'Logout returns to login page',
      status: 'Passed',
      device: process.env.DEVICE_NAME || 'Android Device',
      duration: 'N/A'
    });
  });
});
