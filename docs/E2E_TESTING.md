# E2E Testing Guide

## Overview

This project uses Flutter's `integration_test` package with ChromeDriver for comprehensive end-to-end (E2E) testing. These tests run in a real browser environment, catching issues that unit and widget tests miss.

## What E2E Tests Cover

E2E tests verify complete user workflows in a real browser, including:

- ✅ **Form interactions** - Autofill behavior, validation, submission
- ✅ **Browser-specific issues** - Form recognition, CORS, network requests
- ✅ **Navigation flows** - Multi-screen user journeys
- ✅ **Authentication** - Login, register, logout workflows
- ✅ **Real API integration** - Actual backend communication
- ✅ **UI state management** - Cross-screen state persistence

### Why We Need E2E Tests

Recent example: Login form wasn't working in browsers despite passing all widget tests. The issue was missing `autofillHints`, which caused browsers to submit empty credentials. E2E tests would have caught this immediately.

## Test Structure

```
integration_test/
├── login_flow_test.dart       # Login workflows and validation
├── register_flow_test.dart    # Registration workflows and validation
└── navigation_flow_test.dart  # Post-login navigation and logout

test_driver/
└── integration_test.dart      # Driver for flutter drive command

scripts/
└── run_integration_tests.sh   # Local test execution script
```

## Running Tests Locally

### Prerequisites

**Ubuntu/Debian:**
```bash
# Install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# Install ChromeDriver
sudo apt-get install chromium-chromedriver
```

**macOS:**
```bash
brew install chromedriver
```

### Run All E2E Tests

```bash
# Make script executable
chmod +x scripts/run_integration_tests.sh

# Run all integration tests
./scripts/run_integration_tests.sh
```

### Run Individual Test Files

```bash
# Start ChromeDriver
chromedriver --port=4444 --url-base=/wd/hub &

# Run specific test
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d web-server \
  --web-port=8080 \
  --web-browser-flag="--disable-gpu" \
  --web-browser-flag="--no-sandbox"

# Stop ChromeDriver
pkill -f chromedriver
```

### Run Tests in Headless Mode (CI-like)

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d web-server \
  --web-port=8080 \
  --web-browser-flag="--headless=new" \
  --web-browser-flag="--disable-gpu"
```

## Writing New E2E Tests

### Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Feature Name E2E Tests', () {
    testWidgets('Test description', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Interact with UI
      final button = find.text('Click Me');
      await tester.tap(button);
      await tester.pumpAndSettle();

      // Verify result
      expect(find.text('Success'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
```

### Best Practices

1. **Use descriptive test names**: `'Login with invalid credentials shows error'` not `'test 1'`

2. **Always use pumpAndSettle() after actions**:
   ```dart
   await tester.tap(button);
   await tester.pumpAndSettle(); // Wait for animations/state updates
   ```

3. **Add timeouts for network-dependent tests**:
   ```dart
   await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait up to 5s
   ```

4. **Use specific finders**:
   ```dart
   // Good - specific
   final emailField = find.widgetWithText(TextFormField, 'Email');
   
   // Bad - ambiguous
   final field = find.byType(TextFormField);
   ```

5. **Test validation before submission**:
   ```dart
   testWidgets('Form validation prevents empty submission', (tester) async {
     await tester.tap(submitButton);
     await tester.pumpAndSettle();
     
     expect(find.text('Please enter email'), findsOneWidget);
   });
   ```

6. **Test error states**:
   ```dart
   testWidgets('API error shows user-friendly message', (tester) async {
     // Trigger error condition
     await tester.tap(loginButton);
     await tester.pumpAndSettle(const Duration(seconds: 3));
     
     expect(find.byType(SnackBar), findsOneWidget);
   });
   ```

## Critical Test Scenarios

### Authentication Tests (`login_flow_test.dart`)
- ✅ Valid credentials login successfully
- ✅ Invalid credentials show error
- ✅ Empty form shows validation errors
- ✅ Password visibility toggle works
- ✅ Navigation to register screen

### Registration Tests (`register_flow_test.dart`)
- ✅ Valid registration creates account
- ✅ Email format validation
- ✅ Password confirmation matching
- ✅ Minimum password length
- ✅ Navigation back to login

### Navigation Tests (`navigation_flow_test.dart`)
- ✅ Bottom navigation works after login
- ✅ Tab switching persists state
- ✅ Logout returns to login screen
- ✅ Back button navigation

## CI/CD Integration

E2E tests run automatically on every push/PR via GitHub Actions:

```yaml
# .github/workflows/flutter-ci.yml
e2e-tests:
  name: E2E Tests (Web)
  runs-on: ubuntu-latest
  needs: analyze
  
  steps:
    - Install Chrome & ChromeDriver
    - Start ChromeDriver
    - Run E2E test suites
    - Stop ChromeDriver
```

### Viewing CI Test Results

1. Go to GitHub Actions tab
2. Click on your commit's workflow run
3. Expand "E2E Tests (Web)" job
4. View individual test results in each step

## Troubleshooting

### ChromeDriver Connection Refused

```bash
# Check if ChromeDriver is running
ps aux | grep chromedriver

# Kill existing instances
pkill -f chromedriver

# Restart
chromedriver --port=4444 --url-base=/wd/hub &
```

### Tests Timeout

Increase timeout in test:
```dart
testWidgets('Test name', (tester) async {
  // test code
}, timeout: const Timeout(Duration(seconds: 60)));
```

### Cannot Find Widget

```dart
// Debug: Print widget tree
debugDumpApp();

// Or use finder alternatives
find.text('Text', skipOffstage: false);
find.byType(Widget, skipOffstage: false);
```

### Browser Not Starting

```bash
# Test Chrome manually
google-chrome --version
google-chrome --headless --disable-gpu --dump-dom https://example.com

# Check ChromeDriver compatibility
chromedriver --version
```

### Tests Pass Locally But Fail in CI

CI runs in headless mode. Test with headless flag locally:
```bash
flutter drive \
  --target=integration_test/login_flow_test.dart \
  --web-browser-flag="--headless=new"
```

## Performance Considerations

- E2E tests are slower than unit tests (5-30s per test)
- Run them in parallel when possible
- Focus on critical user paths
- Use unit tests for isolated logic
- Reserve E2E for integration scenarios

## Current Test Coverage

| Flow | Tests | Status |
|------|-------|--------|
| Login | 5 tests | ✅ Implemented |
| Register | 7 tests | ✅ Implemented |
| Navigation | 7 tests | ✅ Implemented |
| Personals | 0 tests | ⏳ TODO |
| Messages | 0 tests | ⏳ TODO |
| Profile | 0 tests | ⏳ TODO |

## Next Steps

1. **Add Personals E2E tests**:
   - Create personal post
   - View personal details
   - Like/unlike personal
   - Delete personal

2. **Add Messages E2E tests**:
   - Send message
   - View conversation
   - Mark as read

3. **Add Profile E2E tests**:
   - Update profile
   - Change password
   - Upload avatar

4. **Add visual regression testing**:
   - Screenshot comparison
   - UI consistency checks

## Related Documentation

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [ChromeDriver Documentation](https://chromedriver.chromium.org/getting-started)
- [Testing Best Practices](../test/README.md)
