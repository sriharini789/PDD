const { buildDefaultReportModel, generateExcelReport } = require('./excelReport');

let reportData = null;

const initReport = async () => {
  reportData = await buildDefaultReportModel();
  return reportData;
};

const addTestCase = ({ testId, module, scenario, status, device, duration }) => {
  if (!reportData) return;
  reportData.testCases.push({ testId, module, scenario, status, device, duration });
};

const addExecutionLog = ({ timestamp, testName, step, result, remarks }) => {
  if (!reportData) return;
  reportData.executionLogs.push({ timestamp, testName, step, result, remarks });
};

const addFailure = ({ testName, failureReason, screenshotPath, device, androidVersion }) => {
  if (!reportData) return;
  reportData.failedTests.push({ testName, failureReason, screenshotPath, device, androidVersion });
};

const finalizeSummary = (durationMs) => {
  if (!reportData) return;
  const totalTests = reportData.testCases.length;
  const passed = reportData.testCases.filter((test) => test.status === 'Passed').length;
  const failed = reportData.testCases.filter((test) => test.status === 'Failed').length;
  const skipped = reportData.testCases.filter((test) => test.status === 'Skipped').length;
  const passPercentage = totalTests ? `${Math.round((passed / totalTests) * 100)}%` : '0%';

  reportData.summary = {
    ...reportData.summary,
    totalTests,
    passed,
    failed,
    skipped,
    passPercentage,
    duration: `${Math.round(durationMs / 1000)}s`
  };
};

const writeExcelReport = async () => {
  if (!reportData) return null;
  return generateExcelReport(reportData);
};

module.exports = { initReport, addTestCase, addExecutionLog, addFailure, finalizeSummary, writeExcelReport };
