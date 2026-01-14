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
      final result = await _dhikrRepository.syncDhikrs(userId: auth.value.uid);
      switch (result) {
        case Ok():
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } else {
      _log.warning('No network connection, skipping sync');
      return Result.ok(null);
    }
  }

  Future<Result<void>> deleteDhikr({required String dhikrId}) async {
    await _updateDeviceHasConnection();
    if (_deviceHasConnection.value) {
      if (auth.value.uid.isEmpty) {
        _log.warning('User ID is empty, cannot delete dhikr');
        return Result.error(Exception('User ID is empty'));
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
    } else {
      _log.warning('No network connection, skipping delete');
      return Result.error(Exception('No network connection'));
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
