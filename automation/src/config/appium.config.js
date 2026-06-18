require('dotenv').config();
const path = require('path');
const repoRoot = path.resolve(__dirname, '../..');

const resolveApkPath = () => {
  const configuredPath = process.env.APK_PATH || './app/app-release.apk';
  const resolvedPath = path.isAbsolute(configuredPath)
    ? configuredPath
    : path.resolve(repoRoot, configuredPath);
  return resolvedPath;
};

module.exports = {
  server: {
    hostname: process.env.APPIUM_HOST || '127.0.0.1',
    port: Number(process.env.APPIUM_PORT || 4723),
    path: process.env.APPIUM_PATH || '/'
  },
  capabilities: {
    platformName: 'Android',
    'appium:automationName': process.env.USE_FALLBACK_UIAUTOMATOR2 === 'true' ? 'UIAutomator2' : 'Flutter',
    'appium:deviceName': process.env.DEVICE_NAME || 'Android Emulator',
    'appium:platformVersion': process.env.ANDROID_PLATFORM_VERSION || '',
    'appium:app': resolveApkPath(),
    'appium:appPackage': process.env.APP_PACKAGE || 'com.researchai.research_ai',
    'appium:appActivity': process.env.APP_ACTIVITY || 'com.researchai.research_ai.MainActivity',
    'appium:autoGrantPermissions': true,
    'appium:newCommandTimeout': 300,
    'appium:noReset': process.env.NO_RESET !== 'false',
    'appium:fullReset': false,
    'appium:unicodeKeyboard': true,
    'appium:resetKeyboard': true,
    'appium:disableWindowAnimation': true,
    'appium:allowTestPackages': true,
    'appium:enableMultiWindows': true
  }
};
