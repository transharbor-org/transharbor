# Phone Verification Setup

## Overview

Phone verification prevents Sybil attacks by requiring users to authenticate with a unique phone number. This implementation uses SMS OTP (One-Time Password) verification.

## Architecture

```
User → Flutter App → PocketBase → SMS Provider → User's Phone
                          ↓
                    Phone Verification Collection
                          ↓
                    Users Collection (with phone)
```

## Components

### 1. Flutter Service (`lib/services/phone_auth_service.dart`)
- `PhoneAuthService`: Handles OTP generation, verification, and registration
- `PhoneVerificationWidget`: UI component for phone verification flow
- Supports multiple SMS providers (Twilio, AWS SNS)

### 2. PocketBase Hooks (`pocketbase/pb_hooks/phone_verification.pb.js`)
- OTP generation (6-digit random code)
- Expiration handling (10 minutes)
- Rate limiting (5 attempts per hour per phone)
- Duplicate phone prevention

### 3. Database Schema (`pocketbase/schema/phone_verification.sql`)
- `phone_verification` collection: Stores OTP codes and verification status
- `users` collection: Updated with phone and phoneVerified fields

## SMS Provider Configuration

### Option 1: Twilio (Recommended for Production)

**Cost**: ~$0.0079 per SMS (US), ~$0.10-0.15 international

**Setup**:
1. Sign up at https://www.twilio.com
2. Get Account SID and Auth Token
3. Purchase a phone number ($1/month)
4. Configure environment:
   ```bash
   SMS_API_URL=https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
   SMS_API_KEY=Basic {base64(AccountSid:AuthToken)}
   ```

### Option 2: AWS SNS

**Cost**: $0.00645 per SMS (US), varies internationally

**Setup**:
1. Enable AWS SNS in your region
2. Create IAM user with SNS permissions
3. Configure environment:
   ```bash
   SMS_API_URL=https://sns.us-east-1.amazonaws.com
   SMS_API_KEY={AWS_ACCESS_KEY_ID}:{AWS_SECRET_ACCESS_KEY}
   ```

### Option 3: Vonage (formerly Nexmo)

**Cost**: ~$0.0067 per SMS (US)

**Setup**:
1. Sign up at https://www.vonage.com
2. Get API Key and Secret
3. Add provider to `phone_auth_service.dart`

### Option 4: MessageBird

**Cost**: ~$0.008 per SMS (US)

**Setup**:
1. Sign up at https://messagebird.com
2. Get API Key
3. Add provider to `phone_auth_service.dart`

## Kubernetes Deployment

### Development Environment

```yaml
# iaac/dev/web.yaml - Add environment variables
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-dev
spec:
  template:
    spec:
      containers:
      - name: web
        env:
        - name: SMS_API_URL
          valueFrom:
            secretKeyRef:
              name: sms-credentials
              key: api-url
        - name: SMS_API_KEY
          valueFrom:
            secretKeyRef:
              name: sms-credentials
              key: api-key
```

### Create Secret

```bash
# Create SMS credentials secret
kubectl create secret generic sms-credentials \
  --from-literal=api-url='https://api.twilio.com/...' \
  --from-literal=api-key='Basic ...' \
  -n transharbor

# Verify
kubectl get secret sms-credentials -n transharbor -o yaml
```

### Production Environment

For Civo production:

```bash
# Setup SMS provider credentials
cd /root/transharbor
./iaac/setup-sms-credentials.sh
```

## PocketBase Configuration

### 1. Create Collections via Admin UI

1. Navigate to https://dev.transharbor.org/_/
2. Login to PocketBase Admin
3. Create `phone_verification` collection:
   - Go to Collections → New Collection
   - Name: `phone_verification`
   - Type: Base
   - Copy schema from `pocketbase/schema/phone_verification.sql`

4. Update `users` collection:
   - Go to Collections → users → Edit
   - Add fields: `phone` (text, required, unique), `phoneVerified` (bool)
   - Update authentication options:
     - Disable email auth
     - Disable OAuth2 auth
     - Enable phone auth

### 2. Deploy Hooks

Hooks are automatically loaded from `pocketbase/pb_hooks/` directory when PocketBase starts.

```bash
# Rebuild PocketBase image with hooks
cd /home/aaron/transharbor
git add -A
git commit -m "Add phone verification"
git push

# CI will rebuild and deploy
```

## User Flow

### Registration Flow

1. **Enter Phone Number**
   ```
   User enters: +12125551234
   → Validates E.164 format
   → Checks rate limit
   ```

2. **Send OTP**
   ```
   → Generate 6-digit code (e.g., 492837)
   → Store in phone_verification collection
   → Send SMS via provider
   → Set 10-minute expiration
   ```

3. **Verify OTP**
   ```
   User enters: 492837
   → Check code matches
   → Check not expired
   → Mark as verified
   ```

4. **Complete Registration**
   ```
   → Create user account
   → Set phone and phoneVerified=true
   → Authenticate user
   → Return JWT token
   ```

### Login Flow

After registration, users can log in with phone + password:

```dart
await pb.collection('users').authWithPassword(
  '+12125551234',
  'user_password',
);
```

## Security Features

### 1. Rate Limiting
- Maximum 5 verification attempts per phone per hour
- Prevents brute force attacks
- Implemented in PocketBase hooks

### 2. OTP Expiration
- 10-minute validity window
- Prevents replay attacks
- Automatic cleanup of expired codes

### 3. Duplicate Prevention
- Unique phone constraint on users collection
- Prevents multiple accounts per phone
- Enforced at database level

### 4. Phone Format Validation
- E.164 international format required
- Pattern: `^\+[1-9]\d{1,14}$`
- Validates country code and length

## Cost Estimates

### SMS Costs (per month, 1000 users)

Assuming 2 SMS per user (initial verification + occasional re-verification):

| Provider | Cost per SMS | 2000 SMS/month |
|----------|-------------|----------------|
| Twilio | $0.0079 | $15.80 |
| AWS SNS | $0.00645 | $12.90 |
| Vonage | $0.0067 | $13.40 |
| MessageBird | $0.008 | $16.00 |

**Recommendation**: AWS SNS for lowest cost at scale

### Additional Costs
- Twilio phone number: $1/month
- AWS SNS: No additional fees
- Vonage/MessageBird: No phone number required

## Testing

### Manual Testing

```bash
# 1. Start dev environment
ssh root@dev.transharbor.org
kubectl get pods -n transharbor

# 2. Test OTP generation
curl -X POST https://dev.transharbor.org/api/collections/phone_verification/records \
  -H "Content-Type: application/json" \
  -d '{"phone": "+12125551234"}'

# 3. Check PocketBase logs
kubectl logs -n transharbor deployment/pocketbase-dev -f

# 4. Test via Flutter app
flutter run -d web-server --web-port 8080
```

### Integration Tests

```dart
// test/phone_auth_test.dart
void main() {
  group('Phone Verification', () {
    test('sends OTP successfully', () async {
      final service = PhoneAuthService(/*...*/);
      final verificationId = await service.sendOTP('+12125551234');
      expect(verificationId, isNotEmpty);
    });

    test('verifies correct OTP', () async {
      final service = PhoneAuthService(/*...*/);
      final verificationId = await service.sendOTP('+12125551234');
      // Get OTP from test database
      final isVerified = await service.verifyOTP(verificationId, '123456');
      expect(isVerified, true);
    });

    test('rejects expired OTP', () async {
      // Test with expired OTP
    });
  });
}
```

## Monitoring

### Key Metrics

1. **Verification Success Rate**
   ```sql
   SELECT 
     COUNT(*) FILTER (WHERE verified = true) * 100.0 / COUNT(*) as success_rate
   FROM phone_verification;
   ```

2. **Average Verification Time**
   ```sql
   SELECT AVG(updated - created) as avg_verification_time
   FROM phone_verification
   WHERE verified = true;
   ```

3. **Failed Attempts by Phone**
   ```sql
   SELECT phone, COUNT(*) as attempts
   FROM phone_verification
   WHERE verified = false
   GROUP BY phone
   HAVING COUNT(*) > 3;
   ```

### Alerts

Set up alerts for:
- Verification failure rate > 20%
- SMS delivery failures
- Rate limit hits > 10 per hour
- Cost anomalies (unexpected SMS volume)

## Troubleshooting

### OTP Not Received

1. **Check SMS provider status**
   ```bash
   # Twilio
   curl https://status.twilio.com/api/v2/status.json
   
   # AWS SNS
   aws sns get-sms-attributes
   ```

2. **Verify phone number format**
   - Must include country code (+1, +44, etc.)
   - No spaces or special characters except +
   - E.164 format: +12125551234

3. **Check PocketBase logs**
   ```bash
   kubectl logs -n transharbor deployment/pocketbase-dev | grep -i "phone_verification"
   ```

### Rate Limit Hit

```bash
# Check verification attempts
kubectl exec -it deployment/pocketbase-dev -n transharbor -- \
  sqlite3 /pb_data/data.db "SELECT phone, COUNT(*) FROM phone_verification WHERE created > datetime('now', '-1 hour') GROUP BY phone;"
```

### OTP Expired

- Default: 10 minutes
- To adjust: Edit `pocketbase/pb_hooks/phone_verification.pb.js`
  ```js
  // Change 10 to desired minutes
  e.record.set('expires_at', new Date(Date.now() + 15 * 60 * 1000).toISOString());
  ```

## Production Deployment

### Pre-deployment Checklist

- [ ] SMS provider account created and funded
- [ ] API credentials stored in Kubernetes secrets
- [ ] PocketBase collections created
- [ ] Hooks deployed and tested
- [ ] Rate limiting tested
- [ ] Monitoring and alerts configured
- [ ] Cost limits set on SMS provider
- [ ] Terms of Service updated (phone collection disclosure)
- [ ] Privacy Policy updated (phone storage and SMS)

### Rollout Strategy

1. **Phase 1: Optional Phone Verification** (Week 1)
   - Allow email OR phone registration
   - Monitor adoption rate and issues

2. **Phase 2: Incentivize Phone** (Week 2-3)
   - Offer benefits for phone-verified users
   - Monitor conversion rate

3. **Phase 3: Require Phone** (Week 4+)
   - Require phone verification for new signups
   - Grandfather existing email-only users
   - Monitor churn and support volume

### Rollback Plan

If issues arise:
```bash
# 1. Disable phone requirement
kubectl edit configmap app-config -n transharbor
# Set: REQUIRE_PHONE_VERIFICATION=false

# 2. Restart pods
kubectl rollout restart deployment/web-dev -n transharbor

# 3. Monitor
kubectl logs -f deployment/web-dev -n transharbor
```

## Future Enhancements

1. **WhatsApp Verification**
   - Use Twilio WhatsApp API
   - Lower cost (~$0.005 per message)
   - Higher delivery rate

2. **Voice Call Fallback**
   - If SMS fails, call with automated voice
   - Better for areas with poor SMS delivery

3. **Phone Number Portability**
   - Allow users to change phone number
   - Require re-verification

4. **Two-Factor Authentication**
   - Use phone as 2FA method
   - Send OTP for sensitive operations

5. **Bulk SMS Optimization**
   - Batch notifications
   - Use dedicated short codes
   - Negotiate better rates at scale

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review PocketBase logs
3. Check SMS provider dashboard
4. Open issue on GitHub

## References

- [PocketBase Authentication](https://pocketbase.io/docs/authentication/)
- [Twilio SMS API](https://www.twilio.com/docs/sms/api)
- [AWS SNS SMS](https://docs.aws.amazon.com/sns/latest/dg/sms_publish-to-phone.html)
- [E.164 Phone Format](https://en.wikipedia.org/wiki/E.164)
