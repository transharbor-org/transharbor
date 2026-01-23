## TransHarbor Flutter App

[![Flutter CI](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml)
[![Deploy to GitHub Pages](https://github.com/transharbor-org/transharbor/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/transharbor-org/transharbor/actions/workflows/deploy-pages.yml)

A user-owned, democratically-governed community platform for trans and nonbinary people.

### Features

- **Groups** - Join interest-based communities
- **Personals** - Text posts to connect with others
- **Messaging** - Private conversations
- **Governance** - Active members vote on decisions
- **Moderation** - Community reporting and content moderation

### Core Values

- User-Owned
- Trans-Centered
- Privacy-First
- Democratic
- Nonprofit

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality
│   ├── constants/           # App constants
│   ├── models/              # Shared models
│   ├── router/              # Navigation/routing
│   ├── services/            # API & storage services
│   └── theme/               # App theming
└── features/                # Feature modules
    ├── auth/               # Authentication
    ├── home/               # Home screen
    ├── personals/          # Personals feature
    ├── messaging/          # Messaging feature
    ├── governance/         # Governance/voting
    ├── groups/             # Interest-based groups
    ├── moderation/         # Community moderation
    ├── profile/            # User profile
    └── settings/           # App settings
```

### Getting Started

**🚀 Quick Start (One Command):**
```bash
./setup.sh
```

This will:
- Install Flutter dependencies
- Download and setup PocketBase
- Show next steps for database creation

**Manual Setup:**
1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### Architecture

This app uses:
- **Provider** for state management
- **GoRouter** for navigation
- **PocketBase** for backend (BaaS)
- **Flutter Secure Storage** for secure data storage
- Feature-based modular architecture

### Backend Setup

This app uses PocketBase as the backend.

**🚀 Automated Setup (Recommended):**
```bash
# 1. Run automated setup
./setup_pocketbase.sh

# 2. Start PocketBase
cd pocketbase && ./pocketbase serve

# 3. Create admin account at http://127.0.0.1:8090/_/

# 4. Auto-create all collections
node scripts/create_pocketbase_schema.js
```

### Testing

The project includes comprehensive tests for all features:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/moderation/models/report_test.dart
``✅ PocketBase backend with automated setup
- ✅ Core features (Auth, Personals, Messaging, Governance, Groups)
- ✅ Community moderation system
- ✅ Comprehensive test suite (80+ tests)
- ✅ CI/CD pipeline with GitHub Actions
- [ ] Error handling and loading states improvements
- [ ] Realtime subscriptions for messages
- [ ] Configure assets and fonts
- [ ] Set up code signing for releases
- [ ] Production deployment

### Documentation

- [Roles & Permissions](docs/ROLES_AND_PERMISSIONS.md) - Admin and moderator access control
- [Membership Types](docs/MEMBERSHIP_TYPES.md) - Voting eligibility and member types
- [Moderation System](docs/MODERATION.md) - Community reporting and moderation
- [PocketBase Automation](POCKETBASE_AUTOMATION.md) - Automated backend setup
- [PocketBase Setup](POCKETBASE_SETUP.md) - Manual backend configuration
- [Test Documentation](TEST_SUMMARY.md) - Test suite overview
- [GitHub Actions](.github/ACTIONS.md) - CI/CD workflows
- [Setup Scripts](SCRIPTS.md) - Available automation scripts
The project includes GitHub Actions workflows for:
- ✅ Continuous Integration (tests, analysis, builds)
- ✅ GitHub Pages deployment (web app)
- ✅ Release builds for Android, iOS, and Web
- ✅ Dependency security reviews

See [.github/ACTIONS.md](.github/ACTIONS.md) for details.

### Next Steps

- Set up PocketBase collections (see POCKETBASE_SETUP.md)
- Configure API rules for security
- Add error handling and loading states
- Implement realtime subscriptions for messages
- Add unit and widget tests
- Configure assets and fonts
- Set up code signing for releasesfonts
- Set up CI/CD pipeline

### Contributing

Please follow the community guidelines and ensure all changes align with TransHarbor's core values.
