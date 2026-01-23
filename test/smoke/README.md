# Smoke Tests

Lightweight tests to verify deployed environments are functional.

## What Are Smoke Tests?

Smoke tests are quick, high-level tests that verify:
- Services are running and accessible
- Critical endpoints respond correctly
- Basic functionality works
- Performance is acceptable

They're called "smoke tests" because they check if your app is "on fire" 🔥

## Running Locally

### Against Staging

```bash
flutter test test/smoke/stage_smoke_test.dart \
  --dart-define=STAGE_URL=https://stage.transharbor.org \
  --dart-define=STAGE_PB_URL=https://pb-stage.transharbor.org
```

### Against Production

```bash
flutter test test/smoke/stage_smoke_test.dart \
  --dart-define=STAGE_URL=https://transharbor.org \
  --dart-define=STAGE_PB_URL=https://pb.transharbor.org
```

### Against Local Development

```bash
flutter test test/smoke/stage_smoke_test.dart \
  --dart-define=STAGE_URL=http://localhost:8080 \
  --dart-define=STAGE_PB_URL=http://localhost:8090
```

## Running in CI

Smoke tests run automatically:
- **After stage deployment** - Verifies deployment succeeded
- **Daily at 8am UTC** - Catches environment drift
- **On demand** - Via GitHub Actions workflow dispatch

See [.github/workflows/stage-smoke-tests.yml](../../.github/workflows/stage-smoke-tests.yml)

## What They Check

### Basic Availability
- ✅ Web app is accessible (200 OK)
- ✅ PocketBase health endpoint responds
- ✅ Collections endpoints exist (even if unauthorized)

### Performance
- ✅ Web app loads within 3 seconds
- ✅ PocketBase API responds within 1 second

## Adding More Tests

Keep smoke tests:
- **Fast** - Should complete in < 30 seconds
- **Simple** - No complex logic or dependencies
- **Stable** - Should rarely flake
- **Non-destructive** - Read-only operations

For complex scenarios, use integration tests instead.

## Integration Tests vs Smoke Tests

| Aspect | Smoke Tests | Integration Tests |
|--------|-------------|------------------|
| **Purpose** | Health check | Full user flows |
| **Speed** | < 30 seconds | 5-10 minutes |
| **Frequency** | Every deploy + daily | Before releases |
| **Complexity** | Simple HTTP checks | Full UI interactions |
| **Data** | Read-only | Creates test data |
| **Failure** | Critical issue | Specific bug |

## Example: Adding a New Smoke Test

```dart
test('Governance collection accessible', () async {
  final response = await http.get(
    Uri.parse('$pbUrl/api/collections/proposals/records'),
  );
  
  // Should return 401 (unauthorized) but endpoint exists
  expect(response.statusCode, anyOf(401, 403));
});
```

## Debugging Failed Tests

1. **Check the workflow logs** - GitHub Actions shows detailed output
2. **Run locally** - Use the commands above to reproduce
3. **Verify environment** - Is stage actually deployed?
4. **Check DNS** - Can you reach the URLs in a browser?
5. **Review recent changes** - What was deployed?

## Related Documentation

- [Integration Tests](../PHONE_VERIFICATION_TESTS.md)
- [CI/CD Workflows](../../.github/ACTIONS.md)
- [GitOps Deployment](../../iaac/GITOPS.md)
