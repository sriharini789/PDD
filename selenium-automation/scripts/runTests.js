require('dotenv').config();
const path = require('path');
const Mocha = require('mocha');
const { ensureReportFolders, buildMochawesomeOptions } = require('../src/tests/helpers/reportHelper');

(async () => {
  await ensureReportFolders();

  const mocha = new Mocha({
    timeout: 180000,
    reporter: 'mochawesome',
    reporterOptions: buildMochawesomeOptions()
  });

  mocha.addFile(path.resolve(__dirname, '../src/tests/login.spec.js'));

  mocha.run((failures) => {
    process.exitCode = failures ? 1 : 0;
  });
})();
