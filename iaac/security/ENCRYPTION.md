# Encryption at Rest

## Overview
TransHarbor implements server-side encryption for sensitive user data to protect privacy while allowing moderation.

## Architecture

### Encryption Method
- **Algorithm**: AES-256-GCM
- **Key Management**: Platform key stored in Kubernetes Secrets
- **Mode**: Server-side encryption with moderator escrow

### What Gets Encrypted
- Direct message content
- User bio/personal information
- Location data
- Any field marked as sensitive

### What Stays Unencrypted
- Usernames (needed for mentions/search)
- Timestamps
- Metadata (like counts, IDs)
- Public post titles (for discoverability)

## Security Model

### Access Levels
1. **Regular Users**: Can only decrypt their own data via the app
2. **Moderators**: Can decrypt reported content via admin API (logged)
3. **Database Admin**: Sees only encrypted data
4. **Platform Key Holder**: Can decrypt all (key rotation capability)

### Audit Logging
Every moderator decryption is logged:
- Who accessed the data
- What data was accessed
- When it was accessed
- Why (report ID or reason)

## Setup

### Development
```bash
# Deploy encryption secret (uses dev key)
kubectl apply -f iaac/security/encryption-secret.yaml
```

### Production
```bash
# Generate production key
openssl rand -base64 32 > /tmp/encryption.key

# Create secret
kubectl create secret generic encryption-key \
  --from-literal=ENCRYPTION_KEY=$(cat /tmp/encryption.key) \
  -n transharbor

# Shred the temp file
shred -u /tmp/encryption.key
```

### Key Rotation
```bash
# Generate new key
openssl rand -base64 32 > /tmp/new-encryption.key

# Deploy re-encryption job (migrates data to new key)
kubectl apply -f iaac/security/key-rotation-job.yaml

# Update secret with new key
kubectl create secret generic encryption-key-new \
  --from-literal=ENCRYPTION_KEY=$(cat /tmp/new-encryption.key) \
  -n transharbor

# Shred temp file
shred -u /tmp/new-encryption.key
```

## Implementation Details

### Flutter App
- `EncryptionService` handles all encryption/decryption
- Transparent to UI layer (encrypt on save, decrypt on load)
- Key cached in memory during session
- Cleared on logout

### PocketBase
- Stores encrypted data as base64 strings
- No decryption happens on server
- Collection rules unchanged (work on encrypted data)

### Moderator Access
- Admin API endpoint for decryption
- Requires moderator role + reason
- All access logged to audit collection
- Time-limited access tokens

## Migration Strategy

### Existing Data
- Encryption is opt-in per field
- Legacy unencrypted data readable
- Gradual migration via background job
- App detects and handles both encrypted/unencrypted

### Rollback
- Set `ENCRYPTION_ENABLED=false` in ConfigMap
- App stops encrypting new data
- Existing encrypted data still decryptable
- Allows safe rollback if issues arise

## Compliance

### GDPR
- Right to erasure: Delete encrypted data + key rotation invalidates
- Right to access: Users can export their data (decrypted)
- Data minimization: Only sensitive fields encrypted
- Pseudonymization: Encrypted data is pseudonymous

### Threat Model
**Protects Against:**
- ✅ Database dump leaks
- ✅ Backup theft
- ✅ Rogue database admins
- ✅ Server compromise (if key stored separately)

**Does NOT Protect Against:**
- ❌ Application-level attacks (XSS, etc.)
- ❌ Compromised platform key
- ❌ Malicious moderators (logged but not prevented)
- ❌ Client-side malware

## Monitoring

```bash
# Check encryption status
kubectl get configmap encryption-config -n transharbor -o yaml

# View audit logs
kubectl logs -n transharbor -l app=pocketbase | grep "AUDIT:DECRYPT"

# Verify secret exists
kubectl get secret encryption-key -n transharbor
```

## Performance Impact

- **Encryption**: ~0.5ms per message
- **Decryption**: ~0.3ms per message  
- **Storage**: ~33% larger (base64 encoding + IV)
- **CPU**: Negligible (modern AES hardware support)

## Future Enhancements

1. **End-to-End Encryption**: Optional E2EE for ultra-sensitive DMs
2. **Multi-Key**: Different keys per data type
3. **HSM Integration**: Hardware security module for key storage
4. **Zero-Knowledge**: Server can't decrypt (user key only)
