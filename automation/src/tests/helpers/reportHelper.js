const fs = require('fs-extra');
const path = require('path');

const ensureReportFolders = async () => {
  await fs.ensureDir(path.resolve(__dirname, '../../../reports'));
  await fs.ensureDir(path.resolve(__dirname, '../../../reports/failures'));
};

const buildMochawesomeOptions = () => ({
  reportDir: path.resolve(process.cwd(), 'reports'),
  reportFilename: 'index',
  quiet: true,
  overwrite: true,
  html: true,
  json: true,
  charts: true,
  inlineAssets: true
});

module.exports = { ensureReportFolders, buildMochawesomeOptions };
