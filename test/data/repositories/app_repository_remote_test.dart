import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

const String _key = 'APP_PREFERENCES';

String todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

void main() {
  late FakeSharedPreferencesService prefs;
  late AppRepositoryRemote repository;

  setUp(() {
    prefs = FakeSharedPreferencesService();
    repository = AppRepositoryRemote(sharedPreferencesService: prefs);
  });

  group('getPreferences', () {
    test('returns defaults and leaves the notifier untouched when nothing is stored', () async {
      final before = repository.appPreferences.value;

      final result = await repository.getPreferences();

      expect(result, isA<Ok<AppPreferences>>());
      final value = result.asOk.value;
      expect(value.isVibrationEnabled, isTrue);
      expect(value.isNotificationsEnabled, isFalse);
      expect(value.isOnboardingCompleted, isFalse);
      expect(value.assistantDailyLimit, 5);
      expect(repository.appPreferences.value, same(before));
      expect(prefs.fetchedKeys, [_key]);
    });

    test('publishes the stored JSON on the notifier', () async {
      prefs.store[_key] = Fixtures.appPreferences(
        isVibrationEnabled: false,
        isNotificationsEnabled: true,
        isOnboardingCompleted: true,
        assistantDailyLimit: 2,
        lastLimitResetDate: '2026-03-15',
      ).toJson();

      final result = await repository.getPreferences();

      expect(result, isA<Ok<AppPreferences>>());
      final value = repository.appPreferences.value;
      expect(result.asOk.value, same(value));
      expect(value.isVibrationEnabled, isFalse);
      expect(value.isNotificationsEnabled, isTrue);
      expect(value.isOnboardingCompleted, isTrue);
      expect(value.assistantDailyLimit, 2);
      expect(value.lastLimitResetDate, '2026-03-15');
    });

    test('passes a service Error through unchanged', () async {
      final failure = Exception('read failed');
      prefs.fetchError = failure;

      final result = await repository.getPreferences();

      expect(result, isA<Error<AppPreferences>>());
      expect(result.asError.error, same(failure));
    });

    test('maps a thrown exception to AppLoadFailed', () async {
      prefs.throwOnFetch = true;

      final result = await repository.getPreferences();

      expect(result, isA<Error<AppPreferences>>());
      expect(result.asError.error, isA<AppLoadFailed>());
    });
  });

  group('update methods', () {
    test('updateIsVibrationEnabled persists and then updates the notifier', () async {
      final result = await repository.updateIsVibrationEnabled(
        isVibrationEnabled: false,
      );

      expect(result, isA<Ok<void>>());
      expect(prefs.savedKeys, [_key]);
      expect(prefs.store[_key]!['isVibrationEnabled'], isFalse);
      expect(repository.appPreferences.value.isVibrationEnabled, isFalse);
    });

    test('updateIsNotificationsEnabled persists and then updates the notifier', () async {
      final result = await repository.updateIsNotificationsEnabled(
        isNotificationsEnabled: true,
      );

      expect(result, isA<Ok<void>>());
      expect(prefs.store[_key]!['isNotificationsEnabled'], isTrue);
      expect(repository.appPreferences.value.isNotificationsEnabled, isTrue);
    });

    test('updateIsOnboardingCompleted persists and then updates the notifier', () async {
      final result = await repository.updateIsOnboardingCompleted(
        isOnboardingCompleted: true,
      );

      expect(result, isA<Ok<void>>());
      expect(prefs.store[_key]!['isOnboardingCompleted'], isTrue);
      expect(repository.appPreferences.value.isOnboardingCompleted, isTrue);
    });

    test('updateAssistantDailyLimit persists and then updates the notifier', () async {
      final result = await repository.updateAssistantDailyLimit(
        updatedDailyLimit: 1,
      );

      expect(result, isA<Ok<void>>());
      expect(prefs.store[_key]!['assistantDailyLimit'], 1);
      expect(repository.appPreferences.value.assistantDailyLimit, 1);
    });

    test('updates only the targeted field and keeps the rest', () async {
      await repository.updateIsNotificationsEnabled(
        isNotificationsEnabled: true,
      );
      await repository.updateAssistantDailyLimit(updatedDailyLimit: 3);

      final value = repository.appPreferences.value;
      expect(value.isNotificationsEnabled, isTrue);
      expect(value.assistantDailyLimit, 3);
      expect(value.isVibrationEnabled, isTrue);
      expect(prefs.store[_key]!['isNotificationsEnabled'], isTrue);
    });

    test('leaves the notifier untouched when the save returns Error', () async {
      final failure = Exception('disk full');
      prefs.saveError = failure;
      final before = repository.appPreferences.value;

      final result = await repository.updateIsVibrationEnabled(
        isVibrationEnabled: false,
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
      expect(repository.appPreferences.value, same(before));
      expect(repository.appPreferences.value.isVibrationEnabled, isTrue);
      expect(prefs.store, isEmpty);
    });

    test('leaves the notifier untouched when the save throws', () async {
      prefs.throwOnSave = true;
      final before = repository.appPreferences.value;

      final result = await repository.updateIsOnboardingCompleted(
        isOnboardingCompleted: true,
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error.toString(), 'Exception: fake save throw');
      expect(repository.appPreferences.value, same(before));
    });
  });

  group('resetAssistantDailyLimit', () {
    test('sets the limit to 5 and the reset date to today', () async {
      prefs.store[_key] = Fixtures.appPreferences(
        assistantDailyLimit: 0,
        lastLimitResetDate: '2000-01-01',
      ).toJson();
      await repository.getPreferences();
      expect(repository.appPreferences.value.assistantDailyLimit, 0);

      // Computed on both sides of the call so a midnight rollover during the
      // test cannot produce a spurious failure.
      final todayBefore = todayKey();
      final result = await repository.resetAssistantDailyLimit();
      final todayAfter = todayKey();

      expect(result, isA<Ok<void>>());
      final value = repository.appPreferences.value;
      expect(value.assistantDailyLimit, 5);
      expect(value.lastLimitResetDate, anyOf(todayBefore, todayAfter));
      expect(prefs.store[_key]!['assistantDailyLimit'], 5);
      expect(
        prefs.store[_key]!['lastLimitResetDate'],
        anyOf(todayBefore, todayAfter),
      );
    });

    test('propagates a save failure without touching the notifier', () async {
      prefs.saveError = Exception('x');
      final before = repository.appPreferences.value;

      final result = await repository.resetAssistantDailyLimit();

      expect(result, isA<Error<void>>());
      expect(repository.appPreferences.value, same(before));
    });
  });
}
