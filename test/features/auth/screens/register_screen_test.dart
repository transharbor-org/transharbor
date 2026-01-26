import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/auth/screens/register_screen.dart';

void main() {
  group('RegisterScreen', () {
    test('RegisterScreen class exists', () {
      expect(RegisterScreen, isNotNull);
    });

    test('RegisterScreen is a StatefulWidget', () {
      expect(const RegisterScreen(), isA<StatefulWidget>());
    });
  });
}
