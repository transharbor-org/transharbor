import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/screens/create_group_screen.dart';

void main() {
  group('CreateGroupScreen', () {
    test('CreateGroupScreen class exists', () {
      expect(CreateGroupScreen, isNotNull);
    });

    test('CreateGroupScreen is a StatefulWidget', () {
      expect(const CreateGroupScreen(), isA<StatefulWidget>());
    });
  });
}
