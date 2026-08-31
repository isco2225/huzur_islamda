import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakeDhikrRepository dhikrRepository;
  late FakeConnectivityUseCase connectivity;
  late FakeAuthRepository authRepository;
  late FakeNotificationRepository notificationRepository;
  late DhikrUseCase useCase;

  setUp(() {
    dhikrRepository = FakeDhikrRepository();
    connectivity = FakeConnectivityUseCase(type: ConnectivityEnum.wifi);
    authRepository = FakeAuthRepository(auth: Fixtures.auth(uid: 'uid-1'));
    notificationRepository = FakeNotificationRepository();
    useCase = DhikrUseCase(
      dhikrRepository: dhikrRepository,
      connectivityUseCase: connectivity,
      authRepository: authRepository,
      notificationRepository: notificationRepository,
    );
  });

  group('DhikrUseCase.syncDhikrs', () {
    test('returns Ok and touches nothing when there is no connection', () async {
      connectivity.type = ConnectivityEnum.none;

      final result = await useCase.syncDhikrs();

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls, isEmpty);
      expect(useCase.deviceHasConnection.value, isFalse);
    });

    test('keeps the previous connection state when the check fails', () async {
      connectivity.connectionTypeResult = Error(Exception('unavailable'));

      final result = await useCase.syncDhikrs();

      // Initial state is "no connection", so the sync is skipped.
      expect(result, isA<Ok<void>>());
      expect(useCase.deviceHasConnection.value, isFalse);
      expect(dhikrRepository.calls, isEmpty);
    });

    test('returns an error when the uid is empty', () async {
      authRepository.authNotifier.value = Auth.empty();

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error.toString(), contains('User ID is empty'));
      expect(dhikrRepository.calls, isEmpty);
      expect(useCase.deviceHasConnection.value, isTrue);
    });

    test('propagates an error from getUnsyncedDhikrs', () async {
      final exception = Exception('hive read');
      dhikrRepository.getUnsyncedDhikrsResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(dhikrRepository.calls, ['getUnsyncedDhikrs()']);
    });

    test(
      'pushes unsynced dhikrs to Firestore and marks each as synced',
      () async {
        dhikrRepository.getUnsyncedDhikrsResult = Ok([
          Fixtures.dhikr(id: 'a', isSynced: false),
          Fixtures.dhikr(id: 'b', isSynced: false),
        ]);

        final result = await useCase.syncDhikrs();

        expect(result, isA<Ok<void>>());
        expect(dhikrRepository.calls, [
          'getUnsyncedDhikrs()',
          'syncDhikrsToFirestore(userId=uid-1)',
          'updateDhikrLocally(dhikrId=a, isSynced=true)',
          'updateDhikrLocally(dhikrId=b, isSynced=true)',
        ]);
        expect(
          dhikrRepository.updatedDhikrs.map((d) => d.isSynced),
          everyElement(isTrue),
        );
        // The count comparison branch is not reached.
        expect(
          dhikrRepository.calls,
          isNot(contains('getFirestoreDhikrsCount(userId=uid-1)')),
        );
      },
    );

    test('does not mark dhikrs synced when the Firestore push fails', () async {
      final exception = Exception('firestore');
      dhikrRepository.getUnsyncedDhikrsResult = Ok([Fixtures.dhikr(id: 'a')]);
      dhikrRepository.syncDhikrsToFirestoreResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(dhikrRepository.updatedDhikrs, isEmpty);
    });

    test('treats a null unsynced list like an empty one', () async {
      dhikrRepository.getUnsyncedDhikrsResult = const Ok(null);
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(0);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls, [
        'getUnsyncedDhikrs()',
        'getFirestoreDhikrsCount(userId=uid-1)',
        'getDhikrsCountLocally()',
      ]);
    });

    test('returns an error when the remote count is null', () async {
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(null);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        contains('No firestore dhikrs count found'),
      );
      expect(
        dhikrRepository.calls,
        isNot(contains('getDhikrsCountLocally()')),
      );
    });

    test('propagates an error from getFirestoreDhikrsCount', () async {
      final exception = Exception('count');
      dhikrRepository.getFirestoreDhikrsCountResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('propagates an error from getDhikrsCountLocally', () async {
      final exception = Exception('local count');
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(2);
      dhikrRepository.getDhikrsCountLocallyResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('pushes to Firestore when local count is greater', () async {
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(1);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(3);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls.last, 'syncDhikrsToFirestore(userId=uid-1)');
      expect(
        dhikrRepository.calls,
        isNot(contains('syncDhikrsToLocally(userId=uid-1)')),
      );
    });

    test('propagates a push failure when local count is greater', () async {
      final exception = Exception('push');
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(1);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(3);
      dhikrRepository.syncDhikrsToFirestoreResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('pulls from Firestore when local count is smaller', () async {
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(3);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(1);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls.last, 'syncDhikrsToLocally(userId=uid-1)');
      expect(
        dhikrRepository.calls,
        isNot(contains('syncDhikrsToFirestore(userId=uid-1)')),
      );
    });

    test('propagates a pull failure when local count is smaller', () async {
      final exception = Exception('pull');
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(3);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(1);
      dhikrRepository.syncDhikrsToLocallyResult = Error(exception);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('does nothing when the counts are equal', () async {
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(2);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(2);

      final result = await useCase.syncDhikrs();

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls, [
        'getUnsyncedDhikrs()',
        'getFirestoreDhikrsCount(userId=uid-1)',
        'getDhikrsCountLocally()',
      ]);
    });
  });

  group('DhikrUseCase.cancelTodayDhikrReminderIfAllCompleted', () {
    test('returns an error without touching repositories when uid is empty', () async {
      authRepository.authNotifier.value = Auth.empty();

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Error<void>>());
      expect(dhikrRepository.calls, isEmpty);
      expect(notificationRepository.calls, isEmpty);
    });

    test('queries dhikrs for today', () async {
      final now = DateTime.now();
      final todayKey = Prayer.formatDate(now);

      await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(dhikrRepository.calls, [
        'getAllDhikrsByDateLocally(date=$todayKey)',
      ]);
    });

    test('returns Ok without cancelling when there are no dhikrs', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = const Ok(<Dhikr>[]);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, isEmpty);
    });

    test('treats a null dhikr list like an empty one', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = const Ok(null);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, isEmpty);
    });

    test('cancels the reminder when every dhikr is completed', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(id: 'a', isCompleted: true),
        Fixtures.dhikr(id: 'b', currentCount: 33, targetCount: 33),
      ]);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, [
        'cancelTodayDhikrNotifications(userId=uid-1)',
      ]);
    });

    test('keeps the reminder when at least one dhikr is incomplete', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(id: 'a', isCompleted: true),
        Fixtures.dhikr(id: 'b', currentCount: 5, targetCount: 33),
      ]);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, isEmpty);
    });

    test('ignores deleted dhikrs when deciding completeness', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(id: 'a', isCompleted: true),
        Fixtures.dhikr(id: 'b', currentCount: 0, isDeleted: true),
      ]);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, [
        'cancelTodayDhikrNotifications(userId=uid-1)',
      ]);
    });

    test('propagates a failure to load dhikrs', () async {
      final exception = Exception('load');
      dhikrRepository.getAllDhikrsByDateLocallyResult = Error(exception);

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('propagates a failure to cancel the notification', () async {
      final exception = Exception('cancel');
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(isCompleted: true),
      ]);
      notificationRepository.cancelTodayDhikrNotificationsResult = Error(
        exception,
      );

      final result = await useCase.cancelTodayDhikrReminderIfAllCompleted();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });
  });

  group('DhikrUseCase.cancelTodayDhikrCreationReminder', () {
    test('returns an error when uid is empty', () async {
      authRepository.authNotifier.value = Auth.empty();

      final result = await useCase.cancelTodayDhikrCreationReminder();

      expect(result, isA<Error<void>>());
      expect(notificationRepository.calls, isEmpty);
    });

    test('cancels today\'s creation reminder for the current user', () async {
      final result = await useCase.cancelTodayDhikrCreationReminder();

      expect(result, isA<Ok<void>>());
      expect(notificationRepository.calls, [
        'cancelTodayDhikrCreationReminderNotification(userId=uid-1)',
      ]);
    });

    test('propagates a repository error', () async {
      final exception = Exception('cancel');
      notificationRepository.cancelTodayDhikrCreationReminderNotificationResult =
          Error(exception);

      final result = await useCase.cancelTodayDhikrCreationReminder();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });
  });

  group('DhikrUseCase.deleteDhikr', () {
    test('returns an error when uid is empty', () async {
      authRepository.authNotifier.value = Auth.empty();

      final result = await useCase.deleteDhikr(dhikrId: 'a');

      expect(result, isA<Error<void>>());
      expect(connectivity.calls, isEmpty);
      expect(dhikrRepository.calls, isEmpty);
    });

    test('returns ConnectivityNoConnection when offline', () async {
      connectivity.type = ConnectivityEnum.none;

      final result = await useCase.deleteDhikr(dhikrId: 'a');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<ConnectivityNoConnection>());
      expect(dhikrRepository.calls, isEmpty);
    });

    test('deletes remotely then locally when online', () async {
      connectivity.type = ConnectivityEnum.mobile;

      final result = await useCase.deleteDhikr(dhikrId: 'a');

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls, [
        'deleteDhikrFromFirestore(dhikrId=a, userId=uid-1)',
        'deleteDhikrLocally(dhikrId=a)',
      ]);
    });

    test('does not delete locally when the remote delete fails', () async {
      final exception = Exception('remote');
      dhikrRepository.deleteDhikrFromFirestoreResult = Error(exception);

      final result = await useCase.deleteDhikr(dhikrId: 'a');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(dhikrRepository.calls, [
        'deleteDhikrFromFirestore(dhikrId=a, userId=uid-1)',
      ]);
    });

    test('propagates a local delete failure', () async {
      final exception = Exception('local');
      dhikrRepository.deleteDhikrLocallyResult = Error(exception);

      final result = await useCase.deleteDhikr(dhikrId: 'a');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });
  });

  group('DhikrUseCase.deleteGroup', () {
    test('returns an error for an empty id list', () async {
      final result = await useCase.deleteGroup(groupIds: const []);

      expect(result, isA<Error<void>>());
      expect(result.asError.error.toString(), contains('No group IDs'));
      expect(dhikrRepository.calls, isEmpty);
    });

    test('deletes every dhikr in order', () async {
      final result = await useCase.deleteGroup(groupIds: const ['a', 'b']);

      expect(result, isA<Ok<void>>());
      expect(dhikrRepository.calls, [
        'deleteDhikrFromFirestore(dhikrId=a, userId=uid-1)',
        'deleteDhikrLocally(dhikrId=a)',
        'deleteDhikrFromFirestore(dhikrId=b, userId=uid-1)',
        'deleteDhikrLocally(dhikrId=b)',
      ]);
    });

    test('stops at the first failing dhikr', () async {
      final exception = Exception('b failed');
      dhikrRepository.onDeleteDhikrFromFirestore = (dhikrId) async =>
          dhikrId == 'b' ? Error(exception) : const Ok(null);

      final result = await useCase.deleteGroup(groupIds: const ['a', 'b', 'c']);

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(dhikrRepository.calls, [
        'deleteDhikrFromFirestore(dhikrId=a, userId=uid-1)',
        'deleteDhikrLocally(dhikrId=a)',
        'deleteDhikrFromFirestore(dhikrId=b, userId=uid-1)',
      ]);
    });

    test('returns ConnectivityNoConnection when offline', () async {
      connectivity.type = ConnectivityEnum.none;

      final result = await useCase.deleteGroup(groupIds: const ['a']);

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<ConnectivityNoConnection>());
    });
  });
}
