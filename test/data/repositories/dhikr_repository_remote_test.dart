import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHiveService<Dhikr> hive;
  late FakeFirestoreDhikrService firestore;
  late DhikrRepositoryRemote repository;

  List<String> ids(Iterable<Dhikr> dhikrs) => dhikrs.map((d) => d.id).toList();

  setUp(() {
    hive = FakeHiveService<Dhikr>(boxName: Dhikr.boxName);
    firestore = FakeFirestoreDhikrService();
    repository = DhikrRepositoryRemote(
      hiveService: hive,
      firestoreDhikrService: firestore,
    );
  });

  group('loadAllDhikrsLocally', () {
    test('replaces the notifier with everything stored in Hive', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      hive.store['b'] = Fixtures.dhikr(id: 'b');
      var notifications = 0;
      repository.dhikrsLocally.addListener(() => notifications++);

      final result = await repository.loadAllDhikrsLocally();

      expect(result, isA<Ok<void>>());
      expect(ids(repository.dhikrsLocally.value), ['a', 'b']);
      // The implementation first assigns [] then the loaded list.
      expect(notifications, 2);
    });

    test('leaves the notifier untouched and propagates a Hive error', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      await repository.loadAllDhikrsLocally();
      hive.alwaysFail.add('getAll');

      final result = await repository.loadAllDhikrsLocally();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(hive.failure));
      expect(ids(repository.dhikrsLocally.value), ['a']);
    });
  });

  group('saveDhikrLocally', () {
    test('persists under dhikr.id and prepends to the notifier', () async {
      final first = Fixtures.dhikr(id: 'first');
      final second = Fixtures.dhikr(id: 'second');

      await repository.saveDhikrLocally(dhikr: first);
      final result = await repository.saveDhikrLocally(dhikr: second);

      expect(result, isA<Ok<Dhikr>>());
      expect(result.asOk.value, same(second));
      expect(hive.savedKeys, ['first', 'second']);
      expect(ids(repository.dhikrsLocally.value), ['second', 'first']);
    });

    test('does not touch the notifier when Hive fails', () async {
      hive.alwaysFail.add('save');

      final result = await repository.saveDhikrLocally(
        dhikr: Fixtures.dhikr(id: 'x'),
      );

      expect(result, isA<Error<Dhikr>>());
      expect(repository.dhikrsLocally.value, isEmpty);
    });
  });

  group('getDhikrLocally', () {
    test('returns the stored dhikr or null', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');

      expect((await repository.getDhikrLocally(dhikrId: 'a')).asOk.value?.id, 'a');
      expect((await repository.getDhikrLocally(dhikrId: 'zz')).asOk.value, isNull);
    });

    test('propagates a Hive error', () async {
      hive.alwaysFail.add('getById');

      final result = await repository.getDhikrLocally(dhikrId: 'a');

      expect(result, isA<Error<Dhikr?>>());
    });
  });

  group('getAllDhikrsByDateLocally', () {
    test('matches on the calendar day regardless of time of day', () async {
      hive.store['morning'] = Fixtures.dhikr(
        id: 'morning',
        day: DateTime(2026, 3, 15, 6, 15),
      );
      hive.store['night'] = Fixtures.dhikr(
        id: 'night',
        day: DateTime(2026, 3, 15, 23, 59),
      );
      hive.store['next'] = Fixtures.dhikr(
        id: 'next',
        day: DateTime(2026, 3, 16, 0, 0),
      );

      final result = await repository.getAllDhikrsByDateLocally(
        date: DateTime(2026, 3, 15, 18, 42, 7),
      );

      expect(result, isA<Ok<List<Dhikr>?>>());
      expect(ids(result.asOk.value!), ['morning', 'night']);
    });

    test('returns Ok(null) when no dhikr exists for that day', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a', day: DateTime(2026, 3, 15));

      final result = await repository.getAllDhikrsByDateLocally(
        date: DateTime(2026, 3, 16),
      );

      expect(result, isA<Ok<List<Dhikr>?>>());
      expect(result.asOk.value, isNull);
    });

    test('propagates a Hive error', () async {
      hive.alwaysFail.add('getWithFilter');

      final result = await repository.getAllDhikrsByDateLocally(
        date: DateTime(2026, 3, 16),
      );

      expect(result, isA<Error<List<Dhikr>?>>());
    });
  });

  group('deleteDhikrLocally', () {
    test('removes the dhikr from Hive and from the notifier', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      hive.store['b'] = Fixtures.dhikr(id: 'b');
      await repository.loadAllDhikrsLocally();

      final result = await repository.deleteDhikrLocally(dhikrId: 'a');

      expect(result, isA<Ok<void>>());
      expect(hive.store.keys, ['b']);
      expect(ids(repository.dhikrsLocally.value), ['b']);
    });

    test('keeps the notifier when Hive fails', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      await repository.loadAllDhikrsLocally();
      hive.alwaysFail.add('delete');

      final result = await repository.deleteDhikrLocally(dhikrId: 'a');

      expect(result, isA<Error<void>>());
      expect(ids(repository.dhikrsLocally.value), ['a']);
    });
  });

  group('clearAllDhikrsLocally', () {
    test('empties Hive and the notifier', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      await repository.loadAllDhikrsLocally();

      final result = await repository.clearAllDhikrsLocally();

      expect(result, isA<Ok<void>>());
      expect(hive.store, isEmpty);
      expect(repository.dhikrsLocally.value, isEmpty);
    });

    test('keeps the notifier when Hive fails', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      await repository.loadAllDhikrsLocally();
      hive.alwaysFail.add('clear');

      final result = await repository.clearAllDhikrsLocally();

      expect(result, isA<Error<void>>());
      expect(ids(repository.dhikrsLocally.value), ['a']);
    });
  });

  group('updateDhikrLocally', () {
    Future<void> seedAbc() async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      hive.store['b'] = Fixtures.dhikr(id: 'b');
      hive.store['c'] = Fixtures.dhikr(id: 'c');
      await repository.loadAllDhikrsLocally();
    }

    test('persists the update and replaces the item exactly once', () async {
      await seedAbc();
      final updated = Fixtures.dhikr(id: 'b', currentCount: 7);

      final result = await repository.updateDhikrLocally(
        dhikrId: 'b',
        dhikr: updated,
      );

      expect(result, isA<Ok<void>>());
      expect(hive.store['b']!.currentCount, 7);
      final value = repository.dhikrsLocally.value;
      expect(value.where((d) => d.id == 'b').length, 1);
      expect(value.firstWhere((d) => d.id == 'b').currentCount, 7);
      expect(value.length, 3);
    });

    test(
      'keeps the updated item in place and does not mutate the previously '
      'published list',
      () async {
        await seedAbc();
        final before = repository.dhikrsLocally.value;

        await repository.updateDhikrLocally(
          dhikrId: 'b',
          dhikr: Fixtures.dhikr(id: 'b', currentCount: 7),
        );

        expect(ids(before), ['a', 'b', 'c']);
        expect(ids(repository.dhikrsLocally.value), ['a', 'b', 'c']);
      },
    );

    test('appends the item when it is not in the notifier yet', () async {
      await seedAbc();

      await repository.updateDhikrLocally(
        dhikrId: 'd',
        dhikr: Fixtures.dhikr(id: 'd'),
      );

      expect(ids(repository.dhikrsLocally.value), ['a', 'b', 'c', 'd']);
    });

    test('keeps the notifier when Hive fails', () async {
      await seedAbc();
      hive.alwaysFail.add('update');

      final result = await repository.updateDhikrLocally(
        dhikrId: 'b',
        dhikr: Fixtures.dhikr(id: 'b', currentCount: 7),
      );

      expect(result, isA<Error<void>>());
      expect(ids(repository.dhikrsLocally.value), ['a', 'b', 'c']);
      expect(hive.store['b']!.currentCount, 0);
    });
  });

  group('getUnsyncedDhikrs', () {
    test('returns only dhikrs with isSynced == false', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a', isSynced: true);
      hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);
      hive.store['c'] = Fixtures.dhikr(id: 'c', isSynced: false);

      final result = await repository.getUnsyncedDhikrs();

      expect(ids(result.asOk.value!), ['b', 'c']);
    });

    test('returns Ok(null) when everything is synced', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a', isSynced: true);

      final result = await repository.getUnsyncedDhikrs();

      expect(result, isA<Ok<List<Dhikr>?>>());
      expect(result.asOk.value, isNull);
    });

    test('propagates a Hive error', () async {
      hive.alwaysFail.add('getWithFilter');

      expect(await repository.getUnsyncedDhikrs(), isA<Error<List<Dhikr>?>>());
    });
  });

  group('syncDhikrsToFirestore', () {
    test('returns Ok and does not call Firestore when nothing is unsynced', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a', isSynced: true);

      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(firestore.saveDhikrsCalls, isEmpty);
    });

    test('returns Ok and does not call Firestore on an empty box', () async {
      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(firestore.saveDhikrsCalls, isEmpty);
    });

    test('sends exactly the unsynced dhikrs to Firestore', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a', isSynced: true);
      hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);
      hive.store['c'] = Fixtures.dhikr(id: 'c', isSynced: false);

      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(firestore.saveDhikrsCalls.length, 1);
      expect(firestore.saveDhikrsCalls.single.userId, 'uid-1');
      expect(ids(firestore.saveDhikrsCalls.single.dhikrs), ['b', 'c']);
    });

    test(
      'marks the pushed dhikrs as synced locally after a successful upload',
      () async {
        hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);
        hive.store['c'] = Fixtures.dhikr(id: 'c', isSynced: false);

        await repository.syncDhikrsToFirestore(userId: 'uid-1');

        expect(hive.store['b']!.isSynced, isTrue);
        expect(hive.store['c']!.isSynced, isTrue);
        expect((await repository.getUnsyncedDhikrs()).asOk.value, isNull);
      },
    );

    test('does not re-upload already synced dhikrs on the next sync', () async {
      hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);

      await repository.syncDhikrsToFirestore(userId: 'uid-1');
      await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(hive.store['b']!.isSynced, isTrue);
      expect(firestore.saveDhikrsCalls.length, 1);
    });

    test('marks synced items in the notifier without reordering', () async {
      await repository.saveDhikrLocally(
        dhikr: Fixtures.dhikr(id: 'a', isSynced: true),
      );
      await repository.saveDhikrLocally(
        dhikr: Fixtures.dhikr(id: 'b', isSynced: false),
      );
      final orderBefore = ids(repository.dhikrsLocally.value);

      await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(ids(repository.dhikrsLocally.value), orderBefore);
      expect(
        repository.dhikrsLocally.value.every((d) => d.isSynced),
        isTrue,
      );
    });

    test('still returns Ok when marking as synced fails locally', () async {
      hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);
      hive.alwaysFail.add('update');

      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(firestore.saveDhikrsCalls.length, 1);
    });

    test('propagates a Firestore failure', () async {
      hive.store['b'] = Fixtures.dhikr(id: 'b', isSynced: false);
      firestore.saveDhikrsResult = const Error(DhikrSaveFailed());

      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<DhikrSaveFailed>());
    });

    test('propagates a Hive failure without calling Firestore', () async {
      hive.alwaysFail.add('getWithFilter');

      final result = await repository.syncDhikrsToFirestore(userId: 'uid-1');

      expect(result, isA<Error<void>>());
      expect(firestore.saveDhikrsCalls, isEmpty);
    });
  });

  group('syncDhikrsToLocally', () {
    test('returns Ok and saves nothing when Firestore is empty', () async {
      final result = await repository.syncDhikrsToLocally(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(firestore.fetchAllDhikrsUserIds, ['uid-1']);
      expect(hive.savedKeys, isEmpty);
      expect(repository.dhikrsLocally.value, isEmpty);
    });

    test('saves each remote dhikr locally with isSynced set to true', () async {
      firestore.fetchAllDhikrsResult = Result.ok([
        Fixtures.dhikr(id: 'a', isSynced: false),
        Fixtures.dhikr(id: 'b', isSynced: false),
      ]);

      final result = await repository.syncDhikrsToLocally(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(hive.savedKeys, unorderedEquals(['a', 'b']));
      expect(hive.store.values.every((d) => d.isSynced), isTrue);
    });

    test(
      'keeps the remote (newest-first) order in the notifier',
      () async {
        firestore.fetchAllDhikrsResult = Result.ok([
          Fixtures.dhikr(id: 'newest'),
          Fixtures.dhikr(id: 'middle'),
          Fixtures.dhikr(id: 'oldest'),
        ]);

        await repository.syncDhikrsToLocally(userId: 'uid-1');

        expect(ids(repository.dhikrsLocally.value), [
          'newest',
          'middle',
          'oldest',
        ]);
      },
    );

    test('propagates a Firestore failure', () async {
      firestore.fetchAllDhikrsResult = const Error(DhikrFetchAllFailed());

      final result = await repository.syncDhikrsToLocally(userId: 'uid-1');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<DhikrFetchAllFailed>());
      expect(hive.savedKeys, isEmpty);
    });
  });

  group('getDhikrsByGroupId', () {
    test('returns the matching dhikrs in reversed key order', () async {
      hive.store['g-1'] = Fixtures.dhikr(id: 'g-1', groupId: 'grp');
      hive.store['g-2'] = Fixtures.dhikr(id: 'g-2', groupId: 'grp');
      hive.store['g-3'] = Fixtures.dhikr(id: 'g-3', groupId: 'grp');
      hive.store['other'] = Fixtures.dhikr(id: 'other', groupId: 'zzz');

      final result = await repository.getDhikrsByGroupId(groupId: 'grp');

      expect(result, isA<Ok<List<Dhikr>>>());
      expect(ids(result.asOk.value), ['g-3', 'g-2', 'g-1']);
    });

    test('returns Ok([]) for an unknown group', () async {
      hive.store['g-1'] = Fixtures.dhikr(id: 'g-1', groupId: 'grp');

      final result = await repository.getDhikrsByGroupId(groupId: 'nope');

      expect(result, isA<Ok<List<Dhikr>>>());
      expect(result.asOk.value, isEmpty);
    });

    test('propagates a Hive error', () async {
      hive.alwaysFail.add('getWithFilter');

      expect(
        await repository.getDhikrsByGroupId(groupId: 'grp'),
        isA<Error<List<Dhikr>>>(),
      );
    });
  });

  group('createGroupDhikrs', () {
    test('saves every dhikr and prepends each to the notifier', () async {
      final result = await repository.createGroupDhikrs(
        dhikrs: [
          Fixtures.dhikr(id: 'g-1', groupId: 'grp'),
          Fixtures.dhikr(id: 'g-2', groupId: 'grp'),
          Fixtures.dhikr(id: 'g-3', groupId: 'grp'),
        ],
      );

      expect(result, isA<Ok<void>>());
      expect(hive.savedKeys, ['g-1', 'g-2', 'g-3']);
      expect(ids(repository.dhikrsLocally.value), ['g-3', 'g-2', 'g-1']);
    });

    test('returns Ok for an empty list without touching Hive', () async {
      final result = await repository.createGroupDhikrs(dhikrs: const []);

      expect(result, isA<Ok<void>>());
      expect(hive.calls, isEmpty);
    });

    test(
      'aborts at the first failure and leaves the earlier writes in place '
      '(no rollback)',
      () async {
        hive.failWhen = (method, key) => method == 'save' && key == 'g-2';

        final result = await repository.createGroupDhikrs(
          dhikrs: [
            Fixtures.dhikr(id: 'g-1', name: 'Subhanallah', groupId: 'grp'),
            Fixtures.dhikr(id: 'g-2', name: 'Elhamdulillah', groupId: 'grp'),
            Fixtures.dhikr(id: 'g-3', name: 'Allahu Ekber', groupId: 'grp'),
          ],
        );

        expect(result, isA<Error<void>>());
        expect(
          result.asError.error.toString(),
          'Exception: Failed to save dhikr: Elhamdulillah',
        );
        // g-1 was written and stays; g-3 was never attempted.
        expect(hive.savedKeys, ['g-1']);
        expect(hive.store.keys, ['g-1']);
        expect(ids(repository.dhikrsLocally.value), ['g-1']);
      },
    );
  });

  group('Firestore pass-throughs', () {
    test('getAllDhikrsFromFirestore forwards the user id and result', () async {
      firestore.fetchAllDhikrsResult = Result.ok([Fixtures.dhikr(id: 'r')]);

      final result = await repository.getAllDhikrsFromFirestore(
        userId: 'uid-1',
      );

      expect(firestore.fetchAllDhikrsUserIds, ['uid-1']);
      expect(ids(result.asOk.value), ['r']);
    });

    test('getAllDhikrsFromFirestore propagates errors', () async {
      firestore.fetchAllDhikrsResult = const Error(DhikrFetchAllFailed());

      final result = await repository.getAllDhikrsFromFirestore(
        userId: 'uid-1',
      );

      expect(result, isA<Error<List<Dhikr>>>());
    });

    test('deleteDhikrFromFirestore forwards ids and returns the result', () async {
      final result = await repository.deleteDhikrFromFirestore(
        dhikrId: 'd',
        userId: 'uid-1',
      );

      expect(result, isA<Ok<void>>());
      expect(firestore.deleteDhikrCalls.single, (userId: 'uid-1', dhikrId: 'd'));
    });

    test('getFirestoreDhikrsCount forwards the count (possibly null)', () async {
      firestore.getDhikrsCountResult = const Ok(3);
      expect((await repository.getFirestoreDhikrsCount(userId: 'u')).asOk.value, 3);

      firestore.getDhikrsCountResult = const Ok(null);
      expect((await repository.getFirestoreDhikrsCount(userId: 'u')).asOk.value, isNull);

      firestore.getDhikrsCountResult = const Error(DhikrGetCountFailed());
      expect(
        await repository.getFirestoreDhikrsCount(userId: 'u'),
        isA<Error<int?>>(),
      );
    });

    test('getDhikrsCountLocally forwards the Hive count', () async {
      hive.store['a'] = Fixtures.dhikr(id: 'a');
      hive.store['b'] = Fixtures.dhikr(id: 'b');

      expect((await repository.getDhikrsCountLocally()).asOk.value, 2);

      hive.alwaysFail.add('count');
      expect(await repository.getDhikrsCountLocally(), isA<Error<int>>());
    });
  });
}
