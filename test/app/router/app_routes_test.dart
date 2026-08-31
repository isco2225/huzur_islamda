import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/router/app_routes.dart';

void main() {
  /// Every route constant declared on [AppRoutes]. Keep in sync with the
  /// class; the "count" test below guards against silent drift.
  const allRoutes = <String, String>{
    'onboarding': AppRoutes.onboarding,
    'signIn': AppRoutes.signIn,
    'signUp': AppRoutes.signUp,
    'emailVerification': AppRoutes.emailVerification,
    'resetPassword': AppRoutes.resetPassword,
    'flow': AppRoutes.flow,
    'assistant': AppRoutes.assistant,
    'assistantForPost': AppRoutes.assistantForPost,
    'prayer': AppRoutes.prayer,
    'dhikr': AppRoutes.dhikr,
    'profile': AppRoutes.profile,
    'createProfile': AppRoutes.createProfile,
    'editProfile': AppRoutes.editProfile,
    'changePassword': AppRoutes.changePassword,
    'settings': AppRoutes.settings,
    'purchase': AppRoutes.purchase,
    'savedPosts': AppRoutes.savedPosts,
    'postDetail': AppRoutes.postDetail,
    'createDhikr': AppRoutes.createDhikr,
    'createDhikrByMood': AppRoutes.createDhikrByMood,
    'dhikrDetail': AppRoutes.dhikrDetail,
  };

  group('AppRoutes', () {
    test('declares 21 routes', () {
      expect(allRoutes, hasLength(21));
    });

    test('onboarding is the root path', () {
      expect(AppRoutes.onboarding, '/');
    });

    for (final entry in allRoutes.entries) {
      test('${entry.key} starts with a slash', () {
        expect(entry.value, startsWith('/'));
      });
    }

    test('no route other than the root ends with a slash', () {
      for (final entry in allRoutes.entries) {
        if (entry.value == '/') continue;
        expect(entry.value, isNot(endsWith('/')), reason: entry.key);
      }
    });

    test('no route contains whitespace or uppercase letters', () {
      for (final entry in allRoutes.entries) {
        expect(entry.value, isNot(contains(' ')), reason: entry.key);
        expect(entry.value, entry.value.toLowerCase(), reason: entry.key);
      }
    });

    test('all route values are unique', () {
      final values = allRoutes.values.toList();
      expect(values.toSet(), hasLength(values.length));
    });

    group('nested routes start with their parent path', () {
      test('editProfile is nested under profile', () {
        expect(AppRoutes.editProfile, startsWith('${AppRoutes.profile}/'));
      });

      test('changePassword is nested under profile', () {
        expect(
          AppRoutes.changePassword,
          startsWith('${AppRoutes.profile}/'),
        );
      });

      test('createDhikr is nested under dhikr', () {
        expect(AppRoutes.createDhikr, startsWith('${AppRoutes.dhikr}/'));
      });

      test('createDhikrByMood is nested under dhikr', () {
        expect(
          AppRoutes.createDhikrByMood,
          startsWith('${AppRoutes.dhikr}/'),
        );
      });

      test('dhikrDetail is nested under dhikr', () {
        expect(AppRoutes.dhikrDetail, startsWith('${AppRoutes.dhikr}/'));
      });
    });

    test('top-level routes have exactly one path segment', () {
      const nested = {
        AppRoutes.editProfile,
        AppRoutes.changePassword,
        AppRoutes.createDhikr,
        AppRoutes.createDhikrByMood,
        AppRoutes.dhikrDetail,
      };
      for (final entry in allRoutes.entries) {
        if (entry.value == '/' || nested.contains(entry.value)) continue;
        expect(
          entry.value.substring(1).split('/'),
          hasLength(1),
          reason: entry.key,
        );
      }
    });
  });
}
