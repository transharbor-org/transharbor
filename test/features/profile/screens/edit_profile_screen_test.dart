import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/profile/screens/edit_profile_screen.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import 'package:transharbor/core/models/user.dart';

import 'edit_profile_screen_test.mocks.dart';

// Helper to create mock user
User createMockUser({
  String id = 'user123',
  String email = 'test@example.com',
  String? displayName = 'Test User',
  String? bio = 'Test bio',
  String? pronouns = 'they/them',
  bool isPrivate = false,
}) {
  return User(
    id: id,
    email: email,
    displayName: displayName,
    bio: bio,
    pronouns: pronouns,
    isPrivate: isPrivate,
    createdAt: DateTime.now(),
  );
}

@GenerateMocks([PocketBaseService, AuthProvider])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EditProfileScreen', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    Widget createTestWidget({User? user}) {
      when(mockAuthProvider.currentUser).thenReturn(user);
      when(mockAuthProvider.refreshUser()).thenAnswer((_) async => {});

      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const EditProfileScreen(),
        ),
      );
    }

    testWidgets('creates widget without error', (WidgetTester tester) async {
      expect(() => const EditProfileScreen(), returnsNormally);
    });

    testWidgets('renders all form fields', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Verify app bar
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Verify form fields
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Display Name'), findsOneWidget);
      expect(find.text('Pronouns (optional)'), findsOneWidget);
      expect(find.text('Bio (optional)'), findsOneWidget);

      // Verify privacy toggle
      expect(find.text('Private Profile'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('pre-fills form with current user data',
        (WidgetTester tester) async {
      final user = createMockUser(
        displayName: 'Alex Smith',
        bio: 'Software developer',
        pronouns: 'she/her',
        isPrivate: true,
      );

      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Verify pre-filled data
      expect(find.text('Alex Smith'), findsOneWidget);
      expect(find.text('Software developer'), findsOneWidget);
      expect(find.text('she/her'), findsOneWidget);

      // Verify privacy switch is on
      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, true);
    });

    testWidgets('handles null user data gracefully',
        (WidgetTester tester) async {
      final user = createMockUser(
        displayName: null,
        bio: null,
        pronouns: null,
        isPrivate: false,
      );

      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Should render without errors with empty fields
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('displays validation error for empty display name',
        (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Clear display name
      final displayNameField = find.widgetWithText(
        TextFormField,
        'Test User',
      );
      await tester.enterText(displayNameField, '');
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter a display name'), findsOneWidget);
    });

    testWidgets('displays validation error for whitespace-only display name',
        (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Enter only whitespace
      final displayNameField = find.byType(TextFormField).first;
      await tester.enterText(displayNameField, '   ');
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter a display name'), findsOneWidget);
    });

    testWidgets('allows valid display name', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Enter valid name
      final displayNameField = find.byType(TextFormField).first;
      await tester.enterText(displayNameField, 'Valid Name');
      await tester.pumpAndSettle();

      // Try to save - should not show validation error
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Validation error should not be present
      expect(find.text('Please enter a display name'), findsNothing);
    });

    testWidgets('respects character limits', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Character counters should be visible (pronouns and display name both 9 chars)
      expect(find.text('9/50'), findsWidgets);
    });

    testWidgets('privacy toggle changes state', (WidgetTester tester) async {
      final user = createMockUser(isPrivate: false);
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Initial state should be public (unlocked icon)
      expect(find.byIcon(Icons.public), findsOneWidget);

      // Toggle privacy
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Should now show lock icon
      expect(find.byIcon(Icons.lock), findsWidgets);
    });

    testWidgets('bio field exists', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Bio field should exist
      final bioFieldFinder = find.ancestor(
        of: find.text('Bio (optional)'),
        matching: find.byType(TextFormField),
      );
      expect(bioFieldFinder, findsOneWidget);
    });

    testWidgets('all fields have appropriate icons',
        (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Verify icons are present in the UI
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.badge), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.info_outline), findsAtLeastNWidgets(1));
    });

    testWidgets('has proper accessibility labels', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Check for label texts
      expect(find.text('Display Name'), findsOneWidget);
      expect(find.text('Pronouns (optional)'), findsOneWidget);
      expect(find.text('Bio (optional)'), findsOneWidget);
      expect(find.text('Private Profile'), findsOneWidget);
      expect(
        find.text('Hide your profile from other users'),
        findsOneWidget,
      );
    });

    testWidgets('displays helpful hint texts', (WidgetTester tester) async {
      final user = createMockUser(displayName: null);
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      expect(find.text('How should we call you?'), findsOneWidget);
      expect(
        find.text('e.g., she/her, they/them, he/him'),
        findsOneWidget,
      );
      expect(find.text('Tell us about yourself...'), findsOneWidget);
    });

    testWidgets('Save button is in app bar', (WidgetTester tester) async {
      final user = createMockUser();
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Find the app bar
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Save button should be in the actions
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('can edit display name', (WidgetTester tester) async {
      final user = createMockUser(displayName: 'Original Name');
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Find and edit display name
      final nameField = find.widgetWithText(TextFormField, 'Original Name');
      await tester.enterText(nameField, 'New Name');
      await tester.pumpAndSettle();

      expect(find.text('New Name'), findsOneWidget);
    });

    testWidgets('can edit pronouns', (WidgetTester tester) async {
      final user = createMockUser(pronouns: 'she/her');
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Find and edit pronouns
      final pronounsField = find.widgetWithText(TextFormField, 'she/her');
      await tester.enterText(pronounsField, 'he/him');
      await tester.pumpAndSettle();

      expect(find.text('he/him'), findsOneWidget);
    });

    testWidgets('can edit bio', (WidgetTester tester) async {
      final user = createMockUser(bio: 'Original bio');
      await tester.pumpWidget(createTestWidget(user: user));
      await tester.pumpAndSettle();

      // Find and edit bio
      final bioField = find.widgetWithText(TextFormField, 'Original bio');
      await tester.enterText(bioField, 'New bio content');
      await tester.pumpAndSettle();

      expect(find.text('New bio content'), findsOneWidget);
    });
  });
}
