import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fixtures.dart';

/// Exercises the real [HiveService] against a temporary on-disk Hive store
/// (plain `Hive.init`, no Flutter path_provider involvement).
void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_service_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(DhikrAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PrayerAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PrayerTimesAdapter());
    }
  });

  tearDown(() async {
    // `Hive.deleteFromDisk()` only removes *open* boxes, so delete the test
    // boxes by name (works whether they are open or already closed).
    await Hive.deleteBoxFromDisk('dhikrs_test');
    await Hive.deleteBoxFromDisk('prayers_test');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('HiveService<Dhikr>', () {
    late HiveService<Dhikr> service;

    setUp(() {
      service = HiveService<Dhikr>('dhikrs_test');
    });

    test('save stores the value and returns it as Ok', () async {
      final dhikr = Fixtures.dhikr(id: 'd1');

      final result = await service.save('d1', dhikr);

      expect(result, isA<Ok<Dhikr>>());
      expect(result.asOk.value.id, 'd1');
      final fetched = await service.getById('d1');
      expect(fetched.asOk.value?.name, 'Subhanallah');
    });

    test('update overwrites the value stored under the same key', () async {
      await service.save('d1', Fixtures.dhikr(id: 'd1', currentCount: 0));

      final result = await service.update(
        'd1',
        Fixtures.dhikr(id: 'd1', currentCount: 10),
      );

      expect(result, isA<Ok<Dhikr>>());
      final fetched = await service.getById('d1');
      expect(fetched.asOk.value?.currentCount, 10);
      expect((await service.count()).asOk.value, 1);
    });

    test('saveAll stores every entry', () async {
      final result = await service.saveAll({
        'a': Fixtures.dhikr(id: 'a'),
        'b': Fixtures.dhikr(id: 'b'),
      });

      expect(result, isA<Ok<void>>());
      expect((await service.count()).asOk.value, 2);
    });

    test('getById returns Ok(null) for an unknown key', () async {
      final result = await service.getById('missing');

      expect(result, isA<Ok<Dhikr?>>());
      expect(result.asOk.value, isNull);
    });

    test('getAll returns every value, ordered by key (not insertion)', () async {
      await service.save('b', Fixtures.dhikr(id: 'b'));
      await service.save('a', Fixtures.dhikr(id: 'a'));
      await service.save('c', Fixtures.dhikr(id: 'c'));

      final result = await service.getAll();

      expect(result, isA<Ok<List<Dhikr>>>());
      expect(result.asOk.value.map((d) => d.id), ['a', 'b', 'c']);
    });

    test('getAll returns an empty list for an empty box', () async {
      final result = await service.getAll();

      expect(result.asOk.value, isEmpty);
    });

    test('getWithFilter returns only matching values', () async {
      await service.save('a', Fixtures.dhikr(id: 'a', isSynced: true));
      await service.save('b', Fixtures.dhikr(id: 'b', isSynced: false));
      await service.save('c', Fixtures.dhikr(id: 'c', isSynced: false));

      final result = await service.getWithFilter((d) => !d.isSynced);

      expect(result, isA<Ok<List<Dhikr>?>>());
      expect(result.asOk.value!.map((d) => d.id), ['b', 'c']);
    });

    test(
      'getWithFilter returns Ok(null) rather than Ok([]) when nothing matches',
      () async {
        // Documented quirk: callers must treat null as "no results".
        await service.save('a', Fixtures.dhikr(id: 'a', isSynced: true));

        final result = await service.getWithFilter((d) => !d.isSynced);

        expect(result, isA<Ok<List<Dhikr>?>>());
        expect(result.asOk.value, isNull);
      },
    );

    test('getAllAsMap maps keys to values', () async {
      await service.save('x', Fixtures.dhikr(id: 'x'));
      await service.save('y', Fixtures.dhikr(id: 'y'));

      final result = await service.getAllAsMap();

      expect(result, isA<Ok<Map<String, Dhikr>>>());
      expect(result.asOk.value.keys, containsAll(['x', 'y']));
      expect(result.asOk.value['x']!.id, 'x');
    });

    test('getAllKeys returns the stored keys as strings', () async {
      await service.save('k1', Fixtures.dhikr(id: 'k1'));
      await service.save('k2', Fixtures.dhikr(id: 'k2'));

      final result = await service.getAllKeys();

      expect(result.asOk.value, ['k1', 'k2']);
    });

    test('exists reports key presence', () async {
      await service.save('present', Fixtures.dhikr(id: 'present'));

      expect((await service.exists('present')).asOk.value, isTrue);
      expect((await service.exists('absent')).asOk.value, isFalse);
    });

    test('count and isEmpty reflect the box contents', () async {
      expect((await service.count()).asOk.value, 0);
      expect((await service.isEmpty()).asOk.value, isTrue);

      await service.save('a', Fixtures.dhikr(id: 'a'));

      expect((await service.count()).asOk.value, 1);
      expect((await service.isEmpty()).asOk.value, isFalse);
    });

    test('delete removes a single key and is Ok for unknown keys', () async {
      await service.save('a', Fixtures.dhikr(id: 'a'));
      await service.save('b', Fixtures.dhikr(id: 'b'));

      expect(await service.delete('a'), isA<Ok<void>>());
      expect(await service.delete('nope'), isA<Ok<void>>());
      expect((await service.getAllKeys()).asOk.value, ['b']);
    });

    test('deleteMany removes every given key', () async {
      await service.saveAll({
        'a': Fixtures.dhikr(id: 'a'),
        'b': Fixtures.dhikr(id: 'b'),
        'c': Fixtures.dhikr(id: 'c'),
      });

      final result = await service.deleteMany(['a', 'c']);

      expect(result, isA<Ok<void>>());
      expect((await service.getAllKeys()).asOk.value, ['b']);
    });

    test('clear empties the box', () async {
      await service.saveAll({
        'a': Fixtures.dhikr(id: 'a'),
        'b': Fixtures.dhikr(id: 'b'),
      });

      final result = await service.clear();

      expect(result, isA<Ok<void>>());
      expect((await service.isEmpty()).asOk.value, isTrue);
    });

    test('nullable Dhikr fields survive a round-trip', () async {
      final dhikr = Fixtures.dhikr(
        id: 'full',
        groupId: 'g1',
        groupDisplayName: 'Tesbihat',
        arabic: 'سُبْحَانَ اللّٰهِ',
        meaning: 'Glory be to Allah',
        benefit: 'Peace',
      );
      await service.save('full', dhikr);
      await service.save('bare', Fixtures.dhikr(id: 'bare'));

      final full = (await service.getById('full')).asOk.value!;
      final bare = (await service.getById('bare')).asOk.value!;

      expect(full.groupId, 'g1');
      expect(full.groupDisplayName, 'Tesbihat');
      expect(full.arabic, 'سُبْحَانَ اللّٰهِ');
      expect(full.meaning, 'Glory be to Allah');
      expect(full.benefit, 'Peace');
      expect(full.day, Fixtures.fixedDate);
      expect(bare.groupId, isNull);
      expect(bare.arabic, isNull);
    });

    test('values persist across a close and reopen of the box', () async {
      await service.save('persisted', Fixtures.dhikr(id: 'persisted'));
      await service.close();

      final reopened = HiveService<Dhikr>('dhikrs_test');
      final result = await reopened.getById('persisted');

      expect(result.asOk.value?.id, 'persisted');
    });
  });

  group('HiveService<Prayer>', () {
    late HiveService<Prayer> service;

    setUp(() {
      service = HiveService<Prayer>('prayers_test');
    });

    test(
      'a Prayer with a nested PrayerTimes map round-trips through the adapters',
      () async {
        final prayer = Fixtures.prayer(
          from: DateTime(2026, 3, 15),
          days: 3,
          year: 2026,
        ).copyWith(latitude: 41.01, longitude: 28.97);

        await service.save(prayer.id, prayer);
        final restored = (await service.getById(prayer.id)).asOk.value!;

        expect(restored.id, 'prayer_2026_9541');
        expect(restored.userId, 'uid-1');
        expect(restored.year, 2026);
        expect(restored.districtId, '9541');
        expect(restored.city, 'İstanbul');
        expect(restored.country, 'Türkiye');
        expect(restored.latitude, 41.01);
        expect(restored.longitude, 28.97);
        expect(restored.prayerTimes.keys, [
          '2026-03-15',
          '2026-03-16',
          '2026-03-17',
        ]);
        final day2 = restored.getPrayerTimesForDate('2026-03-16')!;
        expect(day2.fajr, DateTime(2026, 3, 16, 5));
        expect(day2.sunrise, DateTime(2026, 3, 16, 6));
        expect(day2.dhuhr, DateTime(2026, 3, 16, 13));
        expect(day2.asr, DateTime(2026, 3, 16, 16));
        expect(day2.maghrib, DateTime(2026, 3, 16, 19));
        expect(day2.isha, DateTime(2026, 3, 16, 21));
      },
    );

    test('a Prayer with null coordinates and empty times round-trips', () async {
      const prayer = Prayer(
        id: 'prayer_2026_1',
        userId: 'u',
        year: 2026,
        districtId: '1',
        city: 'c',
        country: 'co',
        prayerTimes: {},
      );

      await service.save(prayer.id, prayer);
      final restored = (await service.getById(prayer.id)).asOk.value!;

      expect(restored.latitude, isNull);
      expect(restored.longitude, isNull);
      expect(restored.prayerTimes, isEmpty);
    });
  });
}
