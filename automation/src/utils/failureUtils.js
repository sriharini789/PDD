const path = require('path');
const fs = require('fs-extra');
const { logger } = require('./logger');
const { collectDeviceLogs } = require('./deviceUtils');

const failureDir = path.resolve(__dirname, '../../reports/failures');
fs.ensureDirSync(failureDir);

const captureFailureArtifacts = async (driver, testName) => {
  const sanitizedName = testName.replace(/[^a-zA-Z0-9_-]/g, '_');
  const screenshotPath = path.join(failureDir, `${sanitizedName}.png`);
  const logsPath = path.join(failureDir, `${sanitizedName}.log`);
  const widgetTreePath = path.join(failureDir, `${sanitizedName}_widget_tree.json`);

  try {
    if (driver) {
      const screenshot = await driver.takeScreenshot();
      await fs.writeFile(screenshotPath, screenshot, 'base64');
      logger.info(`Captured failure screenshot to ${screenshotPath}`);
    }
  } catch (error) {
    logger.warn('Unable to capture screenshot: %s', error.message);
  }

  try {
    await collectDeviceLogs(logsPath);
    logger.info(`Captured device logs to ${logsPath}`);
  } catch (error) {
    logger.warn('Unable to capture device logs: %s', error.message);
  }

  try {
    if (driver && typeof driver.execute === 'function') {
      const widgetTree = await driver.execute('flutter:getDiagnosticsTree', []);
      await fs.writeJSON(widgetTreePath, widgetTree, { spaces: 2 });
      logger.info(`Captured Flutter widget tree to ${widgetTreePath}`);
    }
  } catch (error) {
    logger.warn('Unable to capture Flutter widget tree: %s', error.message);
  }

  return { screenshotPath, logsPath, widgetTreePath };
};

module.exports = { captureFailureArtifacts, failureDir };
