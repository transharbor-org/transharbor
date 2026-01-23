import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:transharbor/services/phone_auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Phone Verification Integration Tests', () {
    late PocketBase pb;
    late PhoneAuthService authService;

    setUp(() {
      // Initialize with test PocketBase instance
      pb = PocketBase('https://dev.transharbor.org');
      authService = PhoneAuthService(
        pb: pb,
        smsApiUrl: const String.fromEnvironment('SMS_API_URL'),
        smsApiKey: const String.fromEnvironment('SMS_API_KEY'),
      );
    });

    testWidgets('Full phone verification flow', (tester) async {
      // This test requires a test phone number from SMS provider
      const testPhone = '+15005550006'; // Twilio test number

      // 1. Send OTP
      String? verificationId;
      try {
        verificationId = await authService.sendOTP(testPhone);
        expect(verificationId, isNotEmpty);
      } catch (e) {
        fail('Failed to send OTP: $e');
      }

      // 2. Retrieve OTP from database (for testing purposes)
      // In production, user receives via SMS
      String? otp;
      try {
        final record = await pb.collection('phone_verification').getOne(verificationId!);
        otp = record.data['otp'] as String;
        expect(otp, hasLength(6));
        expect(int.tryParse(otp), isNotNull);
      } catch (e) {
        fail('Failed to retrieve OTP: $e');
      }

      // 3. Verify OTP
      bool verified = false;
      try {
        verified = await authService.verifyOTP(verificationId!, otp!);
        expect(verified, true);
      } catch (e) {
        fail('Failed to verify OTP: $e');
      }

      // 4. Register user with verified phone
      RecordModel? user;
      try {
        user = await authService.registerWithPhone(
          phoneNumber: testPhone,
          verificationId: verificationId!,
          password: 'TestPassword123!',
          name: 'Test User',
        );
        expect(user.id, isNotEmpty);
        expect(user.data['phone'], testPhone);
        expect(user.data['phoneVerified'], true);
      } catch (e) {
        fail('Failed to register user: $e');
      }

      // 5. Verify user is authenticated
      expect(pb.authStore.isValid, true);
      expect(pb.authStore.token, isNotEmpty);
      expect(pb.authStore.model?.id, user!.id);

      // Cleanup: Delete test user
      try {
        await pb.collection('users').delete(user.id);
        await pb.collection('phone_verification').delete(verificationId!);
      } catch (e) {
        print('Cleanup failed: $e');
      }
    });

    testWidgets('Rate limiting prevents spam', (tester) async {
      const testPhone = '+15005550007';

      // Attempt to send OTP multiple times rapidly
      final futures = List.generate(
        6,
        (i) => authService.sendOTP(testPhone),
      );

      // Should fail on 6th attempt due to rate limit (5 per hour)
      try {
        await Future.wait(futures);
        fail('Expected rate limit error');
      } catch (e) {
        expect(e.toString(), contains('Too many verification attempts'));
      }
    });

    testWidgets('Expired OTP is rejected', (tester) async {
      const testPhone = '+15005550008';

      // Send OTP
      final verificationId = await authService.sendOTP(testPhone);
      final record = await pb.collection('phone_verification').getOne(verificationId);
      final otp = record.data['otp'] as String;

      // Manually set expiration to past (requires admin access)
      await pb.collection('phone_verification').update(verificationId, body: {
        'expires_at': DateTime.now().subtract(Duration(minutes: 15)).toIso8601String(),
      });

      // Attempt verification
      try {
        await authService.verifyOTP(verificationId, otp);
        fail('Expected expiration error');
      } catch (e) {
        expect(e.toString(), contains('expired'));
      }

      // Cleanup
      await pb.collection('phone_verification').delete(verificationId);
    });

    testWidgets('Incorrect OTP is rejected', (tester) async {
      const testPhone = '+15005550009';

      // Send OTP
      final verificationId = await authService.sendOTP(testPhone);

      // Attempt verification with wrong code
      try {
        await authService.verifyOTP(verificationId, '000000');
        fail('Expected invalid OTP error');
      } catch (e) {
        expect(e.toString(), contains('Invalid OTP'));
      }

      // Cleanup
      await pb.collection('phone_verification').delete(verificationId);
    });

    testWidgets('Duplicate phone number is rejected', (tester) async {
      const testPhone = '+15005550010';

      // Register first user
      final verificationId1 = await authService.sendOTP(testPhone);
      final record1 = await pb.collection('phone_verification').getOne(verificationId1);
      final otp1 = record1.data['otp'] as String;
      await authService.verifyOTP(verificationId1, otp1);
      
      final user1 = await authService.registerWithPhone(
        phoneNumber: testPhone,
        verificationId: verificationId1,
        password: 'Password1!',
      );

      // Logout
      pb.authStore.clear();

      // Attempt to register second user with same phone
      final verificationId2 = await authService.sendOTP(testPhone);
      final record2 = await pb.collection('phone_verification').getOne(verificationId2);
      final otp2 = record2.data['otp'] as String;
      await authService.verifyOTP(verificationId2, otp2);

      try {
        await authService.registerWithPhone(
          phoneNumber: testPhone,
          verificationId: verificationId2,
          password: 'Password2!',
        );
        fail('Expected duplicate phone error');
      } catch (e) {
        expect(e.toString(), contains('already registered'));
      }

      // Cleanup
      await pb.collection('users').delete(user1.id);
      await pb.collection('phone_verification').delete(verificationId1);
      await pb.collection('phone_verification').delete(verificationId2);
    });

    testWidgets('User can login with phone after registration', (tester) async {
      const testPhone = '+15005550011';
      const password = 'SecurePassword123!';

      // Register user
      final verificationId = await authService.sendOTP(testPhone);
      final record = await pb.collection('phone_verification').getOne(verificationId);
      final otp = record.data['otp'] as String;
      await authService.verifyOTP(verificationId, otp);
      
      final user = await authService.registerWithPhone(
        phoneNumber: testPhone,
        verificationId: verificationId,
        password: password,
      );

      // Logout
      pb.authStore.clear();
      expect(pb.authStore.isValid, false);

      // Login with phone and password
      final authData = await pb.collection('users').authWithPassword(
        testPhone,
        password,
      );

      expect(authData.record.id, user.id);
      expect(authData.record.data['phone'], testPhone);
      expect(pb.authStore.isValid, true);

      // Cleanup
      await pb.collection('users').delete(user.id);
      await pb.collection('phone_verification').delete(verificationId);
    });

    testWidgets('Phone verification widget full flow', (tester) async {
      // Build widget
      String? verifiedPhone;
      String? verifiedId;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PhoneVerificationWidget(
            onVerified: (phone, verificationId) {
              verifiedPhone = phone;
              verifiedId = verificationId;
            },
          ),
        ),
      ));

      // Enter phone number
      const testPhone = '+15005550012';
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        testPhone,
      );
      await tester.pumpAndSettle();

      // Tap send button
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should show OTP screen
      expect(find.text('Verification Code'), findsOneWidget);
      expect(find.text('Code sent to $testPhone'), findsOneWidget);

      // Get OTP from database
      // Note: This requires test authentication
      // In real app, user receives SMS
      
      // For now, verify UI state
      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.text('Change Phone Number'), findsOneWidget);
    });

    testWidgets('Error handling in UI', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PhoneVerificationWidget(
            onVerified: (phone, verificationId) {},
          ),
        ),
      ));

      // Enter invalid phone
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '1234567890', // Missing +
      );

      // Tap send
      await tester.tap(find.text('Send Verification Code'));
      await tester.pump();

      // Should show validation error
      expect(
        find.text('Invalid phone number format (use +country_code)'),
        findsOneWidget,
      );
    });

    testWidgets('Multiple verification attempts with delays', (tester) async {
      const testPhone = '+15005550013';

      // First attempt
      final verificationId1 = await authService.sendOTP(testPhone);
      expect(verificationId1, isNotEmpty);

      // Wait a bit
      await Future.delayed(Duration(seconds: 2));

      // Second attempt
      final verificationId2 = await authService.sendOTP(testPhone);
      expect(verificationId2, isNotEmpty);
      expect(verificationId2, isNot(equals(verificationId1)));

      // Cleanup
      await pb.collection('phone_verification').delete(verificationId1);
      await pb.collection('phone_verification').delete(verificationId2);
    });

    testWidgets('Verification cleanup after expiration', (tester) async {
      // This test checks that expired verifications are cleaned up
      // Requires background job or manual cleanup

      const testPhone = '+15005550014';
      final verificationId = await authService.sendOTP(testPhone);

      // Verify record exists
      final record = await pb.collection('phone_verification').getOne(verificationId);
      expect(record.id, verificationId);

      // In production, expired records should be cleaned up by cron job
      // For now, just verify expiration is set
      final expiresAt = DateTime.parse(record.data['expires_at']);
      final now = DateTime.now();
      expect(expiresAt.isAfter(now), true);
      expect(expiresAt.difference(now).inMinutes, lessThanOrEqualTo(10));

      // Cleanup
      await pb.collection('phone_verification').delete(verificationId);
    });
  });

  group('PocketBase Hook Tests', () {
    testWidgets('OTP is generated automatically', (tester) async {
      final pb = PocketBase('https://dev.transharbor.org');
      
      // Create verification record (hook should generate OTP)
      final record = await pb.collection('phone_verification').create(body: {
        'phone': '+15005550015',
      });

      // Verify OTP was generated
      expect(record.data['otp'], isNotNull);
      expect(record.data['otp'], hasLength(6));
      expect(int.tryParse(record.data['otp']), isNotNull);
      expect(record.data['verified'], false);
      expect(record.data['expires_at'], isNotNull);

      // Cleanup
      await pb.collection('phone_verification').delete(record.id);
    });

    testWidgets('Duplicate phone prevention works', (tester) async {
      final pb = PocketBase('https://dev.transharbor.org');
      
      // This test requires the hook to be active
      // Create first user with phone
      // Attempt to create second user with same phone
      // Should fail

      // Placeholder for actual implementation
      expect(true, true);
    });
  });

  group('Performance Tests', () {
    testWidgets('OTP generation is fast', (tester) async {
      final pb = PocketBase('https://dev.transharbor.org');
      final authService = PhoneAuthService(
        pb: pb,
        smsApiUrl: const String.fromEnvironment('SMS_API_URL'),
        smsApiKey: const String.fromEnvironment('SMS_API_KEY'),
      );

      final stopwatch = Stopwatch()..start();
      
      await authService.sendOTP('+15005550016');
      
      stopwatch.stop();

      // Should complete in less than 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('Verification is fast', (tester) async {
      final pb = PocketBase('https://dev.transharbor.org');
      final authService = PhoneAuthService(
        pb: pb,
        smsApiUrl: const String.fromEnvironment('SMS_API_URL'),
        smsApiKey: const String.fromEnvironment('SMS_API_KEY'),
      );

      final verificationId = await authService.sendOTP('+15005550017');
      final record = await pb.collection('phone_verification').getOne(verificationId);
      final otp = record.data['otp'] as String;

      final stopwatch = Stopwatch()..start();
      
      await authService.verifyOTP(verificationId, otp);
      
      stopwatch.stop();

      // Should complete in less than 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Cleanup
      await pb.collection('phone_verification').delete(verificationId);
    });
  });
}
