# Integration Tests

Integration tests that validate the PocketBase service layer and API interactions.

## Running Tests

### Run all integration tests (API contracts only)
```bash
flutter test test/integration/pocketbase_api_integration_test.dart
```

### Run against live API (local or remote)
```bash
# Against local PocketBase
flutter test --dart-define=POCKETBASE_URL=http://localhost:8080 test/integration/pocketbase_live_api_test.dart

# Against dev environment
flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/pocketbase_live_api_test.dart
```

### Run all integration tests
```bash
flutter test test/integration/
```

## CI/CD Integration

### Automated Testing Pipeline

1. **Pre-Deployment Tests** (every commit)
   - API contract validation tests run automatically
   - Validates filter syntax, field naming, query parameters
   - Runs in ~3 seconds

2. **Post-Deployment Tests** (main branch only)
   - Live API tests run after Docker images are built and pushed
   - Waits for ArgoCD to sync (60s + health checks)
   - Tests actual API endpoints on dev.transharbor.org
   - Validates:
     * Authentication flow works
     * Filter syntax for relation arrays
     * Pagination and sorting
     * Error handling (404, 400)
     * Data consistency across collections

### Workflow Stages

```
Push to main
  ↓
Analyze & Test (API contract tests)
  ↓
Build Web & Docker Images
  ↓
Push to GHCR & Update Deployment
  ↓
Wait for ArgoCD Sync (60s)
  ↓
Health Check API
  ↓
Run Live API Tests
  ↓
✅ Deployment Verified
```

### What Gets Tested in CI

**API Contract Tests** (always run):
- Collection names
- Filter operators (=, ~, ?~)
- Field name conventions (camelCase)
- Query parameters
- Collection rules syntax
- Error response structures

**Live API Tests** (main branch deployments):
- Actual HTTP calls to deployed API
- Real authentication with test users
- Multi-page pagination
- Ascending/descending sorts
- Relation array filter variations
- Data consistency validation

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
