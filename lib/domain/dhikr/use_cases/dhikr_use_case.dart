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
  }) : _dhikrRepository = dhikrRepository,
       _connectivityUseCase = connectivityUseCase,
       _authRepository = authRepository;

  // LOGGER
  final _log = Logger('DhikrUseCase');

  final DhikrRepository _dhikrRepository;
  final ConnectivityUseCase _connectivityUseCase;
  final AuthRepository _authRepository;

  // DOMAIN
  ValueListenable<Auth> get auth => _authRepository.auth;

  ValueListenable<bool> get deviceHasConnection => _deviceHasConnection;
  final ValueNotifier<bool> _deviceHasConnection = ValueNotifier<bool>(false);

  Future<Result<void>> syncDhikrs() async {
    // check network connection
    await _updateDeviceHasConnection();
    if (_deviceHasConnection.value) {
      if (auth.value.uid.isEmpty) {
        _log.warning('User ID is empty, cannot sync dhikrs');
        return Result.error(Exception('User ID is empty'));
      }
      final userId = auth.value.uid;
      // STEP 1: get dhikrs count from Firestore
      _log.info('Getting dhikrs count from Firestore for user: $userId');
      final firestoreDhikrsCount = await _dhikrRepository
          .getFirestoreDhikrsCount(userId: userId);
      switch (firestoreDhikrsCount) {
        case Ok():
          final firestoreDhikrs = firestoreDhikrsCount.asOk.value;
          if (firestoreDhikrs == null) {
            _log.warning('Firestore dhikrs count is null');
            return Result.error(Exception('Firestore dhikrs count is null'));
          }
          _log.info('Firestore dhikrs count: $firestoreDhikrs');
          final localDhikrsCountResult = await _dhikrRepository
              .getDhikrsCountLocally();
          switch (localDhikrsCountResult) {
            case Ok():
              final localDhikrsCount = localDhikrsCountResult.asOk.value;
              if (localDhikrsCount > firestoreDhikrs) {
                _log.info(
                  'Local dhikrs count is greater than firestore dhikrs count, syncing dhikrs',
                );
                await _dhikrRepository.syncDhikrs(userId: userId);
              } else if (localDhikrsCount < firestoreDhikrs) {
                _log.info(
                  'Local dhikrs count is less than firestore dhikrs count, downloading dhikrs from Firestore',
                );
                final downloadResult = await _dhikrRepository
                    .getAllDhikrsFromFirestore(userId: userId);
                switch (downloadResult) {
                  case Ok():
                    for (final dhikr in downloadResult.asOk.value) {
                      final localResult = await _dhikrRepository
                          .getDhikrLocally(dhikrId: dhikr.id);
                      switch (localResult) {
                        case Ok():
                          final localDhikr = localResult.asOk.value;
                          if (localDhikr != null) {
                            if (!localDhikr.isSynced) {
                              if (dhikr.lastUpdatedAt.isAfter(
                                localDhikr.lastUpdatedAt,
                              )) {
                                await _dhikrRepository.updateDhikrLocally(
                                  dhikrId: dhikr.id,
                                  dhikr: dhikr.copyWith(isSynced: true),
                                );
                              }
                            }
                          } else {
                            await _dhikrRepository.saveDhikrLocally(
                              dhikr: dhikr.copyWith(isSynced: true),
                            );
                          }
                        case Error():
                          await _dhikrRepository.saveDhikrLocally(
                            dhikr: dhikr.copyWith(isSynced: true),
                          );
                      }
                    }
                  case Error<List<Dhikr>>():
                    _log.warning(
                      'Failed to download dhikrs from Firestore: ${downloadResult.asError.error}',
                    );
                    return Result.error(downloadResult.asError.error);
                }
              } else {
                _log.info(
                  'Local dhikrs count is equal to firestore dhikrs count, no need to sync dhikrs',
                );
              }
            case Error():
              _log.warning(
                'Failed to get local dhikrs count: ${localDhikrsCountResult.asError.error}',
              );
              return Result.error(localDhikrsCountResult.asError.error);
          }
        case Error():
          _log.warning(
            'Failed to get dhikrs count from Firestore: ${firestoreDhikrsCount.asError.error}',
          );
          return Result.error(firestoreDhikrsCount.asError.error);
      }

      // STEP 2: Upload unsynced local dhikrs to Firestore
      final uploadResult = await _dhikrRepository.syncDhikrs(userId: userId);
      switch (uploadResult) {
        case Ok():
          _log.info('Dhikrs synced successfully');
          return Result.ok(null);
        case Error():
          _log.warning('Failed to sync dhikrs: ${uploadResult.asError.error}');
          return Result.error(uploadResult.asError.error);
      }
    } else {
      _log.warning('No network connection, skipping sync');
      return Result.ok(null);
    }
  }

  Future<Result<void>> deleteDhikr({required String dhikrId}) async {
    if (auth.value.uid.isEmpty) {
      _log.warning('User ID is empty, cannot delete dhikr');
      return Result.error(Exception('User ID is empty'));
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
            return Result.ok(null);
          case Error():
            return Result.error(localResult.asError.error);
        }
      case Error():
        return Result.error(firestoreResult.asError.error);
    }
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
