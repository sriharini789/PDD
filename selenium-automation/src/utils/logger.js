const { createLogger, transports, format } = require('winston');
const path = require('path');
const fs = require('fs-extra');

const logDir = path.resolve(__dirname, '../../reports/logs');
fs.ensureDirSync(logDir);

const logger = createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: format.combine(
    format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    format.errors({ stack: true }),
    format.splat(),
    format.printf(({ timestamp, level, message, stack }) => {
      return `${timestamp} [${level}] ${stack || message}`;
    })
  ),
  transports: [
    new transports.Console({ format: format.colorize({ all: true }) }),
    new transports.File({ filename: path.join(logDir, 'selenium.log') })
  ]
});

module.exports = { logger };
