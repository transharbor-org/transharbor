# PocketBase Directory

This directory contains PocketBase-related files.

## Setup

1. Download PocketBase:
   ```bash
   cd pocketbase
   wget https://github.com/pocketbase/pocketbase/releases/download/v0.18.10/pocketbase_0.18.10_linux_amd64.zip
   unzip pocketbase_0.18.10_linux_amd64.zip
   rm pocketbase_0.18.10_linux_amd64.zip
   ```

2. Or use the setup script from the project root:
   ```bash
# From project root:
./pocketbase/setup_pocketbase.sh

# Or from pocketbase directory:
cd pocketbase
   ```

## Contents

- `CHANGELOG.md` - PocketBase changelog
- `LICENSE.md` - PocketBase license
- `pocketbase` - PocketBase binary (not committed to git)
- `pb_data/` - PocketBase database and storage (not committed to git)

## Running

```bash
./pocketbase serve
```

Access the admin UI at http://127.0.0.1:8090/_/
