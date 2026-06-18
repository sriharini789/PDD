const { By, until } = require('selenium-webdriver');

class BasePage {
  constructor(driver) {
    this.driver = driver;
  }

  async findElement(locator, timeout = 10000) {
    await this.driver.wait(until.elementLocated(locator), timeout);
    const element = await this.driver.findElement(locator);
    await this.driver.wait(until.elementIsVisible(element), timeout);
    return element;
  }

  async click(locator) {
    const element = await this.findElement(locator);
    await element.click();
  }

  async type(locator, text) {
    const element = await this.findElement(locator);
    await element.clear();
    await element.sendKeys(text);
  }

  async getText(locator) {
    const element = await this.findElement(locator);
    return await element.getText();
  }

  async isDisplayed(locator) {
    try {
      const element = await this.driver.findElement(locator);
      return await element.isDisplayed();
    } catch {
      return false;
    }
  }
}

module.exports = BasePage;
