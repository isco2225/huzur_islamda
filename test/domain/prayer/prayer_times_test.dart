import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  final date = DateTime(2026, 3, 15);

  PrayerTimes buildFromApi({
    String? imsak = '05:10',
    String? gunes = '06:40',
    String? ogle = '13:05',
    String? ikindi = '16:30',
    String? aksam = '19:20',
    String? yatsi = '20:45',
  }) {
    return PrayerTimes.fromApiJson({
      'imsak': imsak,
      'gunes': gunes,
      'ogle': ogle,
      'ikindi': ikindi,
      'aksam': aksam,
      'yatsi': yatsi,
    }, date);
  }

  group('PrayerTimes.fromApiJson', () {
    test('parses HH:mm strings onto the given date', () {
      final times = buildFromApi();

      expect(times.fajr, DateTime(2026, 3, 15, 5, 10));
      expect(times.sunrise, DateTime(2026, 3, 15, 6, 40));
      expect(times.dhuhr, DateTime(2026, 3, 15, 13, 5));
      expect(times.asr, DateTime(2026, 3, 15, 16, 30));
      expect(times.maghrib, DateTime(2026, 3, 15, 19, 20));
      expect(times.isha, DateTime(2026, 3, 15, 20, 45));
    });

    test('falls back to midnight of the date for missing or empty values', () {
      final times = buildFromApi(imsak: null, gunes: '');

      expect(times.fajr, date);
      expect(times.sunrise, date);
    });

    test('falls back to midnight for malformed time strings', () {
      final times = buildFromApi(ogle: '13-05', ikindi: '16:30:00');

      expect(times.dhuhr, date);
      expect(times.asr, date);
    });

    test('non-numeric parts default to zero', () {
      final times = buildFromApi(aksam: 'xx:30');

      expect(times.maghrib, DateTime(2026, 3, 15, 0, 30));
    });
  });

  group('PrayerTimes.fromJson / toJson', () {
    test('round-trips through ISO-8601 strings', () {
      final original = buildFromApi();

      final restored = PrayerTimes.fromJson(original.toJson());

      expect(restored.fajr, original.fajr);
      expect(restored.sunrise, original.sunrise);
      expect(restored.dhuhr, original.dhuhr);
      expect(restored.asr, original.asr);
      expect(restored.maghrib, original.maghrib);
      expect(restored.isha, original.isha);
    });

    test('accepts capitalised legacy keys', () {
      final restored = PrayerTimes.fromJson({
        'Fajr': '2026-03-15T05:10:00.000',
        'Sunrise': '2026-03-15T06:40:00.000',
        'Dhuhr': '2026-03-15T13:05:00.000',
        'Asr': '2026-03-15T16:30:00.000',
        'Maghrib': '2026-03-15T19:20:00.000',
        'Isha': '2026-03-15T20:45:00.000',
      });

      expect(restored.fajr, DateTime(2026, 3, 15, 5, 10));
      expect(restored.isha, DateTime(2026, 3, 15, 20, 45));
    });

    test('accepts DateTime values directly', () {
      final restored = PrayerTimes.fromJson({
        'fajr': DateTime(2026, 1, 1, 5),
        'sunrise': DateTime(2026, 1, 1, 6),
        'dhuhr': DateTime(2026, 1, 1, 13),
        'asr': DateTime(2026, 1, 1, 16),
        'maghrib': DateTime(2026, 1, 1, 19),
        'isha': DateTime(2026, 1, 1, 21),
      });

      expect(restored.dhuhr, DateTime(2026, 1, 1, 13));
    });
  });

  group('PrayerTimes.copyWith', () {
    test('overrides only the given fields', () {
      final original = buildFromApi();
      final newIsha = DateTime(2026, 3, 15, 21, 0);

      final copy = original.copyWith(isha: newIsha);

      expect(copy.isha, newIsha);
      expect(copy.fajr, original.fajr);
      expect(copy.maghrib, original.maghrib);
    });
  });

  group('PrayerTimes.allPrayerTimes', () {
    test('lists the six times in chronological order with Turkish names', () {
      final times = buildFromApi();

      final names = times.allPrayerTimes.map((e) => e.name).toList();
      final values = times.allPrayerTimes.map((e) => e.time).toList();

      expect(names, ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı']);
      for (var i = 1; i < values.length; i++) {
        expect(values[i].isAfter(values[i - 1]), isTrue);
      }
    });
  });

  group('PrayerTimes time-of-day queries (relative to now)', () {
    PrayerTimes relative({
      required Duration fajr,
      required Duration sunrise,
      required Duration dhuhr,
      required Duration asr,
      required Duration maghrib,
      required Duration isha,
    }) {
      final now = DateTime.now();
      return PrayerTimes(
        fajr: now.add(fajr),
        sunrise: now.add(sunrise),
        dhuhr: now.add(dhuhr),
        asr: now.add(asr),
        maghrib: now.add(maghrib),
        isha: now.add(isha),
      );
    }

    test('getNextPrayerTime returns the first time in the future', () {
      final times = relative(
        fajr: const Duration(hours: -10),
        sunrise: const Duration(hours: -8),
        dhuhr: const Duration(hours: -2),
        asr: const Duration(hours: 1),
        maghrib: const Duration(hours: 3),
        isha: const Duration(hours: 5),
      );

      final next = times.getNextPrayerTime();

      expect(next, isNotNull);
      expect(next!.name, 'İkindi');
      expect(next.time, times.asr);
    });

    test(
      'getNextPrayerTime rolls over to tomorrow\'s İmsak when all passed',
      () {
        final times = relative(
          fajr: const Duration(hours: -20),
          sunrise: const Duration(hours: -18),
          dhuhr: const Duration(hours: -12),
          asr: const Duration(hours: -9),
          maghrib: const Duration(hours: -6),
          isha: const Duration(hours: -4),
        );

        final next = times.getNextPrayerTime();
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);

        expect(next, isNotNull);
        expect(next!.name, 'İmsak');
        expect(next.time.year, tomorrow.year);
        expect(next.time.month, tomorrow.month);
        expect(next.time.day, tomorrow.day);
        expect(next.time.hour, times.fajr.hour);
        expect(next.time.minute, times.fajr.minute);
      },
    );

    test('getRemainingTimeToNextPrayer is positive and close to the gap', () {
      final times = relative(
        fajr: const Duration(hours: -10),
        sunrise: const Duration(hours: -8),
        dhuhr: const Duration(hours: -2),
        asr: const Duration(minutes: 30),
        maghrib: const Duration(hours: 3),
        isha: const Duration(hours: 5),
      );

      final remaining = times.getRemainingTimeToNextPrayer();

      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, inInclusiveRange(29, 30));
    });

    test('getCurrentPrayerTime identifies the window we are in', () {
      final between = relative(
        fajr: const Duration(hours: -10),
        sunrise: const Duration(hours: -8),
        dhuhr: const Duration(hours: -2),
        asr: const Duration(hours: 1),
        maghrib: const Duration(hours: 3),
        isha: const Duration(hours: 5),
      );
      expect(between.getCurrentPrayerTime(), 'Öğle');

      final afterIsha = relative(
        fajr: const Duration(hours: -20),
        sunrise: const Duration(hours: -18),
        dhuhr: const Duration(hours: -12),
        asr: const Duration(hours: -9),
        maghrib: const Duration(hours: -6),
        isha: const Duration(hours: -1),
      );
      expect(afterIsha.getCurrentPrayerTime(), 'Yatsı');

      final beforeFajr = relative(
        fajr: const Duration(hours: 1),
        sunrise: const Duration(hours: 2),
        dhuhr: const Duration(hours: 8),
        asr: const Duration(hours: 11),
        maghrib: const Duration(hours: 14),
        isha: const Duration(hours: 16),
      );
      expect(beforeFajr.getCurrentPrayerTime(), 'Yatsı');
    });
  });
}
