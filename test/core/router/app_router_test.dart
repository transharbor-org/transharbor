import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/router/app_router.dart';

void main() {
  group('AppRouter', () {
    test('router is configured', () {
      expect(AppRouter.router, isNotNull);
    });

    test('router has routes', () {
      final routes = AppRouter.router.configuration.routes;
      expect(routes, isNotEmpty);
    });

    test('router has navigation delegate', () {
      expect(AppRouter.router.routerDelegate, isNotNull);
    });

    group('NavigationLogger', () {
      test('NavigationLogger class exists', () {
        expect(NavigationLogger, isNotNull);
      });

      test('NavigationLogger is a NavigatorObserver', () {
        final logger = NavigationLogger();
        expect(logger, isA<NavigatorObserver>());
      });
    });
  });
}
