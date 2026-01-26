import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/constants/app_strings.dart';

void main() {
  group('AppStrings Constants', () {
    group('App metadata', () {
      test('appName is TransHarbor', () {
        expect(AppStrings.appName, equals('TransHarbor'));
        expect(AppStrings.appName, isNotEmpty);
      });

      test('appTagline is defined and descriptive', () {
        expect(AppStrings.appTagline,
            equals('User-Owned Platform for Trans & Nonbinary People'));
        expect(AppStrings.appTagline.length, greaterThan(10));
      });
    });

    group('Core values', () {
      test('all core values are defined', () {
        expect(AppStrings.userOwned, equals('User-Owned'));
        expect(AppStrings.transCentered, equals('Trans-Centered'));
        expect(AppStrings.privacyFirst, equals('Privacy-First'));
        expect(AppStrings.democratic, equals('Democratic'));
        expect(AppStrings.nonprofit, equals('Nonprofit'));
      });

      test('core values are non-empty strings', () {
        expect(AppStrings.userOwned, isNotEmpty);
        expect(AppStrings.transCentered, isNotEmpty);
        expect(AppStrings.privacyFirst, isNotEmpty);
        expect(AppStrings.democratic, isNotEmpty);
        expect(AppStrings.nonprofit, isNotEmpty);
      });
    });

    group('Feature strings', () {
      test('feature names are defined', () {
        expect(AppStrings.personals, equals('Personals'));
        expect(AppStrings.messaging, equals('Messaging'));
        expect(AppStrings.governance, equals('Governance'));
      });

      test('feature descriptions are defined', () {
        expect(AppStrings.personalDescription,
            equals('Text posts to connect with others'));
        expect(
            AppStrings.messagingDescription, equals('Private conversations'));
        expect(AppStrings.governanceDescription,
            equals('Active members vote on decisions'));
      });

      test('feature descriptions are descriptive', () {
        expect(AppStrings.personalDescription.length, greaterThan(5));
        expect(AppStrings.messagingDescription.length, greaterThan(5));
        expect(AppStrings.governanceDescription.length, greaterThan(5));
      });
    });

    group('Auth strings', () {
      test('auth action strings are defined', () {
        expect(AppStrings.login, equals('Login'));
        expect(AppStrings.register, equals('Register'));
        expect(AppStrings.logout, equals('Logout'));
      });

      test('auth field strings are defined', () {
        expect(AppStrings.email, equals('Email'));
        expect(AppStrings.password, equals('Password'));
        expect(AppStrings.confirmPassword, equals('Confirm Password'));
        expect(AppStrings.forgotPassword, equals('Forgot Password?'));
      });

      test('all auth strings are non-empty', () {
        expect(AppStrings.login, isNotEmpty);
        expect(AppStrings.email, isNotEmpty);
        expect(AppStrings.password, isNotEmpty);
      });
    });

    group('Navigation strings', () {
      test('navigation labels are defined', () {
        expect(AppStrings.home, equals('Home'));
        expect(AppStrings.profile, equals('Profile'));
        expect(AppStrings.settings, equals('Settings'));
      });

      test('navigation labels are non-empty', () {
        expect(AppStrings.home, isNotEmpty);
        expect(AppStrings.profile, isNotEmpty);
        expect(AppStrings.settings, isNotEmpty);
      });
    });

    group('Common UI strings', () {
      test('common action strings are defined', () {
        expect(AppStrings.submit, equals('Submit'));
        expect(AppStrings.cancel, equals('Cancel'));
        expect(AppStrings.save, equals('Save'));
        expect(AppStrings.delete, equals('Delete'));
      });

      test('common state strings are defined', () {
        expect(AppStrings.loading, equals('Loading...'));
        expect(AppStrings.error, equals('Error'));
      });

      test('all common strings are non-empty', () {
        expect(AppStrings.submit, isNotEmpty);
        expect(AppStrings.cancel, isNotEmpty);
        expect(AppStrings.loading, isNotEmpty);
        expect(AppStrings.error, isNotEmpty);
      });
    });

    group('String consistency', () {
      test('no strings contain only whitespace', () {
        expect(AppStrings.appName.trim(), equals(AppStrings.appName));
        expect(AppStrings.login.trim(), equals(AppStrings.login));
        expect(AppStrings.home.trim(), equals(AppStrings.home));
      });

      test('action strings use title case', () {
        expect(AppStrings.login, matches(RegExp(r'^[A-Z]')));
        expect(AppStrings.register, matches(RegExp(r'^[A-Z]')));
        expect(AppStrings.submit, matches(RegExp(r'^[A-Z]')));
      });
    });
  });
}
