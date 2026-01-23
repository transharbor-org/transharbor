# Automated PocketBase Setup

This directory contains scripts to automatically download, configure, and run PocketBase for TransHarbor.

## Quick Start

### Option 1: Fully Automated (Recommended)

```bash
# 1. Run the setup script
./setup_pocketbase.sh

# 2. Start PocketBase
cd pocketbase && ./pocketbase serve

# 3. Create admin account (first time only)
# Open http://127.0.0.1:8090/_/
# Follow the prompts to create your admin account

# 4. Automatically create all collections
node scripts/create_pocketbase_schema.js
```

### Option 2: Manual Schema Import

```bash
# 1. Run the setup script
./setup_pocketbase.sh

# 2. Start PocketBase
cd pocketbase && ./pocketbase serve

# 3. Create admin account and import schema manually:
#    - Open http://127.0.0.1:8090/_/
#    - Create admin account
#    - Go to Settings > Import collections
#    - Upload pb_schema.json
```

### Option 3: Using Environment Variables

```bash
# Set admin credentials (optional)
export POCKETBASE_URL="http://127.0.0.1:8090"
export POCKETBASE_ADMIN_EMAIL="admin@example.com"
export POCKETBASE_ADMIN_PASSWORD="yourpassword"

# Run automated schema creation
node scripts/create_pocketbase_schema.js
```

## Files Included

- **`setup_pocketbase.sh`** - Downloads and installs PocketBase
- **`pb_schema.json`** - Complete database schema for all collections
- **`scripts/create_pocketbase_schema.js`** - Node.js script to create collections via API

## What Gets Created

The automated setup creates these collections:

1. **users** (auth) - User accounts with profiles
2. **personals** - Personal posts/stories
3. **conversations** - Direct messaging conversations
4. **messages** - Individual messages
5. **proposals** - Governance proposals
6. **votes** - Voting records
7. **groups** - Interest-based groups
8. **group_members** - Group membership
9. **group_posts** - Posts within groups

## Requirements

- **Bash** (for setup script)
- **Node.js 18+** (for automated schema creation)
- **curl or wget** (for downloading PocketBase)
- **unzip** (for extracting PocketBase)

## Configuration

### Default Settings

- **PocketBase URL**: `http://127.0.0.1:8090`
- **Admin UI**: `http://127.0.0.1:8090/_/`
- **API Base**: `http://127.0.0.1:8090/api/`

### Custom Configuration

Edit `lib/core/constants/api_constants.dart` to change the API URL:

```dart
class ApiConstants {
  static const String pocketBaseUrl = 'http://127.0.0.1:8090';
  // ...
}
```

## Troubleshooting

### PocketBase won't start

**Error**: "Address already in use"

```bash
# Check what's using port 8090
lsof -i :8090

# Kill the process or use a different port
cd pocketbase && ./pocketbase serve --http=127.0.0.1:8091
```

### Schema creation fails

**Error**: "Authentication failed"

Make sure you:
1. Created an admin account via the UI first
2. Using correct credentials
3. PocketBase is running

### Collections already exist

The script will skip existing collections and only create missing ones.

To start fresh:
```bash
rm -rf pocketbase/pb_data
./setup_pocketbase.sh
```

### Node.js version too old

**Error**: "fetch is not defined"

Update to Node.js 18 or later:
```bash
# Using nvm
nvm install 18
nvm use 18

# Or install node-fetch
npm install node-fetch
```

## Development Workflow

### Start PocketBase in Background

```bash
cd pocketbase && ./pocketbase serve > pocketbase.log 2>&1 &
```

### Stop PocketBase

```bash
# Find the process
ps aux | grep pocketbase

# Kill it
pkill pocketbase
```

### View Logs

```bash
cd pocketbase && tail -f pocketbase.log
```

### Backup Data

```bash
# Backup entire database
cp -r pocketbase/pb_data pocketbase/pb_data_backup_$(date +%Y%m%d)

# Export collections as JSON
# Go to http://127.0.0.1:8090/_/ > Settings > Export collections
```

## Production Deployment

For production, you should:

1. **Use environment variables** for sensitive data
2. **Enable HTTPS** with a reverse proxy (nginx/caddy)
3. **Set up backups** for pb_data directory
4. **Use a process manager** (systemd/supervisor)
5. **Configure CORS** if Flutter web runs on different domain

Example systemd service (`/etc/systemd/system/pocketbase.service`):

```ini
[Unit]
Description=PocketBase
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/home/youruser/transharbor/pocketbase
ExecStart=/home/youruser/transharbor/pocketbase/pocketbase serve --http=0.0.0.0:8090
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable pocketbase
sudo systemctl start pocketbase
sudo systemctl status pocketbase
```

## API Testing

Once PocketBase is running, test the API:

```bash
# Health check
curl http://127.0.0.1:8090/api/health

# List collections
curl http://127.0.0.1:8090/api/collections

# Create a user
curl -X POST http://127.0.0.1:8090/api/collections/users/records \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword123",
    "passwordConfirm": "testpassword123"
  }'
```

## Next Steps

After PocketBase setup:

1. Update Flutter app constants with your PocketBase URL
2. Run the Flutter app: `flutter run`
3. Register a test user
4. Test all features (personals, groups, governance, messaging)

## Resources

- [PocketBase Documentation](https://pocketbase.io/docs/)
- [PocketBase Dart SDK](https://pub.dev/packages/pocketbase)
- [TransHarbor Documentation](../README.md)
