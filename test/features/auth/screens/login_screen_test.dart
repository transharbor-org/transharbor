import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/auth/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    test('LoginScreen class exists', () {
      expect(LoginScreen, isNotNull);
    });

    test('LoginScreen is a StatefulWidget', () {
      expect(const LoginScreen(), isA<StatefulWidget>());
    });
  });
}
