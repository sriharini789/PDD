const fs = require('fs-extra');
const { remote } = require('webdriverio');
const config = require('../config/appium.config');
const { findConnectedDeviceId, getDeviceInfo, installApkWithAdb } = require('../utils/deviceUtils');
const { logger } = require('../utils/logger');

let driverInstance = null;

const createDriver = async () => {
  const deviceId = await findConnectedDeviceId();
  if (deviceId) {
    logger.info(`Using connected device: ${deviceId}`);
    config.capabilities['appium:udid'] = deviceId;
    config.capabilities['appium:deviceName'] = deviceId;
  }

  logger.info('Initializing Appium session with capabilities');
  logger.debug(JSON.stringify(config.capabilities, null, 2));

  driverInstance = await remote({
    protocol: 'http',
    hostname: config.server.hostname,
    port: config.server.port,
    path: config.server.path,
    capabilities: config.capabilities,
    logLevel: 'error',
    connectionRetryCount: 3,
    waitforTimeout: 15000
  });

  return driverInstance;
};

const closeDriver = async () => {
  if (driverInstance) {
    try {
      await driverInstance.deleteSession();
      logger.info('Appium session closed');
    } catch (error) {
      logger.warn('Unable to close Appium session cleanly', error.message);
    }
  }
};

const getDriver = () => driverInstance;

const installApk = async () => {
  const apkPath = config.capabilities['appium:app'] || config.capabilities.app;
  if (!apkPath || !fs.existsSync(apkPath)) {
    throw new Error(`APK path is invalid or missing: ${apkPath}`);
  }

  logger.info(`Installing APK automatically from path: ${apkPath}`);
  await installApkWithAdb(apkPath);
};

module.exports = {
  createDriver,
  closeDriver,
  getDriver,
  installApk
};
