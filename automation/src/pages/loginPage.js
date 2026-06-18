const BasePage = require('./basePage');
const { findByValueKey, findByText, findBySemanticsLabel } = require('../utils/flutterFinder');

class LoginPage extends BasePage {
  get emailField() {
    return findByValueKey('login_email');
  }

  get passwordField() {
    return findByValueKey('login_password');
  }

  get loginButton() {
    return findByValueKey('login_button');
  }

  get emailErrorText() {
    return findByValueKey('email_error_text');
  }

  get passwordErrorText() {
    return findByValueKey('password_error_text');
  }

  get forgotPasswordLink() {
    return findByText('Forgot Password');
  }

  async enterEmail(email) {
    const element = await this.findElement(this.emailField);
    await this.type(element, email);
  }

  async enterPassword(password) {
    const element = await this.findElement(this.passwordField);
    await this.type(element, password);
  }

  async submitLogin() {
    const element = await this.findElement(this.loginButton);
    await this.tap(element);
  }

  async getEmailError() {
    const element = await this.findElement(this.emailErrorText);
    return this.getText(element);
  }

  async getPasswordError() {
    const element = await this.findElement(this.passwordErrorText);
    return this.getText(element);
  }
}

module.exports = LoginPage;
