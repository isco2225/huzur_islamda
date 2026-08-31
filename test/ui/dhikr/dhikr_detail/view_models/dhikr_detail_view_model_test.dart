import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeDhikrRepository dhikrRepository;
  late FakeAuthRepository authRepository;
  late FakeNotificationRepository notificationRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late DhikrUseCase dhikrUseCase;
  late DhikrDetailViewModel viewModel;

  /// In-memory dhikr store served through the repository's per-id hook.
  late Map<String, Dhikr> store;

  DhikrDetailViewModel build({
    String initialDhikrId = 'dhikr-1',
    List<String>? groupDhikrIds,
  }) {
    return DhikrDetailViewModel(
      dhikrRepository: dhikrRepository,
      dhikrUseCase: dhikrUseCase,
      initialDhikrId: initialDhikrId,
      groupDhikrIds: groupDhikrIds,
    );
  }

  setUp(() {
    store = {'dhikr-1': Fixtures.dhikr(currentCount: 5, targetCount: 33)};
    dhikrRepository = FakeDhikrRepository();
    dhikrRepository.onGetDhikrLocally = (id) async => Ok(store[id]);
    dhikrRepository.onUpdateDhikrLocally = (id, dhikr) async {
      store[id] = dhikr;
      return const Ok(null);
    };
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    notificationRepository = FakeNotificationRepository();
    connectivityUseCase = FakeConnectivityUseCase();
    dhikrUseCase = DhikrUseCase(
      dhikrRepository: dhikrRepository,
      connectivityUseCase: connectivityUseCase,
      authRepository: authRepository,
      notificationRepository: notificationRepository,
    );
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('loadDhikr (fired from the constructor)', () {
    test('loads the initial dhikr into currentDhikr', () async {
      await pumpEventQueue();

      expect(viewModel.loadDhikr.completed.value, isTrue);
      expect(viewModel.currentDhikr.value?.id, 'dhikr-1');
      expect(dhikrRepository.calls, ['getDhikrLocally(dhikrId=dhikr-1)']);
    });

    test('leaves currentDhikr null when the dhikr does not exist', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'missing');
      await pumpEventQueue();

      expect(viewModel.currentDhikr.value, isNull);
      expect(viewModel.loadDhikr.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      viewModel.dispose();
      final exception = Exception('hive');
      dhikrRepository.onGetDhikrLocally = (_) async => Error<Dhikr?>(exception);
      viewModel = build();
      await pumpEventQueue();

      expect(viewModel.loadDhikr.error.value, isTrue);
      expect(viewModel.loadDhikr.result.value!.asError.error, same(exception));
      expect(viewModel.currentDhikr.value, isNull);
    });
  });

  group('progress and remainingCount', () {
    test('are 0 before a dhikr is loaded', () async {
      viewModel.dispose();
      // The constructor's load yields at its first await, so synchronously
      // after construction nothing is loaded yet.
      viewModel = build();

      expect(viewModel.currentDhikr.value, isNull);
      expect(viewModel.progress, 0.0);
      expect(viewModel.remainingCount, 0);
      await pumpEventQueue();
    });

    test('are 0 when the dhikr could not be found', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'missing');
      await pumpEventQueue();

      expect(viewModel.progress, 0.0);
      expect(viewModel.remainingCount, 0);
    });

    test('reflect the loaded dhikr', () async {
      await pumpEventQueue();

      expect(viewModel.progress, closeTo(5 / 33, 1e-9));
      expect(viewModel.remainingCount, 28);
    });

    test('progress is 0 and remainingCount 0 when targetCount is 0', () async {
      viewModel.dispose();
      store['zero'] = Fixtures.dhikr(id: 'zero', targetCount: 0, currentCount: 3);
      viewModel = build(initialDhikrId: 'zero');
      await pumpEventQueue();

      expect(viewModel.progress, 0.0);
      expect(viewModel.remainingCount, 0);
    });

    test('progress is clamped to 1 and remainingCount to 0 when over target', () async {
      viewModel.dispose();
      store['over'] = Fixtures.dhikr(id: 'over', targetCount: 10, currentCount: 15);
      viewModel = build(initialDhikrId: 'over');
      await pumpEventQueue();

      expect(viewModel.progress, 1.0);
      expect(viewModel.remainingCount, 0);
    });
  });

  group('incrementCount', () {
    test('persists currentCount + 1 with isSynced false and updates state', () async {
      await pumpEventQueue();

      await viewModel.incrementCount.execute();

      expect(dhikrRepository.updatedDhikrs, hasLength(1));
      final saved = dhikrRepository.updatedDhikrs.single;
      expect(saved.currentCount, 6);
      expect(saved.isSynced, isFalse);
      expect(saved.isCompleted, isFalse);
      expect(dhikrRepository.calls.last, 'updateDhikrLocally(dhikrId=dhikr-1, isSynced=false)');
      expect(viewModel.currentDhikr.value?.currentCount, 6);
      expect(viewModel.showPaywall.value, isFalse);
      expect(notificationRepository.calls, isEmpty);
    });

    test('errors when no dhikr is loaded', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'missing');
      await pumpEventQueue();

      await viewModel.incrementCount.execute();

      expect(viewModel.incrementCount.error.value, isTrue);
      expect(dhikrRepository.updatedDhikrs, isEmpty);
    });

    test(
      'marks completion when reaching target, shows the paywall and cancels '
      "today's reminder through the real DhikrUseCase when all are complete",
      () async {
        viewModel.dispose();
        store['almost'] = Fixtures.dhikr(id: 'almost', targetCount: 33, currentCount: 32);
        // The use case reads today's dhikrs to decide whether to cancel.
        dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
          Fixtures.dhikr(id: 'almost', targetCount: 33, currentCount: 33, isCompleted: true),
        ]);
        viewModel = build(initialDhikrId: 'almost');
        await pumpEventQueue();

        await viewModel.incrementCount.execute();

        final saved = dhikrRepository.updatedDhikrs.single;
        expect(saved.currentCount, 33);
        expect(saved.isCompleted, isTrue);
        expect(viewModel.currentDhikr.value?.isCompleted, isTrue);
        expect(viewModel.showPaywall.value, isTrue);
        expect(notificationRepository.calls, ['cancelTodayDhikrNotifications(userId=uid-1)']);
      },
    );

    test('does not cancel the reminder while another dhikr is incomplete', () async {
      viewModel.dispose();
      store['almost'] = Fixtures.dhikr(id: 'almost', targetCount: 33, currentCount: 32);
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(id: 'almost', targetCount: 33, currentCount: 33, isCompleted: true),
        Fixtures.dhikr(id: 'other', targetCount: 33, currentCount: 1),
      ]);
      viewModel = build(initialDhikrId: 'almost');
      await pumpEventQueue();

      await viewModel.incrementCount.execute();

      expect(notificationRepository.calls, isEmpty);
      expect(viewModel.incrementCount.completed.value, isTrue);
    });

    test('shows the paywall only on the first completion', () async {
      viewModel.dispose();
      store['almost'] = Fixtures.dhikr(id: 'almost', targetCount: 33, currentCount: 32);
      viewModel = build(initialDhikrId: 'almost');
      await pumpEventQueue();

      await viewModel.incrementCount.execute();
      expect(viewModel.showPaywall.value, isTrue);

      // The view consumed the trigger; another increment past the target
      // must not raise it again.
      viewModel.showPaywall.value = false;
      await viewModel.incrementCount.execute();

      expect(viewModel.currentDhikr.value?.currentCount, 34);
      expect(viewModel.showPaywall.value, isFalse);
    });

    test('propagates an updateDhikrLocally error without touching state', () async {
      await pumpEventQueue();
      final exception = Exception('hive');
      dhikrRepository.onUpdateDhikrLocally = (_, __) async =>
          Error<void>(exception);

      await viewModel.incrementCount.execute();

      expect(viewModel.incrementCount.error.value, isTrue);
      expect(viewModel.incrementCount.result.value!.asError.error, same(exception));
      expect(viewModel.currentDhikr.value?.currentCount, 5);
    });
  });

  group('decrementCount', () {
    test('persists currentCount - 1 with isSynced false', () async {
      await pumpEventQueue();

      await viewModel.decrementCount.execute();

      final saved = dhikrRepository.updatedDhikrs.single;
      expect(saved.currentCount, 4);
      expect(saved.isSynced, isFalse);
      expect(viewModel.currentDhikr.value?.currentCount, 4);
      expect(viewModel.decrementCount.completed.value, isTrue);
    });

    test('errors at 0 without a repository call', () async {
      viewModel.dispose();
      store['zero'] = Fixtures.dhikr(id: 'zero', currentCount: 0);
      viewModel = build(initialDhikrId: 'zero');
      await pumpEventQueue();

      await viewModel.decrementCount.execute();

      expect(viewModel.decrementCount.error.value, isTrue);
      expect(
        viewModel.decrementCount.result.value!.asError.error.toString(),
        contains("Sayı 0'dan küçük olamaz"),
      );
      expect(dhikrRepository.updatedDhikrs, isEmpty);
    });

    test('errors when no dhikr is loaded', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'missing');
      await pumpEventQueue();

      await viewModel.decrementCount.execute();

      expect(viewModel.decrementCount.error.value, isTrue);
      expect(
        viewModel.decrementCount.result.value!.asError.error.toString(),
        contains('Zikir yüklenmedi'),
      );
    });

    test('un-completes a dhikr that drops below its target', () async {
      viewModel.dispose();
      store['done'] = Fixtures.dhikr(
        id: 'done',
        targetCount: 10,
        currentCount: 10,
        isCompleted: true,
      );
      viewModel = build(initialDhikrId: 'done');
      await pumpEventQueue();

      await viewModel.decrementCount.execute();

      expect(dhikrRepository.updatedDhikrs.single.isCompleted, isFalse);
    });
  });

  group('resetCount', () {
    test('persists currentCount 0, isCompleted false and isSynced false', () async {
      viewModel.dispose();
      store['done'] = Fixtures.dhikr(
        id: 'done',
        targetCount: 10,
        currentCount: 10,
        isCompleted: true,
        isSynced: true,
      );
      viewModel = build(initialDhikrId: 'done');
      await pumpEventQueue();

      await viewModel.resetCount.execute();

      final saved = dhikrRepository.updatedDhikrs.single;
      expect(saved.currentCount, 0);
      expect(saved.isCompleted, isFalse);
      expect(saved.isSynced, isFalse);
      expect(viewModel.currentDhikr.value?.currentCount, 0);
      expect(viewModel.remainingCount, 10);
    });

    test('errors when no dhikr is loaded', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'missing');
      await pumpEventQueue();

      await viewModel.resetCount.execute();

      expect(viewModel.resetCount.error.value, isTrue);
    });
  });

  group('deleteDhikr (real DhikrUseCase)', () {
    test('deletes remotely then locally and nulls currentDhikr', () async {
      await pumpEventQueue();

      await viewModel.deleteDhikr.execute();

      expect(
        dhikrRepository.calls,
        containsAllInOrder([
          'deleteDhikrFromFirestore(dhikrId=dhikr-1, userId=uid-1)',
          'deleteDhikrLocally(dhikrId=dhikr-1)',
        ]),
      );
      expect(viewModel.currentDhikr.value, isNull);
      expect(viewModel.deleteDhikr.completed.value, isTrue);
    });

    test('fails with ConnectivityNoConnection when offline and keeps the dhikr', () async {
      await pumpEventQueue();
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.deleteDhikr.execute();

      expect(viewModel.deleteDhikr.error.value, isTrue);
      expect(
        viewModel.deleteDhikr.result.value!.asError.error,
        isA<ConnectivityNoConnection>(),
      );
      expect(viewModel.currentDhikr.value, isNotNull);
      expect(dhikrRepository.calls, isNot(contains('deleteDhikrLocally(dhikrId=dhikr-1)')));
    });
  });

  group('group mode', () {
    setUp(() {
      store
        ..['g-a'] = Fixtures.dhikr(
          id: 'g-a',
          groupId: 'grp',
          targetCount: 33,
          currentCount: 33,
          isCompleted: true,
        )
        ..['g-b'] = Fixtures.dhikr(
          id: 'g-b',
          groupId: 'grp',
          targetCount: 33,
          currentCount: 32,
        )
        ..['g-c'] = Fixtures.dhikr(
          id: 'g-c',
          groupId: 'grp',
          targetCount: 33,
          currentCount: 0,
        );
    });

    test('loads the first incomplete dhikr of the group', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'g-a', groupDhikrIds: ['g-a', 'g-b', 'g-c']);
      await pumpEventQueue();

      expect(viewModel.currentDhikr.value?.id, 'g-b');
    });

    test('falls back to the initial dhikr when every member is complete', () async {
      viewModel.dispose();
      store['g-b'] = store['g-b']!.copyWith(currentCount: 33, isCompleted: true);
      store['g-c'] = store['g-c']!.copyWith(currentCount: 33, isCompleted: true);
      viewModel = build(initialDhikrId: 'g-a', groupDhikrIds: ['g-a', 'g-b', 'g-c']);
      await pumpEventQueue();

      expect(viewModel.currentDhikr.value?.id, 'g-a');
    });

    test('advances to the next incomplete dhikr after completing the current one', () async {
      viewModel.dispose();
      viewModel = build(initialDhikrId: 'g-a', groupDhikrIds: ['g-a', 'g-b', 'g-c']);
      await pumpEventQueue();
      expect(viewModel.currentDhikr.value?.id, 'g-b');

      await viewModel.incrementCount.execute();

      expect(dhikrRepository.updatedDhikrs.single.id, 'g-b');
      expect(dhikrRepository.updatedDhikrs.single.isCompleted, isTrue);
      expect(viewModel.currentDhikr.value?.id, 'g-c');
      expect(viewModel.currentDhikr.value?.currentCount, 0);
      expect(viewModel.showPaywall.value, isTrue);
      expect(viewModel.incrementCount.completed.value, isTrue);
    });

    test('stays on the last dhikr when it completes with no incomplete successor', () async {
      viewModel.dispose();
      store['g-c'] = store['g-c']!.copyWith(currentCount: 32);
      viewModel = build(initialDhikrId: 'g-c', groupDhikrIds: ['g-a', 'g-b', 'g-c']);
      await pumpEventQueue();
      // g-b is the first incomplete member, so the view model opened it.
      expect(viewModel.currentDhikr.value?.id, 'g-b');

      await viewModel.incrementCount.execute();
      expect(viewModel.currentDhikr.value?.id, 'g-c');

      await viewModel.incrementCount.execute();

      expect(viewModel.currentDhikr.value?.id, 'g-c');
      expect(viewModel.currentDhikr.value?.currentCount, 33);
    });
  });

  test('dispose does not throw', () async {
    await pumpEventQueue();
    expect(viewModel.dispose, returnsNormally);
    viewModel = build();
  });
}
