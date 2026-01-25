# Integration Tests

Integration tests that validate the PocketBase service layer and API interactions.

## Running Tests

### Run all integration tests
```bash
flutter test test/integration/
```

### Run specific test file
```bash
flutter test test/integration/pocketbase_api_integration_test.dart
```

### Run against live API
```bash
flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/
```

## Test Coverage

### pocketbase_api_integration_test.dart
- **Authentication**: Token format, singleton pattern, auth state
- **Collection Names**: Validates correct collection naming
- **Filter Syntax**: Tests filter operators for relations (=, ~)
- **Model Serialization**: Validates field names (camelCase consistency)
- **Required Fields**: Ensures models enforce required fields
- **Query Parameters**: Pagination, sorting, expand parameters
- **Error Handling**: 400, 403, 404 responses
- **Data Validation**: ID format, timestamps, email validation
- **Collection Rules**: Compatibility with PocketBase security rules
- **Relation Types**: Single (=) vs multi (~) relation queries
- **API Response Structure**: List pagination, record fields

## CI Integration

These tests run automatically in GitHub Actions:
- On every push to main/develop
- On every pull request
- As part of the `analyze` job

See `.github/workflows/flutter-ci.yml` for CI configuration.

## Writing New Tests

When adding new collections or models:
1. Add field name validation tests
2. Add filter syntax tests
3. Add serialization tests
4. Update collection rules tests

Keep tests fast and focused on validation logic, not actual API calls (unless explicitly testing live API).
