import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart' as pck;

import '../../../app/app.dart';
import '../../domain.dart';

/// UseCase for Getting Location.
class RequestPermissionUseCase {
  RequestPermissionUseCase._(this._request);

  /// Create a [RequestPermissionUseCase] that uses
  /// `permission_handler` package.
  factory RequestPermissionUseCase.withPermissionHandler() {
    return RequestPermissionUseCase._(({
      required Permission permission,
      required int? androidVersionSdkNumber,
    }) async {
      final permissionStatus = switch (permission) {
        Permission.location => await pck.Permission.locationWhenInUse.request(),
        Permission.notification => await pck.Permission.notification.request(),
      };
      return permissionStatus.toPermissionState();
    });
  }

  /// Create a [RequestPermissionUseCase] with a custom function.
  factory RequestPermissionUseCase.custom(
    Future<PermissionState> Function({
      required Permission permission,
      required int? androidVersionSdkNumber,
    })
    request,
  ) => RequestPermissionUseCase._(request);

  // Funcions
  final Future<PermissionState> Function({
    required Permission permission,
    required int? androidVersionSdkNumber,
  })
  _request;

  // Logger
  final log = Logger('RequestPermissionUseCase');

  Future<Result<PermissionState>> request({
    required Permission permission,
    required int? androidVersionSdkNumber,
  }) async {
    log.info('Request Permission Started.');
    try {
      final geoLocation = await _request(
        permission: permission,
        androidVersionSdkNumber: androidVersionSdkNumber,
      );
      log.info('Request Successful.');
      return Result.ok(geoLocation);
    } on Exception catch (error) {
      log.severe('Request Permission Error.', error);
      return Result.error(error);
    }
  }
}
