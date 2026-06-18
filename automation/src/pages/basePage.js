const { findElement } = require('../utils/flutterFinder');

class BasePage {
  constructor(driver) {
    this.driver = driver;
  }

  async findElement(finder, timeout = 10000) {
    return findElement(this.driver, finder, timeout);
  }

  async tap(element) {
    await element.waitForDisplayed({ timeout: 10000 });
    await element.click();
  }

  async type(element, text) {
    await element.waitForDisplayed({ timeout: 10000 });
    await element.clearValue();
    await element.setValue(text);
  }

  async getText(element) {
    await element.waitForDisplayed({ timeout: 10000 });
    return element.getText();
  }

  async isDisplayed(element) {
    try {
      return await element.isDisplayed();
    } catch {
      return false;
    }
  }
}

module.exports = BasePage;
