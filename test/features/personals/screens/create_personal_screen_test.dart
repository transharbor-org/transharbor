import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/screens/create_personal_screen.dart';

void main() {
  group('CreatePersonalScreen', () {
    test('CreatePersonalScreen class exists', () {
      expect(CreatePersonalScreen, isNotNull);
    });

    test('CreatePersonalScreen is a StatefulWidget', () {
      expect(const CreatePersonalScreen(), isA<StatefulWidget>());
    });
  });
}
