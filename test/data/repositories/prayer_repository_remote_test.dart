import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHiveService<Prayer> hive;
  late FakePrayerService prayerService;
  late PrayerRepositoryRemote repository;
  final currentYear = DateTime.now().year;

  setUp(() {
    hive = FakeHiveService<Prayer>(boxName: Prayer.boxName);
    prayerService = FakePrayerService();
    repository = PrayerRepositoryRemote(
      hiveService: hive,
      prayerService: prayerService,
    );
  });

  group('getPrayerTimesLocally', () {
    test(
      'returns the cached prayer when district, city and country all match',
      () async {
        final prayer = Fixtures.prayer(year: currentYear);
        hive.store['prayer_${currentYear}_9541'] = prayer;

        final result = await repository.getPrayerTimesLocally(
          districtId: '9541',
          city: 'İstanbul',
          country: 'Türkiye',
        );

        expect(result, isA<Ok<Prayer?>>());
        expect(result.asOk.value, same(prayer));
        expect(hive.calls, ['getById']);
      },
    );

    test('looks up the key prayer_<currentYear>_<districtId>', () async {
      // Cached under last year's key: must not be found.
      hive.store['prayer_${currentYear - 1}_9541'] = Fixtures.prayer(
        year: currentYear - 1,
      );

      final result = await repository.getPrayerTimesLocally(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
      );

      expect(result, isA<Ok<Prayer?>>());
      expect(result.asOk.value, isNull);
    });

    test('returns Ok(null) when the city does not match', () async {
      hive.store['prayer_${currentYear}_9541'] = Fixtures.prayer(
        year: currentYear,
      );

      final result = await repository.getPrayerTimesLocally(
        districtId: '9541',
        city: 'Ankara',
        country: 'Türkiye',
      );

      expect(result.asOk.value, isNull);
    });

    test('returns Ok(null) when the country does not match', () async {
      hive.store['prayer_${currentYear}_9541'] = Fixtures.prayer(
        year: currentYear,
      );

      final result = await repository.getPrayerTimesLocally(
        districtId: '9541',
        city: 'İstanbul',
        country: 'KKTC',
      );

      expect(result.asOk.value, isNull);
    });

    test('returns Ok(null) when nothing is cached', () async {
      final result = await repository.getPrayerTimesLocally(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
      );

      expect(result, isA<Ok<Prayer?>>());
      expect(result.asOk.value, isNull);
    });

    test('propagates a Hive read failure', () async {
      hive.alwaysFail.add('getById');

      final result = await repository.getPrayerTimesLocally(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
      );

      expect(result, isA<Error<Prayer?>>());
      expect(result.asError.error, same(hive.failure));
    });
  });

  group('savePrayerTimesLocally', () {
    test('keys the entry on prayer.year and prayer.districtId', () async {
      final prayer = Fixtures.prayer(year: 2024, districtId: '77');

      final result = await repository.savePrayerTimesLocally(prayer: prayer);

      expect(result, isA<Ok<void>>());
      expect(hive.savedKeys, ['prayer_2024_77']);
      expect(hive.store['prayer_2024_77'], same(prayer));
    });

    test('propagates a Hive write failure', () async {
      hive.alwaysFail.add('save');

      final result = await repository.savePrayerTimesLocally(
        prayer: Fixtures.prayer(),
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(hive.failure));
      expect(hive.store, isEmpty);
    });
  });

  group('clearOldPrayerTimes', () {
    test(
      'deletes only entries of the same user for a different district',
      () async {
        hive.store['prayer_2026_d1'] = Fixtures.prayer(
          userId: 'u1',
          districtId: 'd1',
          year: 2026,
        );
        hive.store['prayer_2025_d2'] = Fixtures.prayer(
          userId: 'u1',
          districtId: 'd2',
          year: 2025,
        );
        hive.store['prayer_2024_d3'] = Fixtures.prayer(
          userId: 'u1',
          districtId: 'd3',
          year: 2024,
        );
        hive.store['prayer_2023_d2'] = Fixtures.prayer(
          userId: 'u2',
          districtId: 'd2',
          year: 2023,
        );

        final result = await repository.clearOldPrayerTimes(
          currentDistrictId: 'd1',
          userId: 'u1',
        );

        expect(result, isA<Ok<void>>());
        expect(hive.deletedKeys, unorderedEquals(['prayer_2025_d2', 'prayer_2024_d3']));
        expect(hive.store.keys, unorderedEquals(['prayer_2026_d1', 'prayer_2023_d2']));
      },
    );

    test('returns Ok(null) without deleting when nothing matches', () async {
      hive.store['prayer_2026_d1'] = Fixtures.prayer(
        userId: 'u1',
        districtId: 'd1',
        year: 2026,
      );
      hive.store['prayer_2026_d2'] = Fixtures.prayer(
        userId: 'other',
        districtId: 'd2',
        year: 2026,
      );

      final result = await repository.clearOldPrayerTimes(
        currentDistrictId: 'd1',
        userId: 'u1',
      );

      expect(result, isA<Ok<void>>());
      expect(hive.calls, ['getAll']);
      expect(hive.store.length, 2);
    });

    test('propagates a failure while reading all prayers', () async {
      hive.alwaysFail.add('getAll');

      final result = await repository.clearOldPrayerTimes(
        currentDistrictId: 'd1',
        userId: 'u1',
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(hive.failure));
    });

    test('propagates a failure while deleting', () async {
      hive.store['prayer_2025_d2'] = Fixtures.prayer(
        userId: 'u1',
        districtId: 'd2',
        year: 2025,
      );
      hive.alwaysFail.add('deleteMany');

      final result = await repository.clearOldPrayerTimes(
        currentDistrictId: 'd1',
        userId: 'u1',
      );

      expect(result, isA<Error<void>>());
      expect(hive.store.length, 1);
    });
  });

  group('clearAllPrayerTimesLocally', () {
    test('clears the box', () async {
      hive.store['prayer_2026_d1'] = Fixtures.prayer();

      final result = await repository.clearAllPrayerTimesLocally();

      expect(result, isA<Ok<void>>());
      expect(hive.calls, ['clear']);
      expect(hive.store, isEmpty);
    });

    test('propagates a Hive failure', () async {
      hive.alwaysFail.add('clear');

      final result = await repository.clearAllPrayerTimesLocally();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(hive.failure));
    });
  });

  group('getPrayerTimesFromRemote', () {
    final apiJson = <String, dynamic>{
      'meta': {'year': 2026, 'district_id': '9541'},
      'data': [
        {
          'district_id': '9541',
          'date': '2026-01-01T00:00:00.000Z',
          'times': {
            'imsak': '06:50',
            'gunes': '08:25',
            'ogle': '13:15',
            'ikindi': '15:35',
            'aksam': '17:55',
            'yatsi': '19:25',
          },
        },
        {
          'district_id': '9541',
          'date': '2026-01-02T00:00:00.000Z',
          'times': {
            'imsak': '06:50',
            'gunes': '08:25',
            'ogle': '13:16',
            'ikindi': '15:36',
            'aksam': '17:56',
            'yatsi': '19:26',
          },
        },
      ],
    };

    test('maps the API payload through Prayer.fromApiJson', () async {
      prayerService.result = Result.ok(apiJson);

      final result = await repository.getPrayerTimesFromRemote(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
        userId: 'uid-1',
      );

      expect(result, isA<Ok<Prayer?>>());
      final prayer = result.asOk.value!;
      expect(prayer.id, 'prayer_2026_9541');
      expect(prayer.year, 2026);
      expect(prayer.userId, 'uid-1');
      expect(prayer.districtId, '9541');
      expect(prayer.city, 'İstanbul');
      expect(prayer.country, 'Türkiye');
      expect(prayer.prayerTimes.keys, ['2026-01-01', '2026-01-02']);
      expect(prayer.prayerTimes['2026-01-02']!.dhuhr.minute, 16);
      expect(prayerService.requestedDistrictIds, ['9541']);
    });

    test('does not touch Hive', () async {
      prayerService.result = Result.ok(apiJson);

      await repository.getPrayerTimesFromRemote(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
        userId: 'uid-1',
      );

      expect(hive.calls, isEmpty);
    });

    test('propagates the service error unchanged', () async {
      final failure = Exception('Network error: offline');
      prayerService.result = Result.error(failure);

      final result = await repository.getPrayerTimesFromRemote(
        districtId: '9541',
        city: 'İstanbul',
        country: 'Türkiye',
        userId: 'uid-1',
      );

      expect(result, isA<Error<Prayer?>>());
      expect(result.asError.error, same(failure));
    });
  });
}
