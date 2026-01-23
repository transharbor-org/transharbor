# TransHarbor Test Suite

This directory contains comprehensive tests for the TransHarbor Flutter application.

## Test Structure

```
test/
├── helpers/                    # Test utilities and mocks
│   ├── test_helpers.dart      # Widget testing helpers
│   └── mock_services.dart     # Mock service implementations
├── core/                      # Core functionality tests
│   ├── services/              # Service layer tests
│   │   ├── pocketbase_service_test.dart
│   │   ├── storage_service_test.dart
│   │   └── api_service_test.dart
│   └── router/                # Routing tests
│       └── app_router_test.dart
├── features/                  # Feature-specific tests
│   ├── auth/                  # Authentication tests
│   │   ├── models/
│   │   ├── providers/
│   │   └── screens/
│   ├── personals/             # Personals feature tests
│   ├── messaging/             # Messaging feature tests
│   ├── governance/            # Governance feature tests
│   ├── groups/                # Groups feature tests
│   └── home/                  # Home screen tests
└── main_test.dart             # App entry point test
```

## Test Categories

### 1. Model Tests
Tests for all data models including JSON serialization/deserialization and PocketBase integration.

- User model
- Personal model
- Message and Conversation models
- Proposal and Vote models
- Group, GroupMember, and GroupPost models

### 2. Service Tests
Tests for core services that handle business logic and external interactions.

- **StorageService**: Local storage, secure token storage
- **PocketBaseService**: Backend API integration, authentication, CRUD operations
- **PhoneAuthService**: SMS OTP verification and phone number validation

### 3. Provider Tests
Tests for state management providers using the Provider pattern.

- AuthProvider: Authentication state management
- PersonalsProvider: Personals feed state
- MessagingProvider: Conversations and messages
- GovernanceProvider: Proposals and voting
- GroupsProvider: Groups, members, and posts

### 4. Widget Tests
UI tests for key screens and components.

- Login and Registration screens
- Home screen with feature cards
- Personals list and creation
- Groups list and creation
- Messaging conversations
- Governance proposals

### 5. Router Tests
Tests for navigation and routing configuration.

- Route definitions
- Navigation between screens
- Route parameters

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/features/auth/models/user_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run tests in a specific directory
```bash
flutter test test/features/groups/
```

### Run tests with verbose output
```bash
flutter test --verbose
```

## CI/CD Integration

These tests are automatically run in the GitHub Actions CI/CD pipeline on:
- Every push to main branch
- Every pull request
- Before deployment

See [.github/workflows/flutter-ci.yml](../.github/workflows/flutter-ci.yml) for CI configuration.

## Test Dependencies

The following packages are used for testing:

- `flutter_test`: Core Flutter testing framework
- `mockito`: Mock generation for testing
- `build_runner`: Code generation for mocks
- `bloc_test`: Additional testing utilities

## Writing New Tests

### Model Test Example
```dart
test('creates model from JSON', () {
  final json = {'id': '123', 'name': 'Test'};
  final model = MyModel.fromJson(json);
  
  expect(model.id, '123');
  expect(model.name, 'Test');
});
```

### Provider Test Example
```dart
test('updates state correctly', () {
  final provider = MyProvider();
  
  provider.updateData(newData);
  
  expect(provider.data, newData);
});
```

### Widget Test Example
```dart
testWidgets('displays correct text', (WidgetTester tester) async {
  await tester.pumpWidget(createTestWidget(MyWidget()));
  
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Best Practices

1. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification
2. **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
3. **Independent Tests**: Each test should be independent and not rely on other tests
4. **Mock External Dependencies**: Use mocks for services, APIs, and external dependencies
5. **Test Edge Cases**: Include tests for error conditions and edge cases
6. **Keep Tests Fast**: Unit tests should run quickly; use integration tests for complex scenarios

## Coverage Goals

- **Models**: 100% coverage - all fields and methods
- **Services**: 80%+ coverage - core functionality
- **Providers**: 90%+ coverage - state management logic
- **Widgets**: 70%+ coverage - critical UI paths
- **Overall**: 80%+ test coverage

## Troubleshooting

### Common Issues

**Issue**: Tests fail with "No Material widget found"
**Solution**: Wrap widgets with `createTestWidget()` helper

**Issue**: Provider tests fail with "Could not find the correct Provider"
**Solution**: Use `createTestWidgetWithProviders()` helper

**Issue**: Navigation tests fail
**Solution**: Use `createTestWidgetWithRouter()` helper with mock router

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
