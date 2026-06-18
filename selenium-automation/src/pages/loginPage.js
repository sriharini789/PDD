const { By } = require('selenium-webdriver');
const BasePage = require('./basePage');

class LoginPage extends BasePage {
  get emailField() {
    return By.id('email');
  }

  get passwordField() {
    return By.id('password');
  }

  get loginButton() {
    return By.id('login-button');
  }

  get emailErrorText() {
    return By.id('email-error');
  }

  get passwordErrorText() {
    return By.id('password-error');
  }

  async enterEmail(email) {
    await this.type(this.emailField, email);
  }

  async enterPassword(password) {
    await this.type(this.passwordField, password);
  }

  async submitLogin() {
    await this.click(this.loginButton);
  }

  async getEmailError() {
    return await this.getText(this.emailErrorText);
  }

  async getPasswordError() {
    return await this.getText(this.passwordErrorText);
  }
}

module.exports = LoginPage;
