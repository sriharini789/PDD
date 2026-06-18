const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const config = require('../config/selenium.config');
const { logger } = require('../utils/logger');

let driverInstance = null;

const createDriver = async () => {
  logger.info(`Initializing Selenium session for browser: ${config.browser}`);
  
  const builder = new Builder().forBrowser(config.browser);

  if (config.browser === 'chrome') {
    const options = new chrome.Options();
    if (config.headless) {
      options.addArguments('--headless', '--disable-gpu', '--no-sandbox');
    }
    options.addArguments('--disable-dev-shm-usage');
    builder.setChromeOptions(options);
  }

  driverInstance = await builder.build();

  // Set implicit wait timeout
  await driverInstance.manage().setTimeouts({ implicit: 10000 });
  await driverInstance.manage().window().maximize();

  return driverInstance;
};

const closeDriver = async () => {
  if (driverInstance) {
    try {
      await driverInstance.quit();
      logger.info('Selenium session closed');
    } catch (error) {
      logger.warn('Unable to close Selenium session cleanly', error.message);
    }
    driverInstance = null;
  }
};

const getDriver = () => driverInstance;

module.exports = {
  createDriver,
  closeDriver,
  getDriver
};
