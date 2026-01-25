## TransHarbor Flutter App

[![Flutter CI](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml)

A user-owned, democratically-governed community platform for trans and nonbinary people.

### Features

- **Phone Verification** - Secure sign-up with SMS OTP (supports 195+ countries worldwide)
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
├── services/                 # App-level services
│   └── phone_auth_service.dart  # Phone verification
├── core/                     # Core functionality
│   ├── models/              # Shared models
│   ├── router/              # Navigation/routing
│   ├── services/            # Core services (PocketBase, Storage)
│   ├── theme/               # App theming
│   └── utils/               # Utility functions & guards
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

### Testing

**Unit & Widget Tests:**
```bash
flutter test
```

**E2E Tests (Browser):**
```bash
./scripts/run_integration_tests.sh
```

**Test Coverage:**
- 104 unit tests ✅
- 58 widget tests ✅
- 19 E2E tests ✅

📚 **Testing Documentation:**
- [E2E Testing Guide](docs/E2E_TESTING.md)
- [E2E Quick Start](docs/E2E_QUICKSTART.md)
- [Implementation Details](docs/E2E_IMPLEMENTATION.md)
