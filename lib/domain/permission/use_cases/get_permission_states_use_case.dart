import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart' as pck;

import '../../../app/app.dart';
import '../../domain.dart';

/// UseCase for Getting Permission States.
class GetPermissionStatesUseCase {
  GetPermissionStatesUseCase._(this._getPermissionStates);

  /// Create a [GetPermissionStatesUseCase] that uses
  /// `permission_handler` package.
  factory GetPermissionStatesUseCase.withPermissionHandler() {
    return GetPermissionStatesUseCase._(({
      required int? androidVersionSdkNumber,
    }) async {
      final locationPermissionState = await pck.Permission.location.status;
      final notificationPermissionState =
          await pck.Permission.notification.status;
      return PermissionStates(
        location: locationPermissionState.toPermissionState(),
        notification: notificationPermissionState.toPermissionState(),
      );
    });
  }

  /// Create a [GetPermissionStatesUseCase] with a custom function.
  factory GetPermissionStatesUseCase.custom(
    Future<PermissionStates> Function({required int? androidVersionSdkNumber})
    getPermissionStates,
  ) => GetPermissionStatesUseCase._(getPermissionStates);

  // Functions
  final Future<PermissionStates> Function({
    required int? androidVersionSdkNumber,
  })
  _getPermissionStates;

  // Logger
  final log = Logger('GetPermissionStatesUseCase');

  Future<Result<PermissionStates>> get({
    required int? androidVersionSdkNumber,
  }) async {
    log.info('Get Permission States Started');
    try {
      final permissionStates = await _getPermissionStates(
        androidVersionSdkNumber: androidVersionSdkNumber,
      );
      log.fine('Got Permission States successfully ');
      return Result.ok(permissionStates);
    } on Exception catch (error) {
      log.severe('Failed to get permission States', error);
      return Result.error(error);
    }
  }
}

extension ToPermissionState on pck.PermissionStatus {
  PermissionState toPermissionState() {
    return switch (this) {
      pck.PermissionStatus.denied => PermissionState.requestable,
      pck.PermissionStatus.granted => PermissionState.granted,
      pck.PermissionStatus.limited => PermissionState.granted,
      pck.PermissionStatus.permanentlyDenied =>
        PermissionState.permanentlyDenied,
      pck.PermissionStatus.provisional => PermissionState.granted,
      pck.PermissionStatus.restricted => PermissionState.permanentlyDenied,
    };
  }
}
