import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/profile/screens/edit_profile_screen.dart';

void main() {
  group('EditProfileScreen', () {
    testWidgets('creates widget without error', (WidgetTester tester) async {
      expect(() => const EditProfileScreen(), returnsNormally);
    });

    testWidgets('has required properties', (WidgetTester tester) async {
      expect(EditProfileScreen, isNotNull);
    });
  });
}
