const { createDriver, closeDriver, installApk } = require('../../driver/driverFactory');
const { captureFailureArtifacts } = require('../../utils/failureUtils');
const { initReport, addFailure, finalizeSummary, writeExcelReport } = require('../../utils/reportManager');

const testContext = {
  driver: null,
  reportData: null,
  startTime: null
};

const setup = async () => {
  testContext.reportData = await initReport();
  testContext.startTime = Date.now();
  await installApk();
  testContext.driver = await createDriver();
};

const handleTestResult = async (test) => {
  if (test && test.state === 'failed') {
    const screenshotPath = `reports/failures/${test.fullTitle().replace(/[^a-zA-Z0-9_-]/g, '_')}.png`;
    await captureFailureArtifacts(testContext.driver, test.fullTitle());
    addFailure({
      testName: test.fullTitle(),
      failureReason: test.err ? test.err.message : 'Unknown failure',
      screenshotPath,
      device: process.env.DEVICE_NAME || 'Android Device',
      androidVersion: process.env.ANDROID_PLATFORM_VERSION || 'unknown'
    });
  }
};

const finalize = async () => {
  finalizeSummary(Date.now() - testContext.startTime);
  await writeExcelReport();
  await closeDriver();
};

module.exports = { testContext, setup, handleTestResult, finalize };
