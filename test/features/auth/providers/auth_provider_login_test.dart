import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import 'auth_provider_login_test.mocks.dart';

// Helper to create mock record data
RecordModel createMockUserRecord({
  required String id,
  required String email,
  required String username,
  String? name,
  String? bio,
  String role = 'user',
  String membershipType = 'voting_member',
}) {
  return RecordModel({
    'id': id,
    'collectionId': '_pb_users_auth_',
    'collectionName': 'users',
    'created': DateTime.now().toIso8601String(),
    'updated': DateTime.now().toIso8601String(),
    'email': email,
    'username': username,
    if (name != null) 'name': name,
    if (bio != null) 'bio': bio,
    'role': role,
    'membership_type': membershipType,
    'verified': true,
  });
}

@GenerateMocks([PocketBaseService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;
  late MockPocketBaseService mockPocketBaseService;

  setUp(() {
    mockPocketBaseService = MockPocketBaseService();
    authProvider = AuthProvider(pocketBaseService: mockPocketBaseService);
  });

  group('AuthProvider - Login/Sign In', () {
    group('Successful Login', () {
      test('login with valid credentials succeeds', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          name: 'Test User',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token-123',
          record: mockRecord,
        );

        when(mockPocketBaseService.login('test@example.com', 'password123'))
            .thenAnswer((_) async => mockAuthData);

        // Act
        final result =
            await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(result, true);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser?.email, 'test@example.com');
        verify(mockPocketBaseService.login('test@example.com', 'password123'))
            .called(1);
      });

      test('sets isLoading to true during login', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token',
          record: mockRecord,
        );

        bool? loadingStateDuringCall;
        when(mockPocketBaseService.login(any, any)).thenAnswer((_) async {
          loadingStateDuringCall = authProvider.isLoading;
          return mockAuthData;
        });

        // Act
        await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(loadingStateDuringCall, true);
        expect(authProvider.isLoading, false);
      });

      test('updates currentUser after successful login', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'user456',
          email: 'jane@example.com',
          username: 'janesmith',
          name: 'Jane Smith',
          bio: 'Trans activist',
          role: 'moderator',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login('jane@example.com', 'secure123'))
            .thenAnswer((_) async => mockAuthData);

        expect(authProvider.currentUser, isNull);

        // Act
        await authProvider.login('jane@example.com', 'secure123');

        // Assert
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser?.id, 'user456');
        expect(authProvider.currentUser?.email, 'jane@example.com');
        expect(authProvider.currentUser?.username, 'janesmith');
      });
    });

    group('Failed Login', () {
      test('login with invalid credentials fails', () async {
        // Arrange
        when(mockPocketBaseService.login('wrong@example.com', 'wrongpass'))
            .thenThrow(Exception('Failed to authenticate.'));

        // Act
        final result =
            await authProvider.login('wrong@example.com', 'wrongpass');

        // Assert
        expect(result, false);
        expect(authProvider.isLoading, false);
        expect(authProvider.errorMessage, isNotNull);
        expect(authProvider.currentUser, isNull);
      });

      test('login with network error fails gracefully', () async {
        // Arrange
        when(mockPocketBaseService.login(any, any))
            .thenThrow(Exception('Network error'));

        // Act
        final result =
            await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, contains('Network error'));
        expect(authProvider.currentUser, isNull);
      });

      test('login with server error sets error message', () async {
        // Arrange
        when(mockPocketBaseService.login(any, any))
            .thenThrow(Exception('Server error: 500'));

        // Act
        final result =
            await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, isNotNull);
        expect(authProvider.errorMessage, contains('Server error'));
      });

      test('clears previous error on new login attempt', () async {
        // Arrange - First failed login
        when(mockPocketBaseService.login('wrong@example.com', 'wrongpass'))
            .thenThrow(Exception('Invalid credentials'));

        await authProvider.login('wrong@example.com', 'wrongpass');
        expect(authProvider.errorMessage, isNotNull);

        // Arrange - Second successful login
        final mockRecord = createMockUserRecord(
          id: 'user123',
          email: 'correct@example.com',
          username: 'correctuser',
        );

        final mockAuthData = RecordAuth(
          token: 'new-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login('correct@example.com', 'correctpass'))
            .thenAnswer((_) async => mockAuthData);

        // Act
        final result =
            await authProvider.login('correct@example.com', 'correctpass');

        // Assert
        expect(result, true);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Edge Cases', () {
      test('login with empty email fails', () async {
        // Arrange
        when(mockPocketBaseService.login('', 'password'))
            .thenThrow(Exception('Email is required'));

        // Act
        final result = await authProvider.login('', 'password');

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('login with empty password fails', () async {
        // Arrange
        when(mockPocketBaseService.login('test@example.com', ''))
            .thenThrow(Exception('Password is required'));

        // Act
        final result = await authProvider.login('test@example.com', '');

        // Assert
        expect(result, false);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('login with special characters in password succeeds', () async {
        // Arrange
        final specialPassword = 'P@ssw0rd!#\$%^&*()';
        final mockRecord = createMockUserRecord(
          id: 'user789',
          email: 'test@example.com',
          username: 'testuser',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login('test@example.com', specialPassword))
            .thenAnswer((_) async => mockAuthData);

        // Act
        final result =
            await authProvider.login('test@example.com', specialPassword);

        // Assert
        expect(result, true);
        verify(mockPocketBaseService.login('test@example.com', specialPassword))
            .called(1);
      });

      test('login preserves user role and membership type', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'admin123',
          email: 'admin@example.com',
          username: 'adminuser',
          name: 'Admin User',
          role: 'admin',
        );

        final mockAuthData = RecordAuth(
          token: 'admin-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login('admin@example.com', 'adminpass'))
            .thenAnswer((_) async => mockAuthData);

        // Act
        await authProvider.login('admin@example.com', 'adminpass');

        // Assert
        expect(authProvider.currentUser?.role.toString(), contains('admin'));
      });
    });

    group('State Management', () {
      test('notifies listeners on successful login', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login(any, any))
            .thenAnswer((_) async => mockAuthData);

        int listenerCallCount = 0;
        authProvider.addListener(() {
          listenerCallCount++;
        });

        // Act
        await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(listenerCallCount, greaterThan(0));
      });

      test('notifies listeners on failed login', () async {
        // Arrange
        when(mockPocketBaseService.login(any, any))
            .thenThrow(Exception('Login failed'));

        int listenerCallCount = 0;
        authProvider.addListener(() {
          listenerCallCount++;
        });

        // Act
        await authProvider.login('test@example.com', 'wrongpass');

        // Assert
        expect(listenerCallCount, greaterThan(0));
      });

      test('resets loading state after login completes', () async {
        // Arrange
        final mockRecord = createMockUserRecord(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final mockAuthData = RecordAuth(
          token: 'test-token',
          record: mockRecord,
        );

        when(mockPocketBaseService.login(any, any))
            .thenAnswer((_) async => mockAuthData);

        // Act
        await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(authProvider.isLoading, false);
      });

      test('resets loading state even when login fails', () async {
        // Arrange
        when(mockPocketBaseService.login(any, any))
            .thenThrow(Exception('Login failed'));

        // Act
        await authProvider.login('test@example.com', 'wrongpass');

        // Assert
        expect(authProvider.isLoading, false);
      });
    });
  });
}
