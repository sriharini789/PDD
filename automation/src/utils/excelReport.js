const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs-extra');
const { getDeviceInfo } = require('./deviceUtils');

const buildSummarySheet = (workbook, summary) => {
  const sheet = workbook.addWorksheet('Summary');
  sheet.columns = [
    { header: 'Execution Date', key: 'executionDate', width: 24 },
    { header: 'Device Name', key: 'deviceName', width: 20 },
    { header: 'Android Version', key: 'androidVersion', width: 16 },
    { header: 'Total Tests', key: 'totalTests', width: 12 },
    { header: 'Passed', key: 'passed', width: 10 },
    { header: 'Failed', key: 'failed', width: 10 },
    { header: 'Skipped', key: 'skipped', width: 10 },
    { header: 'Pass Percentage', key: 'passPercentage', width: 16 },
    { header: 'Duration', key: 'duration', width: 16 }
  ];

  sheet.addRow(summary);
};

const buildTestCasesSheet = (workbook, records) => {
  const sheet = workbook.addWorksheet('Test Cases');
  sheet.columns = [
    { header: 'Test ID', key: 'testId', width: 14 },
    { header: 'Module', key: 'module', width: 18 },
    { header: 'Scenario', key: 'scenario', width: 40 },
    { header: 'Status', key: 'status', width: 12 },
    { header: 'Device', key: 'device', width: 16 },
    { header: 'Duration', key: 'duration', width: 14 }
  ];

  records.forEach((record) => sheet.addRow(record));
};

const buildFailedTestsSheet = (workbook, failures) => {
  const sheet = workbook.addWorksheet('Failed Tests');
  sheet.columns = [
    { header: 'Test Name', key: 'testName', width: 30 },
    { header: 'Failure Reason', key: 'failureReason', width: 60 },
    { header: 'Screenshot Path', key: 'screenshotPath', width: 50 },
    { header: 'Device', key: 'device', width: 18 },
    { header: 'Android Version', key: 'androidVersion', width: 16 }
  ];

  failures.forEach((failure) => sheet.addRow(failure));
};

const buildExecutionLogsSheet = (workbook, logs) => {
  const sheet = workbook.addWorksheet('Execution Logs');
  sheet.columns = [
    { header: 'Timestamp', key: 'timestamp', width: 24 },
    { header: 'Test Name', key: 'testName', width: 30 },
    { header: 'Step', key: 'step', width: 36 },
    { header: 'Result', key: 'result', width: 14 },
    { header: 'Remarks', key: 'remarks', width: 50 }
  ];

  logs.forEach((log) => sheet.addRow(log));
};

const generateExcelReport = async ({ summary, testCases, failedTests, executionLogs }) => {
  const workbook = new ExcelJS.Workbook();
  buildSummarySheet(workbook, summary);
  buildTestCasesSheet(workbook, testCases);
  buildFailedTestsSheet(workbook, failedTests);
  buildExecutionLogsSheet(workbook, executionLogs);

  const reportPath = path.resolve(__dirname, '../../reports/Flutter_E2E_Report.xlsx');
  await fs.ensureDir(path.dirname(reportPath));
  await workbook.xlsx.writeFile(reportPath);
  return reportPath;
};

const buildDefaultReportModel = async () => {
  const deviceInfo = await getDeviceInfo();
  return {
    summary: {
      executionDate: new Date().toISOString(),
      deviceName: deviceInfo.model,
      androidVersion: deviceInfo.version,
      totalTests: 0,
      passed: 0,
      failed: 0,
      skipped: 0,
      passPercentage: '0%',
      duration: '0s'
    },
    testCases: [],
    failedTests: [],
    executionLogs: []
  };
};

module.exports = { generateExcelReport, buildDefaultReportModel };
