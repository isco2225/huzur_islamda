import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class DhikrUseCase {
  DhikrUseCase({
    required DhikrRepository dhikrRepository,
    required ConnectivityUseCase connectivityUseCase,
    required AuthRepository authRepository,
    required NotificationRepository notificationRepository,
  }) : _dhikrRepository = dhikrRepository,
       _connectivityUseCase = connectivityUseCase,
       _authRepository = authRepository,
       _notificationRepository = notificationRepository;

  // LOGGER
  final _log = Logger('DhikrUseCase');

  final DhikrRepository _dhikrRepository;
  final ConnectivityUseCase _connectivityUseCase;
  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;

  // DOMAIN
  ValueListenable<Auth> get auth => _authRepository.auth;

  ValueListenable<bool> get deviceHasConnection => _deviceHasConnection;
  final ValueNotifier<bool> _deviceHasConnection = ValueNotifier<bool>(false);

  Future<Result<void>> syncDhikrs() async {
    // check network connection
    // check is there any unsynced dhikrs?
    // check is firestore dhikrs count is greater than locally dhikrs count?
    // if yes, sync to firestore
    // if no and not equal, sync to locally
    // if equal, do nothing
    await _updateDeviceHasConnection();
    if (_deviceHasConnection.value) {
      if (auth.value.uid.isEmpty) {
        _log.warning('User ID is empty, cannot sync dhikrs');
        return Result.error(const DhikrUserIdEmpty());
      }
      final userId = auth.value.uid;
      final unsyncedDhikrsResult = await _dhikrRepository.getUnsyncedDhikrs();
      switch (unsyncedDhikrsResult) {
        case Ok():
          final unsyncedDhikrs = unsyncedDhikrsResult.asOk.value;
          if (unsyncedDhikrs == null || unsyncedDhikrs.isEmpty) {
            _log.info('No unsynced dhikrs found');
            break;
          }
          _log.info('Found ${unsyncedDhikrs.length} unsynced dhikrs');
          // sync to firestore
          final firestoreResult = await _dhikrRepository.syncDhikrsToFirestore(
            userId: userId,
          );
          switch (firestoreResult) {
            case Ok():
              // The repository marks the pushed dhikrs as synced locally.
              _log.info(
                'Successfully synced ${unsyncedDhikrs.length} unsynced dhikrs to firestore',
              );
              return Result.ok(null);
            case Error():
              return Result.error(firestoreResult.asError.error);
          }
        case Error():
          return Result.error(unsyncedDhikrsResult.asError.error);
      }
      final firestoreDhikrsCountResult = await _dhikrRepository
          .getFirestoreDhikrsCount(userId: userId);
      switch (firestoreDhikrsCountResult) {
        case Ok():
          final firestoreDhikrsCount = firestoreDhikrsCountResult.asOk.value;
          if (firestoreDhikrsCount == null) {
            _log.info('No firestore dhikrs count found');
            return Result.error(const DhikrRemoteCountNotFound());
          }
          // get locally dhikrs count
          final locallyDhikrsCountResult = await _dhikrRepository
              .getDhikrsCountLocally();
          switch (locallyDhikrsCountResult) {
            case Ok():
              final locallyDhikrsCount = locallyDhikrsCountResult.asOk.value;
              if (locallyDhikrsCount > firestoreDhikrsCount) {
                final firestoreResult = await _dhikrRepository
                    .syncDhikrsToFirestore(userId: userId);
                switch (firestoreResult) {
                  case Ok():
                    _log.info(
                      'Successfully synced $firestoreDhikrsCount firestore dhikrs to locally',
                    );
                    break;
                  case Error():
                    _log.warning(
                      'Failed to sync $firestoreDhikrsCount firestore dhikrs to locally: ${firestoreResult.asError.error}',
                    );
                    return Result.error(firestoreResult.asError.error);
                }
              } else if (locallyDhikrsCount < firestoreDhikrsCount) {
                final locallyResult = await _dhikrRepository
                    .syncDhikrsToLocally(userId: userId);
                switch (locallyResult) {
                  case Ok():
                    _log.info(
                      'Successfully synced $locallyDhikrsCount locally dhikrs to firestore',
                    );
                    break;
                  case Error():
                    _log.warning(
                      'Failed to sync $locallyDhikrsCount locally dhikrs to firestore: ${locallyResult.asError.error}',
                    );
                    return Result.error(locallyResult.asError.error);
                }
              } else {
                _log.info('Dhikrs are equal');
                break;
              }
            case Error():
              return Result.error(locallyDhikrsCountResult.asError.error);
          }
        case Error():
          return Result.error(firestoreDhikrsCountResult.asError.error);
      }
    } else {
      _log.warning('No network connection, skipping sync');
      return Result.ok(null);
    }
    return Result.ok(null);
  }

  /// Eğer bugün için tamamlanmamış zikir kalmadıysa,
  /// bugünkü zikir hatırlatma bildirimini iptal eder.
  Future<Result<void>> cancelTodayDhikrReminderIfAllCompleted() async {
    if (auth.value.uid.isEmpty) {
      _log.warning('User ID is empty, cannot cancel dhikr reminder');
      return Result.error(const DhikrUserIdEmpty());
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final dhikrsResult = await _dhikrRepository.getAllDhikrsByDateLocally(
        date: today,
      );

      switch (dhikrsResult) {
        case Ok():
          final dhikrs = dhikrsResult.asOk.value ?? <Dhikr>[];

          if (dhikrs.isEmpty) {
            _log.info('No dhikrs found for today, skipping reminder cancel');
            return Result.ok(null);
          }

          final hasIncompleteDhikr = dhikrs.any(
            (d) =>
                !d.isDeleted &&
                !d.isCompleted &&
                d.currentCount < d.targetCount,
          );

          if (hasIncompleteDhikr) {
            _log.info(
              'There are still incomplete dhikrs for today, keeping reminder notification',
            );
            return Result.ok(null);
          }

          _log.info(
            'All dhikrs for today are completed, cancelling today\'s dhikr reminder',
          );
          final cancelResult = await _notificationRepository
              .cancelTodayDhikrNotifications(userId: auth.value.uid);

          switch (cancelResult) {
            case Ok():
              _log.info('Today\'s dhikr reminder cancelled successfully');
              return Result.ok(null);
            case Error():
              _log.warning(
                'Failed to cancel today\'s dhikr reminder: ${cancelResult.asError.error}',
              );
              return Result.error(cancelResult.asError.error);
          }
        case Error():
          _log.warning(
            'Failed to load today\'s dhikrs for reminder cancel: ${dhikrsResult.asError.error}',
          );
          return Result.error(dhikrsResult.asError.error);
      }
    } catch (e) {
      _log.severe(
        'Exception while cancelling today\'s dhikr reminder if all completed: $e',
      );
      return Result.error(const DhikrReminderCancelFailed());
    }
  }

  Future<Result<void>> cancelTodayDhikrCreationReminder() async {
    if (auth.value.uid.isEmpty) {
      _log.warning('User ID is empty, cannot cancel dhikr creation reminder');
      return Result.error(const DhikrUserIdEmpty());
    }

    try {
      final cancelResult = await _notificationRepository
          .cancelTodayDhikrCreationReminderNotification(userId: auth.value.uid);
      switch (cancelResult) {
        case Ok():
          _log.info('Today\'s dhikr creation reminder cancelled successfully');
          return Result.ok(null);
        case Error():
          _log.warning(
            'Failed to cancel today\'s dhikr creation reminder: ${cancelResult.asError.error}',
          );
          return Result.error(cancelResult.asError.error);
      }
    } catch (e) {
      _log.severe(
        'Exception while cancelling today\'s dhikr creation reminder: $e',
      );
      return Result.error(
        UserMessageException(
          'Zikir oluşturma hatırlatma bildirimi iptal edilemedi',
          cause: e,
        ),
      );
    }
  }

  Future<Result<void>> deleteDhikr({required String dhikrId}) async {
    if (auth.value.uid.isEmpty) {
      _log.warning('User ID is empty, cannot delete dhikr');
      return Result.error(const DhikrUserIdEmpty());
    }
    await _updateDeviceHasConnection();
    if (!_deviceHasConnection.value) {
      return Result.error(const ConnectivityNoConnection());
    }
    final firestoreResult = await _dhikrRepository.deleteDhikrFromFirestore(
      dhikrId: dhikrId,
      userId: auth.value.uid,
    );
    switch (firestoreResult) {
      case Ok():
        final localResult = await _dhikrRepository.deleteDhikrLocally(
          dhikrId: dhikrId,
        );
        switch (localResult) {
          case Ok():
            _log.info('Dhikr deleted successfully: $dhikrId');
            return Result.ok(null);
          case Error():
            _log.warning(
              'Failed to delete dhikr locally: ${localResult.asError.error}',
            );
            return Result.error(localResult.asError.error);
        }
      case Error():
        return Result.error(firestoreResult.asError.error);
    }
  }

  Future<Result<void>> deleteGroup({required List<String> groupIds}) async {
    if (groupIds.isEmpty) {
      _log.warning('No group IDs provided, cannot delete group');
      return Result.error(const DhikrGroupIdsEmpty());
    }
    for (final groupId in groupIds) {
      final result = await deleteDhikr(dhikrId: groupId);
      switch (result) {
        case Ok():
          continue;
        case Error():
          return Result.error(result.asError.error);
      }
    }
    return Result.ok(null);
  }

  Future<void> _updateDeviceHasConnection() async {
    final result = await _connectivityUseCase.connectionType();
    switch (result) {
      case Ok():
        _log.info('Device has connection: ${result.asOk.value}');
        _deviceHasConnection.value = result.asOk.value != ConnectivityEnum.none;
      case Error():
        _log.severe(
          'Failed to update device has connection: ${result.asError.error}',
        );
    }
  }
}
