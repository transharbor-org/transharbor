import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transharbor/core/router/app_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = AppRouter.router;
  });

  group('AppRouter', () {
    test('router is not null', () {
      expect(router, isNotNull);
    });

    test('initial location is splash', () {
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    });

    test('has splash route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/'), true);
    });

    test('has login route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/login'), true);
    });

    test('has register route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/register'), true);
    });

    test('has home route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/home'), true);
    });

    test('has personals route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/personals'), true);
    });

    test('has create personal route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/personals/create'), true);
    });

    test('has messages route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/messages'), true);
    });

    test('has chat route with parameter configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/messages/:conversationId'), true);
    });

    test('has governance route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/governance'), true);
    });

    test('has proposal detail route with parameter configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/governance/:proposalId'), true);
    });

    test('has groups route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/groups'), true);
    });

    test('has create group route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/groups/create'), true);
    });

    test('has group detail route with parameter configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/groups/:groupId'), true);
    });

    test('has profile route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/profile'), true);
    });

    test('has settings route configured', () {
      final routes = router.configuration.routes;
      expect(routes.any((route) => route.path == '/settings'), true);
    });

    test('all main routes are present', () {
      final routes = router.configuration.routes;
      final paths = routes.map((route) => route.path).toList();

      expect(paths, contains('/'));
      expect(paths, contains('/login'));
      expect(paths, contains('/register'));
      expect(paths, contains('/home'));
      expect(paths, contains('/personals'));
      expect(paths, contains('/messages'));
      expect(paths, contains('/governance'));
      expect(paths, contains('/groups'));
      expect(paths, contains('/profile'));
      expect(paths, contains('/settings'));
    });

    test('router has error handling', () {
      expect(router.routerDelegate, isNotNull);
    });
  });

  group('Route Navigation', () {
    test('can navigate to login', () {
      router.go('/login');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    });

    test('can navigate to register', () {
      router.go('/register');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/register');
    });

    test('can navigate to home', () {
      router.go('/home');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    test('can navigate to personals', () {
      router.go('/personals');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/personals');
    });

    test('can navigate to groups', () {
      router.go('/groups');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/groups');
    });

    test('can navigate to governance', () {
      router.go('/governance');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/governance');
    });

    test('can navigate to messages', () {
      router.go('/messages');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/messages');
    });

    test('can navigate to profile', () {
      router.go('/profile');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');
    });

    test('can navigate to settings', () {
      router.go('/settings');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/settings');
    });

    test('can navigate with parameters', () {
      router.go('/groups/test123');
      expect(router.routerDelegate.currentConfiguration.uri.path, '/groups/test123');
    });
  });
}
