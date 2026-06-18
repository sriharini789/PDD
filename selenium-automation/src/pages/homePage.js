const { By } = require('selenium-webdriver');
const BasePage = require('./basePage');

class HomePage extends BasePage {
  get logoutButton() {
    return By.id('logout-button');
  }

  get welcomeText() {
    return By.xpath('//*[contains(text(), "Welcome")]');
  }

  async logout() {
    await this.click(this.logoutButton);
  }

  async isLoaded() {
    return await this.isDisplayed(this.welcomeText);
  }
}

module.exports = HomePage;
