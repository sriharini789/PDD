const { exec } = require('child_process');
const util = require('util');
const fs = require('fs-extra');
const path = require('path');
const execAsync = util.promisify(exec);

const findAdb = () => {
  const envPaths = [process.env.ANDROID_HOME, process.env.ANDROID_SDK_ROOT].filter(Boolean);
  const adbName = process.platform === 'win32' ? 'adb.exe' : 'adb';

  for (const base of envPaths) {
    const candidate = path.join(base, 'platform-tools', adbName);
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  return adbName;
};

const runAdb = async (args) => {
  const adb = findAdb();
  const escapedArgs = args.map(arg => {
    if (typeof arg === 'string' && arg.includes(' ') && !arg.startsWith('"') && !arg.endsWith('"')) {
      return `"${arg}"`;
    }
    return arg;
  });
  const command = `"${adb}" ${escapedArgs.join(' ')}`;
  const { stdout, stderr } = await execAsync(command, { timeout: 120000 });
  if (stderr) {
    return stdout.trim();
  }
  return stdout.trim();
};

const listConnectedDevices = async () => {
  const output = await runAdb(['devices']);
  return output
    .split('\n')
    .slice(1)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('*'))
    .map((line) => line.split('\t')[0]);
};

const findConnectedDeviceId = async () => {
  const devices = await listConnectedDevices();
  return devices.length > 0 ? devices[0] : null;
};

const getDeviceInfo = async () => {
  const deviceId = process.env.DEVICE_NAME || (await findConnectedDeviceId());
  if (!deviceId) {
    return {
      deviceId: 'unknown',
      model: 'unknown',
      version: process.env.ANDROID_PLATFORM_VERSION || 'unknown'
    };
  }

  try {
    const model = await runAdb(['-s', deviceId, 'shell', 'getprop', 'ro.product.model']);
    const version = await runAdb(['-s', deviceId, 'shell', 'getprop', 'ro.build.version.release']);
    return { deviceId, model: model || 'Android Device', version: version || 'unknown' };
  } catch {
    return { deviceId, model: 'Android Device', version: process.env.ANDROID_PLATFORM_VERSION || 'unknown' };
  }
};

const installApkWithAdb = async (apkPath) => {
  const absoluteApk = path.isAbsolute(apkPath) ? apkPath : path.resolve(process.cwd(), apkPath);
  
  const deviceId = await findConnectedDeviceId();
  if (!deviceId) {
    console.log('No physical device connected. Skipping APK installation.');
    return;
  }

  if (!fs.existsSync(absoluteApk)) {
    throw new Error(`APK not found at ${absoluteApk}`);
  }

  const target = deviceId ? ['-s', deviceId] : [];
  await runAdb([...target, 'install', '-r', absoluteApk]);
};

const collectDeviceLogs = async (outputFile) => {
  const deviceId = process.env.DEVICE_NAME || (await findConnectedDeviceId());
  if (!deviceId) {
    return 'No connected device found for log collection';
  }

  const logs = await runAdb(['-s', deviceId, 'logcat', '-d']);
  await fs.outputFile(outputFile, logs, 'utf8');
  return outputFile;
};

module.exports = {
  findAdb,
  runAdb,
  listConnectedDevices,
  findConnectedDeviceId,
  getDeviceInfo,
  installApkWithAdb,
  collectDeviceLogs
};
