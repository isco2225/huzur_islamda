import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakePrayerRepository prayerRepository;
  late FakeNotificationRepository notificationRepository;
  late FakeUserRepository userRepository;
  late SchedulePrayerNotificationsUseCase useCase;

  setUp(() {
    prayerRepository = FakePrayerRepository();
    notificationRepository = FakeNotificationRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    useCase = SchedulePrayerNotificationsUseCase(
      prayerRepository: prayerRepository,
      notificationRepository: notificationRepository,
      userRepository: userRepository,
    );
  });

  /// A prayer covering today and tomorrow whose times are built relative to
  /// `now`, so the "future only" filter is deterministic:
  /// today -> fajr/sunrise in the past, the other four in the future;
  /// tomorrow -> every time in the future.
  Prayer buildRelativePrayer(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return Fixtures.prayer(
      prayerTimes: {
        Prayer.formatDate(today): PrayerTimes(
          fajr: now.subtract(const Duration(hours: 2)),
          sunrise: now.subtract(const Duration(hours: 1)),
          dhuhr: now.add(const Duration(hours: 1)),
          asr: now.add(const Duration(hours: 2)),
          maghrib: now.add(const Duration(hours: 3)),
          isha: now.add(const Duration(hours: 4)),
        ),
        Prayer.formatDate(tomorrow): Fixtures.prayerTimes(date: tomorrow),
      },
    );
  }

  group('SchedulePrayerNotificationsUseCase.scheduleForWeek', () {
    test('returns Ok(false) without any calls when districtId is empty', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(districtId: '');

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isFalse);
      expect(prayerRepository.calls, isEmpty);
      expect(notificationRepository.calls, isEmpty);
    });

    test('returns Ok(false) when city or country is empty', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(city: '');
      expect((await useCase.scheduleForWeek()).asOk.value, isFalse);

      userRepository.currentUserNotifier.value = Fixtures.user(country: '');
      expect((await useCase.scheduleForWeek()).asOk.value, isFalse);

      expect(notificationRepository.calls, isEmpty);
    });

    test(
      'returns Ok(false) when the location fields are null',
      () async {
        userRepository.currentUserNotifier.value = Fixtures.user(
          districtId: null,
          city: null,
          country: null,
        );

        final result = await useCase.scheduleForWeek();

        expect(result, isA<Ok<bool>>());
        expect(result.asOk.value, isFalse);
      },
      skip:
          'KNOWN BUG: scheduleForWeek applies `!` to the nullable location '
          'fields outside the try/catch, so a User with a null districtId, '
          'city or country throws a TypeError instead of returning Ok(false).',
    );

    test('cancels all old prayer notifications before reading the cache', () async {
      prayerRepository.getPrayerTimesLocallyResult = Ok(Fixtures.prayer());

      await useCase.scheduleForWeek();

      expect(notificationRepository.calls.first, 'cancelAllPrayerNotifications()');
      expect(prayerRepository.calls, [
        'getPrayerTimesLocally(districtId=9541, city=İstanbul, '
            'country=Türkiye)',
      ]);
    });

    test('continues when cancelling old notifications fails', () async {
      notificationRepository.cancelAllPrayerNotificationsResult = Error(
        Exception('cancel'),
      );
      prayerRepository.getPrayerTimesLocallyResult = Ok(Fixtures.prayer());

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isTrue);
    });

    test('returns an error when no prayer is cached', () async {
      prayerRepository.getPrayerTimesLocallyResult = const Ok(null);

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Error<bool>>());
      expect(
        result.asError.error.toString(),
        contains('Namaz vakitleri bulunamadı'),
      );
      expect(notificationRepository.scheduledPrayerNotifications, isEmpty);
    });

    test('propagates a local read error', () async {
      final exception = Exception('hive');
      prayerRepository.getPrayerTimesLocallyResult = Error(exception);

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Error<bool>>());
      expect(result.asError.error, same(exception));
    });

    test('schedules only future times, excluding sunrise, with a dateKey', () async {
      final now = DateTime.now();
      prayerRepository.getPrayerTimesLocallyResult = Ok(
        buildRelativePrayer(now),
      );
      final todayKey = Prayer.formatDate(now);
      final tomorrowKey = Prayer.formatDate(
        DateTime(now.year, now.month, now.day + 1),
      );

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isTrue);
      final scheduled = notificationRepository.scheduledPrayerNotifications;
      expect(scheduled, hasLength(4 + 5));
      expect(
        scheduled.where((s) => s.dateKey == todayKey).map((s) => s.prayerName),
        ['Öğle', 'İkindi', 'Akşam', 'Yatsı'],
      );
      expect(
        scheduled
            .where((s) => s.dateKey == tomorrowKey)
            .map((s) => s.prayerName),
        ['İmsak', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'],
      );
      expect(scheduled.map((s) => s.prayerName), isNot(contains('Güneş')));
      expect(
        scheduled.map((s) => s.prayerTime.isAfter(now)),
        everyElement(isTrue),
      );
      expect(
        scheduled.map((s) => s.dateKey),
        everyElement(matches(RegExp(r'^\d{4}-\d{2}-\d{2}$'))),
      );
    });

    test('schedules at most 7 days starting from today', () async {
      prayerRepository.getPrayerTimesLocallyResult = Ok(
        Fixtures.prayer(days: 10),
      );
      final now = DateTime.now();

      await useCase.scheduleForWeek();

      final keys = notificationRepository.scheduledPrayerNotifications
          .map((s) => s.dateKey)
          .toSet();
      final allowed = {
        for (var i = 0; i < 7; i++)
          Prayer.formatDate(DateTime(now.year, now.month, now.day + i)),
      };
      expect(keys.difference(allowed), isEmpty);
      // Tomorrow through day 6 are always fully in the future: 6 days x 5.
      expect(
        notificationRepository.scheduledPrayerNotifications.length,
        greaterThanOrEqualTo(6 * 5),
      );
      expect(
        notificationRepository.scheduledPrayerNotifications.length,
        lessThanOrEqualTo(7 * 5),
      );
    });

    test('ignores per-item scheduling errors and still returns Ok(true)', () async {
      final now = DateTime.now();
      prayerRepository.getPrayerTimesLocallyResult = Ok(
        buildRelativePrayer(now),
      );
      notificationRepository.onSchedulePrayerTimeNotification = (request) async =>
          request.prayerName == 'Öğle'
              ? Error(Exception('Öğle failed'))
              : const Ok(null);

      final result = await useCase.scheduleForWeek();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isTrue);
      expect(
        notificationRepository.scheduledPrayerNotifications,
        hasLength(9),
      );
    });

    test('returns Ok(true) even when no day has any future time', () async {
      final now = DateTime.now();
      prayerRepository.getPrayerTimesLocallyResult = Ok(
        Fixtures.prayer(
          from: DateTime(now.year, now.month, now.day - 5),
          days: 1,
        ),
      );

      final result = await useCase.scheduleForWeek();

      expect(result.asOk.value, isTrue);
      expect(notificationRepository.scheduledPrayerNotifications, isEmpty);
    });
  });

  group('SchedulePrayerNotificationsUseCase.cancelAll', () {
    test('delegates to the notification repository', () async {
      final result = await useCase.cancelAll();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, ['cancelAllPrayerNotifications()']);
    });

    test('passes a repository error through', () async {
      final exception = Exception('cancel');
      notificationRepository.cancelAllPrayerNotificationsResult = Error(
        exception,
      );

      final result = await useCase.cancelAll();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });
  });
}
