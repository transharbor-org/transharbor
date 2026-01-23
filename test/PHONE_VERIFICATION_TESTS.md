# Phone Verification Testing Guide

Comprehensive test documentation for the phone verification system.

## Test Structure

### Unit Tests (`test/services/phone_auth_service_test.dart`)
- **PhoneAuthService.sendOTP**: OTP generation and SMS sending
- **PhoneAuthService.verifyOTP**: OTP validation and expiration
- **PhoneAuthService.registerWithPhone**: User registration with verified phone
- **Phone Number Validation**: E.164 format validation
- **Rate Limiting**: Prevention of spam attempts
- **Error Handling**: Network errors, invalid inputs, edge cases

### Widget Tests (`test/widgets/phone_verification_widget_test.dart`)
- **Initial State**: UI rendering and default state
- **Phone Validation**: Input validation and error messages
- **OTP Flow**: Transition from phone input to OTP verification
- **User Interactions**: Button clicks, field entry, navigation
- **Accessibility**: Screen reader support, keyboard navigation
- **Edge Cases**: Rapid clicks, state recovery, rebuilds

### Integration Tests (`integration_test/phone_verification_test.dart`)
- **Full Flow**: End-to-end phone verification and registration
- **PocketBase Hooks**: OTP generation, rate limiting, duplicate prevention
- **Performance**: Response times and throughput
- **Error Scenarios**: Expired OTP, incorrect OTP, rate limiting
- **Multi-user**: Duplicate phone prevention, concurrent attempts

## Running Tests

### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/services/phone_auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests

```bash
# Run all widget tests
flutter test test/widgets/

# Run specific widget test
flutter test test/widgets/phone_verification_widget_test.dart
```

### Integration Tests

```bash
# Run on device/emulator
flutter test integration_test/phone_verification_test.dart

# Run with environment variables
flutter test integration_test/ \
  --dart-define=SMS_API_URL=https://api.twilio.com/... \
  --dart-define=SMS_API_KEY=your_test_key
```

### Generate Mocks

```bash
# Generate mocks for all test files
flutter pub run build_runner build

# Watch mode (regenerate on changes)
flutter pub run build_runner watch
```

## Test Coverage

```bash
# Generate coverage data
flutter test --coverage

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
