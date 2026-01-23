## TransHarbor Flutter App

[![Flutter CI](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/transharbor-org/transharbor/actions/workflows/flutter-ci.yml)

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
