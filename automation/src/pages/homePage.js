const BasePage = require('./basePage');
const { findByValueKey, findByText } = require('../utils/flutterFinder');

class HomePage extends BasePage {
  get logoutButton() {
    return findByValueKey('logout_button');
  }

  get profileMenu() {
    return findByValueKey('profile_menu');
  }

  get welcomeText() {
    return findByText('Welcome');
  }

  async logout() {
    const element = await this.findElement(this.logoutButton);
    await this.tap(element);
  }

  async isLoaded() {
    const element = await this.findElement(this.welcomeText);
    return this.isDisplayed(element);
  }
}

module.exports = HomePage;
