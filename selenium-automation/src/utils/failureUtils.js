const path = require('path');
const fs = require('fs-extra');
const { logger } = require('./logger');

const failureDir = path.resolve(__dirname, '../../reports/failures');
fs.ensureDirSync(failureDir);

const captureFailureArtifacts = async (driver, testName) => {
  const sanitizedName = testName.replace(/[^a-zA-Z0-9_-]/g, '_');
  const screenshotPath = path.join(failureDir, `${sanitizedName}.png`);

  try {
    if (driver) {
      const screenshot = await driver.takeScreenshot();
      await fs.writeFile(screenshotPath, screenshot, 'base64');
      logger.info(`Captured failure screenshot to ${screenshotPath}`);
    }
  } catch (error) {
    logger.warn('Unable to capture screenshot: %s', error.message);
  }

  return { screenshotPath };
};

module.exports = { captureFailureArtifacts, failureDir };
