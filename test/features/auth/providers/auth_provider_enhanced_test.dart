import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/core/models/user.dart';
import 'package:transharbor/core/models/user_role.dart';
import 'package:transharbor/core/models/membership_type.dart';
import '../../../helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider(pocketBaseService: FakePocketBaseService());
  });

  group('AuthProvider - Enhanced Tests', () {
    group('Initial State', () {
      test('has correct defaults', () {
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.canModerate, false);
        expect(authProvider.isAdmin, false);
        expect(authProvider.isPrivileged, false);
        expect(authProvider.userRole, isNull);
      });
    });

    group('User Management', () {
      test('setUserForTesting updates current user', () {
        final user = User(
          id: '123',
          email: 'test@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        authProvider.setUserForTesting(user);

        expect(authProvider.currentUser, user);
        expect(authProvider.currentUser?.id, '123');
      });

      test('setUserForTesting with null clears user', () {
        final user = User(
          id: '123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        authProvider.setUserForTesting(user);
        expect(authProvider.currentUser, isNotNull);

        authProvider.setUserForTesting(null);
        expect(authProvider.currentUser, isNull);
      });
    });

    group('Permission Checks', () {
      test('canModerate returns false for regular users', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'user@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.canModerate, false);
      });

      test('canModerate returns true for moderators', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.canModerate, true);
      });

      test('canModerate returns true for admins', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.canModerate, true);
      });

      test('isAdmin returns true only for admins', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.isAdmin, true);

        authProvider.setUserForTesting(User(
          id: '456',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.isAdmin, false);
      });

      test('isPrivileged returns true for privileged roles', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'admin@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.isPrivileged, true);

        authProvider.setUserForTesting(User(
          id: '456',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.isPrivileged, true);

        authProvider.setUserForTesting(User(
          id: '789',
          email: 'user@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.isPrivileged, false);
      });

      test('userRole returns correct role', () {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'mod@example.com',
          role: UserRole.moderator,
          createdAt: DateTime.now(),
        ));

        expect(authProvider.userRole, UserRole.moderator);
      });
    });

    group('Logout', () {
      test('clears user on logout', () async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ));

        expect(authProvider.currentUser, isNotNull);

        await authProvider.logout();

        expect(authProvider.currentUser, isNull);
      });
    });

    group('Error Handling', () {
      test('error message starts as null', () {
        expect(authProvider.errorMessage, isNull);
      });

      test('user with different membership types', () {
        final votingUser = User(
          id: '123',
          email: 'voter@example.com',
          membershipType: MembershipType.votingMember,
          createdAt: DateTime.now(),
        );

        authProvider.setUserForTesting(votingUser);
        expect(authProvider.currentUser?.canVote, true);

        final nonVotingUser = User(
          id: '456',
          email: 'nonvoter@example.com',
          membershipType: MembershipType.nonVoting,
          createdAt: DateTime.now(),
        );

        authProvider.setUserForTesting(nonVotingUser);
        expect(authProvider.currentUser?.canVote, false);
      });
    });
  });
}
