import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

/// Formats a date as `yyyy-MM-dd` with zero padding.
String formatDay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

void main() {
  group('AppPreferences.empty', () {
    test('uses the documented defaults', () {
      final prefs = AppPreferences.empty();

      expect(prefs.isVibrationEnabled, isTrue);
      expect(prefs.isNotificationsEnabled, isFalse);
      expect(prefs.isOnboardingCompleted, isFalse);
      expect(prefs.assistantDailyLimit, 5);
    });

    test('sets lastLimitResetDate to today as zero-padded yyyy-MM-dd', () {
      final today = formatDay(DateTime.now());

      final prefs = AppPreferences.empty();

      expect(prefs.lastLimitResetDate, today);
      expect(prefs.lastLimitResetDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });

  group('AppPreferences.fromJson', () {
    test('applies defaults for every missing key', () {
      final prefs = AppPreferences.fromJson({});

      expect(prefs.isVibrationEnabled, isTrue);
      expect(prefs.isNotificationsEnabled, isFalse);
      expect(prefs.isOnboardingCompleted, isFalse);
      expect(prefs.assistantDailyLimit, 5);
      expect(prefs.lastLimitResetDate, formatDay(DateTime.now()));
    });

    test('reads every provided key', () {
      final prefs = AppPreferences.fromJson({
        'isVibrationEnabled': false,
        'isNotificationsEnabled': true,
        'isOnboardingCompleted': true,
        'assistantDailyLimit': 2,
        'lastLimitResetDate': '2026-01-05',
      });

      expect(prefs.isVibrationEnabled, isFalse);
      expect(prefs.isNotificationsEnabled, isTrue);
      expect(prefs.isOnboardingCompleted, isTrue);
      expect(prefs.assistantDailyLimit, 2);
      expect(prefs.lastLimitResetDate, '2026-01-05');
    });

    test('throws on wrongly typed values instead of falling back', () {
      // `as int?` / `as bool?` casts fail loudly for present-but-wrong types.
      expect(
        () => AppPreferences.fromJson({'assistantDailyLimit': '3'}),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => AppPreferences.fromJson({'isVibrationEnabled': 'yes'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('AppPreferences.toJson', () {
    test('round-trips every field', () {
      final original = Fixtures.appPreferences(
        isVibrationEnabled: false,
        isNotificationsEnabled: true,
        isOnboardingCompleted: true,
        assistantDailyLimit: 1,
        lastLimitResetDate: '2026-02-09',
      );

      final json = original.toJson();
      final restored = AppPreferences.fromJson(Map<String, Object?>.from(json));

      expect(json, {
        'isVibrationEnabled': false,
        'isNotificationsEnabled': true,
        'isOnboardingCompleted': true,
        'assistantDailyLimit': 1,
        'lastLimitResetDate': '2026-02-09',
      });
      expect(restored.isVibrationEnabled, original.isVibrationEnabled);
      expect(restored.isNotificationsEnabled, original.isNotificationsEnabled);
      expect(restored.isOnboardingCompleted, original.isOnboardingCompleted);
      expect(restored.assistantDailyLimit, original.assistantDailyLimit);
      expect(restored.lastLimitResetDate, original.lastLimitResetDate);
    });
  });

  group('AppPreferences.copyWith', () {
    test('overrides only the given fields', () {
      final original = Fixtures.appPreferences();

      final copy = original.copyWith(
        assistantDailyLimit: 0,
        isNotificationsEnabled: true,
      );

      expect(copy.assistantDailyLimit, 0);
      expect(copy.isNotificationsEnabled, isTrue);
      expect(copy.isVibrationEnabled, original.isVibrationEnabled);
      expect(copy.isOnboardingCompleted, original.isOnboardingCompleted);
      expect(copy.lastLimitResetDate, original.lastLimitResetDate);
    });
  });

  group('AppPreferences.isEmpty', () {
    test('is false for customised preferences', () {
      expect(
        Fixtures.appPreferences(isOnboardingCompleted: true).isEmpty(),
        isFalse,
      );
    });

    test(
      'is true for default preferences',
      () {
        expect(AppPreferences.empty().isEmpty(), isTrue);
        expect(AppPreferences.fromJson({}).isEmpty(), isTrue);
      },
    );

    test('ignores lastLimitResetDate', () {
      expect(
        AppPreferences.empty().copyWith(lastLimitResetDate: '2020-01-01').isEmpty(),
        isTrue,
      );
    });
  });

  group('AppLoadFailed', () {
    test('is a const AppException that implements Exception', () {
      const exception = AppLoadFailed();

      expect(exception, isA<Exception>());
      expect(exception, isA<AppException>());
      expect(identical(const AppLoadFailed(), const AppLoadFailed()), isTrue);
    });
  });
}
