# GitHub Actions CI/CD

This repository uses GitHub Actions for continuous integration and deployment.

## Workflows

### 1. Flutter CI (`flutter-ci.yml`)
**Triggers**: Push and Pull Requests to `main` and `develop` branches

**Jobs**:
- **Analyze**: Runs code analysis, formatting checks, and tests
- **Build Android**: Builds Android APK
- **Build iOS**: Builds iOS app (macOS runner)
- **Build Web**: Builds web application

**Artifacts**: APK, iOS build, and web build (retained for 7 days)

### 2. Deploy to GitHub Pages (`deploy-pages.yml`)
**Triggers**: Push to `main` branch, or manual dispatch

**Purpose**: Automatically deploys the web app to GitHub Pages

**Setup Required**:
1. Go to repository Settings → Pages
2. Set Source to "GitHub Actions"
3. The app will be available at `https://[username].github.io/transharbor/`

### 3. Release Build (`release.yml`)
**Triggers**: 
- Tags matching `v*.*.*` (e.g., v1.0.0)
- Manual workflow dispatch

**Purpose**: Creates production builds for all platforms and creates a GitHub Release

**Jobs**:
- Builds APK and AAB for Android
- Builds IPA for iOS
- Builds web package
- Creates GitHub Release with all artifacts

**To create a release**:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Status Badges

Add these to your README.md:

```markdown
[![Flutter CI](https://github.com/[username]/transharbor/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/[username]/transharbor/actions/workflows/flutter-ci.yml)
[![Deploy to GitHub Pages](https://github.com/[username]/transharbor/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/[username]/transharbor/actions/workflows/deploy-pages.yml)
```

## Configuration

### Caching
All workflows use Flutter and dependency caching to speed up builds:
- Flutter SDK cache
- Pub dependencies cache
- Gradle cache (Android)

### Flutter Version
Current workflows use Flutter 3.24.x stable. Update in each workflow if needed:
```yaml
flutter-version: '3.24.x'
channel: 'stable'
```

### Android Signing (Optional)
To sign Android releases, add these secrets to your repository:
- `KEYSTORE_FILE` (base64 encoded)
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

Then update the Android build steps in `release.yml`.

### iOS Signing (Optional)
For App Store releases, you'll need:
- Apple Developer account
- Provisioning profiles
- Certificates

Add as repository secrets and update the iOS build steps.

## Local Testing

Test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash  # Linux

# Run CI workflow
act pull_request

# Run specific job
act -j build-android
```

## Troubleshooting

### Build Failures
- Check Flutter version compatibility
- Verify all dependencies are compatible
- Check for platform-specific issues in logs

### Artifact Upload Issues
- Ensure paths are correct
- Check artifact retention settings
- Verify GitHub storage limits

### Permission Issues
For GitHub Pages deployment, ensure the workflow has proper permissions in repository settings.
