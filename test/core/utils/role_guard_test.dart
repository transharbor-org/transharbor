import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/core/models/user.dart';
import 'package:transharbor/core/models/user_role.dart';
import 'package:transharbor/core/utils/role_guard.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';

void main() {
  group('RoleGuard',
      skip:
          'Requires platform plugin (flutter_secure_storage) not available in unit tests',
      () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(home: child),
      );
    }

    group('canModerate', () {
      testWidgets('returns true for moderators', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.canModerate(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns true for admins', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.canModerate(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for regular users', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'user@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.canModerate(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });

      testWidgets('returns false when no user', (tester) async {
        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.canModerate(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('isAdmin', () {
      testWidgets('returns true only for admins', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.isAdmin(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for moderators', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.isAdmin(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('isPrivileged', () {
      testWidgets('returns true for admins', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.isPrivileged(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns true for moderators', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.isPrivileged(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for regular users', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'user@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.isPrivileged(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('hasRole', () {
      testWidgets('returns true for matching role', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.hasRole(context, UserRole.moderator);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for non-matching role', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'user@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.hasRole(context, UserRole.admin);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('getCurrentRole', () {
      testWidgets('returns current user role', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        late UserRole? result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.getCurrentRole(context);
              return Container();
            },
          )),
        );

        expect(result, UserRole.moderator);
      });

      testWidgets('returns null when no user', (tester) async {
        late UserRole? result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = RoleGuard.getCurrentRole(context);
              return Container();
            },
          )),
        );

        expect(result, null);
      });
    });
  });

  group('ModeratorOnly Widget',
      skip:
          'Requires platform plugin (flutter_secure_storage) not available in unit tests',
      () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('shows child for moderators', (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'mod@example.com',
        role: UserRole.moderator,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const ModeratorOnly(
            child: Text('Moderator Content'),
          ),
        ),
      );

      expect(find.text('Moderator Content'), findsOneWidget);
    });

    testWidgets('shows child for admins', (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const ModeratorOnly(
            child: Text('Moderator Content'),
          ),
        ),
      );

      expect(find.text('Moderator Content'), findsOneWidget);
    });

    testWidgets('shows nothing for regular users by default', (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'user@example.com',
        role: UserRole.user,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const ModeratorOnly(
            child: Text('Moderator Content'),
          ),
        ),
      );

      expect(find.text('Moderator Content'), findsNothing);
    });

    testWidgets('shows fallback for regular users when provided',
        (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'user@example.com',
        role: UserRole.user,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const ModeratorOnly(
            child: Text('Moderator Content'),
            fallback: Text('Not Authorized'),
          ),
        ),
      );

      expect(find.text('Moderator Content'), findsNothing);
      expect(find.text('Not Authorized'), findsOneWidget);
    });
  });
}
