require('dotenv').config();
const path = require('path');
const { spawn } = require('child_process');
const Mocha = require('mocha');
const { ensureReportFolders, buildMochawesomeOptions } = require('../src/tests/helpers/reportHelper');

const runAppiumServer = () => {
  const appiumCmd = path.resolve(__dirname, '../node_modules/.bin/appium.cmd');
  const appiumProcess = spawn(`"${appiumCmd}"`, ['--use-drivers=flutter', '--log-level', 'error'], {
    cwd: path.resolve(__dirname, '..'),
    stdio: ['ignore', 'pipe', 'pipe'],
    shell: true
  });

  appiumProcess.stdout.on('data', (data) => {
    process.stdout.write(`[Appium] ${data}`);
  });

  appiumProcess.stderr.on('data', (data) => {
    process.stderr.write(`[Appium] ${data}`);
  });

  appiumProcess.on('exit', (code) => {
    console.log(`Appium exited with code ${code}`);
  });

  return appiumProcess;
};

(async () => {
  await ensureReportFolders();

  const appiumProcess = runAppiumServer();
  await new Promise((resolve) => setTimeout(resolve, 7000));

  const mocha = new Mocha({
    timeout: 180000,
    reporter: 'mochawesome',
    reporterOptions: buildMochawesomeOptions()
  });

  mocha.addFile(path.resolve(__dirname, '../src/tests/login.spec.js'));

  mocha.run(async (failures) => {
    if (appiumProcess && !appiumProcess.killed) {
      appiumProcess.kill();
    }
    process.exitCode = failures ? 1 : 0;
  });
})();
