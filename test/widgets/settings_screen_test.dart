import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/settings/screens/settings_screen.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('contains scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays multiple list tiles', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
    });
  });
}
