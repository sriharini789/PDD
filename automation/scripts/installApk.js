require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const path = require('path');
const { installApkWithAdb } = require('../src/utils/deviceUtils');

(async () => {
  const apkPath = process.env.APK_PATH || './app/app-release.apk';
  const absoluteApkPath = path.isAbsolute(apkPath) ? apkPath : path.resolve(process.cwd(), apkPath);

  try {
    await installApkWithAdb(absoluteApkPath);
    console.log(`APK installed from ${absoluteApkPath}`);
    process.exit(0);
  } catch (error) {
    console.error('Failed to install APK:', error.message);
    process.exit(1);
  }
})();
