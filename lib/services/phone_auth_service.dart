import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhoneAuthService {
  final PocketBase pb;
  final String smsApiUrl;
  final String smsApiKey;

  PhoneAuthService({
    required this.pb,
    required this.smsApiUrl,
    required this.smsApiKey,
  });

  /// Send OTP to phone number
  Future<String> sendOTP(String phoneNumber) async {
    try {
      // Call PocketBase function to generate and store OTP
      final result = await pb.collection('phone_verification').create(body: {
        'phone': phoneNumber,
        'verified': false,
      });

      final verificationId = result.id;
      final otp = result.data['otp'] as String;

      // Send SMS via API (Twilio, AWS SNS, etc.)
      await _sendSMS(phoneNumber, otp);

      return verificationId;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP(String verificationId, String code) async {
    try {
      final record = await pb.collection('phone_verification').getOne(verificationId);
      
      // Check if OTP matches and is not expired (10 min)
      final createdAt = DateTime.parse(record.data['created']);
      final isExpired = DateTime.now().difference(createdAt).inMinutes > 10;
      
      if (isExpired) {
        throw Exception('OTP expired. Please request a new code.');
      }

      final storedOtp = record.data['otp'] as String;
      if (storedOtp != code) {
        throw Exception('Invalid OTP code');
      }

      // Mark as verified
      await pb.collection('phone_verification').update(verificationId, body: {
        'verified': true,
      });

      return true;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  /// Register user with verified phone number
  Future<RecordModel> registerWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String password,
    String? email,
    String? name,
  }) async {
    try {
      // Verify phone is verified
      final verification = await pb.collection('phone_verification').getOne(verificationId);
      if (verification.data['verified'] != true) {
        throw Exception('Phone number not verified');
      }

      // Create user account
      final user = await pb.collection('users').create(body: {
        'phone': phoneNumber,
        'phoneVerified': true,
        'password': password,
        'passwordConfirm': password,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      });

      // Authenticate
      await pb.collection('users').authWithPassword(
        phoneNumber,
        password,
      );

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Send SMS via external API
  Future<void> _sendSMS(String phoneNumber, String otp) async {
    final message = 'Your TransHarbor verification code is: $otp. Valid for 10 minutes.';
    
    // Example: Twilio
    if (smsApiUrl.contains('twilio')) {
      final response = await http.post(
        Uri.parse(smsApiUrl),
        headers: {
          'Authorization': 'Bearer $smsApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'To': phoneNumber,
          'Body': message,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to send SMS: ${response.body}');
      }
    }
    // Example: AWS SNS
    else if (smsApiUrl.contains('amazonaws.com')) {
      final response = await http.post(
        Uri.parse(smsApiUrl),
        headers: {
          'Authorization': smsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'PhoneNumber': phoneNumber,
          'Message': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send SMS: ${response.body}');
      }
    }
    // Add more providers as needed
    else {
      throw Exception('Unsupported SMS provider');
    }
  }
}

/// Phone verification widget
class PhoneVerificationWidget extends StatefulWidget {
  final Function(String phoneNumber, String verificationId) onVerified;

  const PhoneVerificationWidget({
    Key? key,
    required this.onVerified,
  }) : super(key: key);

  @override
  State<PhoneVerificationWidget> createState() => _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  String? _error;

  late PhoneAuthService _authService;

  @override
  void initState() {
    super.initState();
    // Initialize with your PocketBase instance
    final pb = PocketBase('https://dev.transharbor.org');
    _authService = PhoneAuthService(
      pb: pb,
      smsApiUrl: const String.fromEnvironment('SMS_API_URL'),
      smsApiKey: const String.fromEnvironment('SMS_API_KEY'),
    );
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verificationId = await _authService.sendOTP(_phoneController.text);
      setState(() {
        _verificationId = verificationId;
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.verifyOTP(_verificationId!, _otpController.text);
      widget.onVerified(_phoneController.text, _verificationId!);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          
          if (!_otpSent) ...[
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
                  return 'Invalid phone number format (use +country_code)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOTP,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Verification Code'),
            ),
          ] else ...[
            Text(
              'Code sent to ${_phoneController.text}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter verification code';
                }
                if (value.length != 6) {
                  return 'Code must be 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify Code'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _otpSent = false;
                  _verificationId = null;
                  _otpController.clear();
                });
              },
              child: const Text('Change Phone Number'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
