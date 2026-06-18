# Flutter Appium E2E Automation Framework

This repository contains a production-ready end-to-end automation framework for Flutter Android applications using Appium 2.x.

## Features

- Appium 2.x with `appium-flutter-driver`
- Mocha + Chai test framework
- Page Object Model architecture
- Flutter widget finders for `ValueKey`, `Text`, `SemanticsLabel`, and accessibility IDs
- Gesture utilities for tap, double tap, long press, swipe, scroll, drag, pinch, and zoom
- Automatic APK installation before execution
- Failure capture: screenshots, device logs, Flutter widget tree, stack trace
- Excel and HTML report generation
- GitHub Actions workflow for CI/CD
- Smart AI-assisted test generation module stub

## Getting Started

1. Navigate to the automation folder:

```bash
cd automation
```
2. Install dependencies:

```bash
npm install
```

3. Configure environment variables:

Create a `.env` file or set variables in your shell. Required variables:

- `APK_PATH=./app/app-release.apk`
- `APP_PACKAGE=com.company.app`
- `APP_ACTIVITY=com.company.app.MainActivity`
- `DEVICE_NAME` (optional)
- `ANDROID_PLATFORM_VERSION` (optional)
- `APPIUM_SERVER_URL` (optional)

4. Run the full test suite:

```bash
npm test
```

## Reports
- HTML report: `automation/reports/index.html`
- Excel report: `automation/reports/Flutter_E2E_Report.xlsx`
- Failure artifacts: `automation/reports/failures/`

## GitHub Actions
A workflow file is included at `.github/workflows/flutter-appium.yml`.
## Notes
- The framework auto-detects connected Android devices via `adb`.
- If no device is connected, it will fall back to emulator settings declared through environment variables.
- Update page object selectors to match your Flutter application keys and semantics.
