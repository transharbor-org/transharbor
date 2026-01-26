import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/theme/app_theme.dart';

void main() {
  group('AppTheme Color Constants', () {
    test('primary color is trans flag light blue', () {
      expect(AppTheme.primaryColor, equals(const Color(0xFF5BCEFA)));
    });

    test('secondary color is trans flag pink', () {
      expect(AppTheme.secondaryColor, equals(const Color(0xFFF5A9B8)));
    });

    test('accent color is trans flag white', () {
      expect(AppTheme.accentColor, equals(const Color(0xFFFFFFFF)));
    });

    test('dark background is defined', () {
      expect(AppTheme.darkBackground, equals(const Color(0xFF1A1A1A)));
    });

    test('light background is defined', () {
      expect(AppTheme.lightBackground, equals(const Color(0xFFFAFAFA)));
    });

    test('all colors are valid Color objects', () {
      expect(AppTheme.primaryColor, isA<Color>());
      expect(AppTheme.secondaryColor, isA<Color>());
      expect(AppTheme.accentColor, isA<Color>());
      expect(AppTheme.darkBackground, isA<Color>());
      expect(AppTheme.lightBackground, isA<Color>());
    });
  });

  group('AppTheme Light Theme', () {
    late ThemeData lightTheme;

    setUp(() {
      lightTheme = AppTheme.lightTheme;
    });

    test('uses Material 3', () {
      expect(lightTheme.useMaterial3, isTrue);
    });

    test('has light brightness', () {
      expect(lightTheme.brightness, equals(Brightness.light));
    });

    test('color scheme uses correct primary color', () {
      expect(lightTheme.colorScheme.primary, equals(AppTheme.primaryColor));
    });

    test('color scheme uses correct secondary color', () {
      expect(lightTheme.colorScheme.secondary, equals(AppTheme.secondaryColor));
    });

    test('color scheme surface is light background', () {
      expect(lightTheme.colorScheme.surface, equals(AppTheme.lightBackground));
    });

    test('scaffold background is light background', () {
      expect(
          lightTheme.scaffoldBackgroundColor, equals(AppTheme.lightBackground));
    });

    test('app bar theme has zero elevation', () {
      expect(lightTheme.appBarTheme.elevation, equals(0));
    });

    test('app bar title is centered', () {
      expect(lightTheme.appBarTheme.centerTitle, isTrue);
    });

    test('app bar background matches scaffold', () {
      expect(lightTheme.appBarTheme.backgroundColor,
          equals(AppTheme.lightBackground));
    });

    test('app bar foreground is black', () {
      expect(lightTheme.appBarTheme.foregroundColor, equals(Colors.black));
    });

    test('input decoration has rounded borders', () {
      final border =
          lightTheme.inputDecorationTheme.border as OutlineInputBorder?;
      expect(border, isNotNull);
      expect(border!.borderRadius, equals(BorderRadius.circular(12)));
    });

    test('input decoration is filled', () {
      expect(lightTheme.inputDecorationTheme.filled, isTrue);
    });
  });

  group('AppTheme Dark Theme', () {
    late ThemeData darkTheme;

    setUp(() {
      darkTheme = AppTheme.darkTheme;
    });

    test('uses Material 3', () {
      expect(darkTheme.useMaterial3, isTrue);
    });

    test('has dark brightness', () {
      expect(darkTheme.brightness, equals(Brightness.dark));
    });

    test('color scheme uses correct primary color', () {
      expect(darkTheme.colorScheme.primary, equals(AppTheme.primaryColor));
    });

    test('color scheme uses correct secondary color', () {
      expect(darkTheme.colorScheme.secondary, equals(AppTheme.secondaryColor));
    });

    test('color scheme surface is dark background', () {
      expect(darkTheme.colorScheme.surface, equals(AppTheme.darkBackground));
    });

    test('scaffold background is dark background', () {
      expect(
          darkTheme.scaffoldBackgroundColor, equals(AppTheme.darkBackground));
    });

    test('app bar theme has zero elevation', () {
      expect(darkTheme.appBarTheme.elevation, equals(0));
    });

    test('app bar title is centered', () {
      expect(darkTheme.appBarTheme.centerTitle, isTrue);
    });

    test('app bar background matches scaffold', () {
      expect(darkTheme.appBarTheme.backgroundColor,
          equals(AppTheme.darkBackground));
    });

    test('app bar foreground is white', () {
      expect(darkTheme.appBarTheme.foregroundColor, equals(Colors.white));
    });

    test('input decoration has rounded borders', () {
      final border =
          darkTheme.inputDecorationTheme.border as OutlineInputBorder?;
      expect(border, isNotNull);
      expect(border!.borderRadius, equals(BorderRadius.circular(12)));
    });

    test('input decoration is filled', () {
      expect(darkTheme.inputDecorationTheme.filled, isTrue);
    });
  });

  group('Theme Consistency', () {
    test('both themes use same primary color', () {
      expect(
        AppTheme.lightTheme.colorScheme.primary,
        equals(AppTheme.darkTheme.colorScheme.primary),
      );
    });

    test('both themes use same secondary color', () {
      expect(
        AppTheme.lightTheme.colorScheme.secondary,
        equals(AppTheme.darkTheme.colorScheme.secondary),
      );
    });

    test('both themes use Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3,
          equals(AppTheme.darkTheme.useMaterial3));
    });

    test('both themes center app bar title', () {
      expect(
        AppTheme.lightTheme.appBarTheme.centerTitle,
        equals(AppTheme.darkTheme.appBarTheme.centerTitle),
      );
    });

    test('both themes have zero app bar elevation', () {
      expect(
        AppTheme.lightTheme.appBarTheme.elevation,
        equals(AppTheme.darkTheme.appBarTheme.elevation),
      );
    });

    test('both themes have matching input border radius', () {
      final lightBorder =
          AppTheme.lightTheme.inputDecorationTheme.border as OutlineInputBorder;
      final darkBorder =
          AppTheme.darkTheme.inputDecorationTheme.border as OutlineInputBorder;
      expect(lightBorder.borderRadius, equals(darkBorder.borderRadius));
    });
  });
}
