import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Minimal slice of the yearly response returned by
/// `https://ezanvakti.imsakiyem.com/api/prayer-times/{districtId}/yearly`.
const String _apiFixture = '''
{
  "meta": { "year": 2026, "district_id": "9541" },
  "data": [
    {
      "district_id": "9541",
      "date": "2026-01-01T00:00:00.000Z",
      "times": {
        "imsak": "06:50", "gunes": "08:25", "ogle": "13:15",
        "ikindi": "15:35", "aksam": "17:55", "yatsi": "19:25"
      }
    },
    {
      "district_id": "9541",
      "date": "2026-01-02T00:00:00.000Z",
      "times": {
        "imsak": "06:50", "gunes": "08:25", "ogle": "13:16",
        "ikindi": "15:36", "aksam": "17:56", "yatsi": "19:26"
      }
    },
    { "district_id": "9541", "date": "2026-01-03T00:00:00.000Z" },
    { "district_id": "9541", "times": { "imsak": "06:50" } },
    "not-a-map"
  ]
}
''';

void main() {
  Map<String, Object?> decode(String s) =>
      jsonDecode(s) as Map<String, Object?>;

  group('Prayer.fromApiJson', () {
    late Prayer prayer;

    setUp(() {
      prayer = Prayer.fromApiJson(
        decode(_apiFixture),
        'user-1',
        '9541',
        'İstanbul',
        'Türkiye',
        latitude: 41.0,
        longitude: 29.0,
      );
    });

    test('derives id, year and location from meta and arguments', () {
      expect(prayer.id, 'prayer_2026_9541');
      expect(prayer.year, 2026);
      expect(prayer.userId, 'user-1');
      expect(prayer.districtId, '9541');
      expect(prayer.city, 'İstanbul');
      expect(prayer.country, 'Türkiye');
      expect(prayer.latitude, 41.0);
      expect(prayer.longitude, 29.0);
    });

    test('keys prayer times by YYYY-MM-DD and skips incomplete entries', () {
      expect(prayer.prayerTimes.keys, ['2026-01-01', '2026-01-02']);
    });

    test('parses each day\'s times onto that day', () {
      final day2 = prayer.getPrayerTimesForDate('2026-01-02');

      expect(day2, isNotNull);
      expect(day2!.dhuhr.day, 2);
      expect(day2.dhuhr.hour, 13);
      expect(day2.dhuhr.minute, 16);
    });

    test('date lookups work with DateTime as well as string', () {
      final viaString = prayer.getPrayerTimesForDate('2026-01-01');
      final viaDate = prayer.getPrayerTimesForDateTime(DateTime(2026, 1, 1));

      expect(viaDate, same(viaString));
      expect(prayer.getPrayerTimesForDateTime(DateTime(2026, 6, 1)), isNull);
    });

    test('falls back to current year when meta is missing', () {
      final result = Prayer.fromApiJson(
        {'data': <Object?>[]},
        'u',
        'd',
        'c',
        'co',
      );

      expect(result.year, DateTime.now().year);
      expect(result.prayerTimes, isEmpty);
    });

    test('tolerates a missing data list', () {
      final result = Prayer.fromApiJson(
        {
          'meta': {'year': 2025},
        },
        'u',
        'd',
        'c',
        'co',
      );

      expect(result.prayerTimes, isEmpty);
      expect(result.id, 'prayer_2025_d');
    });
  });

  group('Prayer.formatDate', () {
    test('zero-pads month and day', () {
      expect(Prayer.formatDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(Prayer.formatDate(DateTime(2026, 12, 25)), '2026-12-25');
    });
  });

  group('Prayer.fromJson / toJson', () {
    test('round-trips including nested prayer times', () {
      final original = Prayer.fromApiJson(
        decode(_apiFixture),
        'user-1',
        '9541',
        'İstanbul',
        'Türkiye',
      );

      final restored = Prayer.fromJson(
        Map<String, Object?>.from(original.toJson()),
      );

      expect(restored.id, original.id);
      expect(restored.year, original.year);
      expect(restored.districtId, original.districtId);
      expect(restored.latitude, isNull);
      expect(restored.prayerTimes.keys, original.prayerTimes.keys);
      expect(
        restored.prayerTimes['2026-01-01']!.fajr,
        original.prayerTimes['2026-01-01']!.fajr,
      );
    });

    test('accepts snake_case aliases and defaults for missing fields', () {
      final restored = Prayer.fromJson({
        'district_id': '77',
        'prayer_times': {
          '2026-02-01': {
            'fajr': '2026-02-01T05:00:00.000',
            'sunrise': '2026-02-01T06:00:00.000',
            'dhuhr': '2026-02-01T13:00:00.000',
            'asr': '2026-02-01T16:00:00.000',
            'maghrib': '2026-02-01T19:00:00.000',
            'isha': '2026-02-01T21:00:00.000',
          },
          'ignored': 'not a map',
        },
      });

      expect(restored.districtId, '77');
      expect(restored.id, '');
      expect(restored.year, DateTime.now().year);
      expect(restored.prayerTimes.keys, ['2026-02-01']);
    });
  });

  group('Prayer.copyWith', () {
    test('overrides only the given fields', () {
      const original = Prayer(
        id: 'p',
        userId: 'u',
        year: 2026,
        districtId: 'd',
        city: 'c',
        country: 'co',
        prayerTimes: {},
      );

      final copy = original.copyWith(city: 'Ankara', latitude: 39.9);

      expect(copy.city, 'Ankara');
      expect(copy.latitude, 39.9);
      expect(copy.id, 'p');
      expect(copy.year, 2026);
      expect(copy.prayerTimes, isEmpty);
    });
  });
}
