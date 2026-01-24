import 'dart:io';

import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class SyncPermissionUseCase {
  SyncPermissionUseCase({
    required this.getPermissionStatesUseCase,
    required this.requestPermissionUseCase,
    required this.appRepository,
    required this.notificationService,
  });
  final GetPermissionStatesUseCase getPermissionStatesUseCase;
  final RequestPermissionUseCase requestPermissionUseCase;
  final AppRepository appRepository;
  final NotificationService notificationService;

  final _log = Logger('SyncPermissionUseCase');

  Future<Result<void>> syncNotificationPermissionState() async {
    _log.info('Syncing notification permission state...');
    try {
      // iOS'ta permission_handler bazen doğru çalışmaz, flutter_local_notifications ile kontrol et
      bool? iosNotificationGranted;
      if (Platform.isIOS) {
        final iosCheckResult = await notificationService
            .checkPermissionStatus();
        switch (iosCheckResult) {
          case Ok():
            iosNotificationGranted = iosCheckResult.asOk.value;
            _log.info(
              'iOS notification permission (flutter_local_notifications): $iosNotificationGranted',
            );
            break;
          case Error():
            _log.warning(
              'Failed to check iOS notification permission with flutter_local_notifications: ${iosCheckResult.asError.error}',
            );
            break;
        }
      }

      final permissionStatesResult = await getPermissionStatesUseCase.get(
        androidVersionSdkNumber: null,
      );
      switch (permissionStatesResult) {
        case Ok():
          final permissionStates = permissionStatesResult.asOk.value;
          final appPreferences = appRepository.appPreferences.value;

          // for ios, use flutter_local_notifications permission status
          // for other platforms, use permission_handler permission status
          final isNotificationGranted =
              Platform.isIOS && iosNotificationGranted != null
              ? iosNotificationGranted
              : permissionStates.notification == PermissionState.granted;
          if (!isNotificationGranted) {
            _log.warning(
              'Notification permission not granted. permission_handler: ${permissionStates.notification}, '
              'flutter_local_notifications: ${iosNotificationGranted ?? 'N/A'}',
            );
            if (appPreferences.isNotificationsEnabled) {
              _log.info(
                'Notification permission not granted, disabling notifications in preferences',
              );
              final updateResult = await appRepository
                  .updateIsNotificationsEnabled(isNotificationsEnabled: false);
              switch (updateResult) {
                case Ok():
                  _log.info(
                    'Successfully disabled notifications in preferences',
                  );
                  break;
                case Error():
                  _log.warning(
                    'Failed to update notification preference: ${updateResult.asError.error}',
                  );
                  return Result.error(updateResult.asError.error);
              }
            }
          }
          _log.info('Notification permission state synced successfully');
          return Result.ok(null);
        case Error():
          _log.warning(
            'Failed to get permission states: ${permissionStatesResult.asError.error}',
          );
          return Result.error(permissionStatesResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception syncing notification permission state', e);
      return Result.error(
        Exception('Failed to sync notification permission state: $e'),
      );
    }
  }
}
