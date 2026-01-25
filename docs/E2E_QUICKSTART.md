# Quick Start: Running E2E Tests

## 1-Minute Setup (Ubuntu/Debian)

```bash
# Install Chrome & ChromeDriver
sudo apt-get update
sudo apt-get install -y google-chrome-stable chromium-chromedriver

# Verify installation
google-chrome --version
chromedriver --version
```

## Run Tests

```bash
# Run all E2E tests
./scripts/run_integration_tests.sh
```

## Common Commands

```bash
# Run single test file
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d web-server

# Run in headless mode (CI-like)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d web-server \
  --web-browser-flag="--headless=new"

# Debug mode (see browser window)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d chrome
```

## What Gets Tested

✅ **Login Flow** (5 tests)
- Valid/invalid credentials
- Form validation
- Password visibility
- Error messages

✅ **Register Flow** (7 tests)
- Email validation
- Password requirements
- Confirmation matching
- Navigation

✅ **Navigation Flow** (7 tests)
- Tab switching
- Logout
- Back button

## When Tests Run

- **Locally**: Run `./scripts/run_integration_tests.sh`
- **CI/CD**: Automatically on every push/PR
- **Before Deploy**: Must pass to build Docker images

## View Results

**Local:**
```bash
./scripts/run_integration_tests.sh
# ✓ Passed: integration_test/login_flow_test.dart
# ✓ Passed: integration_test/register_flow_test.dart
# ✓ Passed: integration_test/navigation_flow_test.dart
```

**CI/CD:**
1. Go to GitHub Actions
2. Click your commit's workflow
3. View "E2E Tests (Web)" job

## Troubleshooting

**ChromeDriver not found?**
```bash
sudo apt-get install chromium-chromedriver
```

**Tests timeout?**
- Check if backend is running
- Increase timeout in test file
- Run with `--verbose` flag

**Full documentation:** [docs/E2E_TESTING.md](E2E_TESTING.md)
