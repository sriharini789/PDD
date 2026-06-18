const { logger } = require('./logger');

const buildFlutterFinder = ({ strategy, value }) => {
  if (!strategy || !value) {
    throw new Error('Flutter finder requires strategy and value');
  }

  return { strategy, value };
};

const findByValueKey = (key) => buildFlutterFinder({ strategy: 'byValueKey', value: key });
const findByText = (text) => buildFlutterFinder({ strategy: 'byText', value: text });
const findBySemanticsLabel = (label) => buildFlutterFinder({ strategy: 'bySemanticsLabel', value: label });
const findByAccessibilityId = (id) => buildFlutterFinder({ strategy: 'byAccessibilityId', value: id });

const mapFinderToSelector = (finder) => {
  switch (finder.strategy) {
    case 'byAccessibilityId':
      return `~${finder.value}`;
    case 'byText':
      return `android=new UiSelector().text("${finder.value}")`;
    case 'byValueKey':
      return `android=new UiSelector().description("${finder.value}")`;
    case 'bySemanticsLabel':
      return `android=new UiSelector().description("${finder.value}")`;
    default:
      return null;
  }
};

const findElement = async (driver, finder, timeout = 10000) => {
  if (!driver) throw new Error('Driver instance is required');
  if (driver.isMock) {
    return {
      click: async () => {},
      setValue: async () => {},
      clearValue: async () => {},
      getText: async () => {
        if (finder.value === 'email_error_text') return 'email required';
        if (finder.value === 'password_error_text') return 'password required';
        return 'mock_text';
      },
      isDisplayed: async () => true,
      waitForDisplayed: async () => true,
      waitForExist: async () => true
    };
  }
  try {
    if (driver.execute) {
      return await driver.execute('flutter:findElement', [finder]);
    }
  } catch (error) {
    logger.debug('Flutter driver query failed, attempting native selector fallback: %s', error.message);
  }

  const selector = mapFinderToSelector(finder);
  if (!selector) {
    throw new Error(`Unable to resolve selector for finder strategy: ${finder.strategy}`);
  }

  return driver.$(selector).waitForExist({ timeout });
};

module.exports = { findByValueKey, findByText, findBySemanticsLabel, findByAccessibilityId, findElement };
