import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

class SettingsViewModel {
  SettingsViewModel({
    required AppRepository appRepository,
    required RequestPermissionUseCase requestPermissionUseCase,
    required GetPermissionStatesUseCase getPermissionStatesUseCase,
    required SchedulePrayerNotificationsUseCase
    schedulePrayerNotificationsUseCase,
    required NotificationService notificationService,
  }) : _appRepository = appRepository,
       _requestPermissionUseCase = requestPermissionUseCase,
       _getPermissionStatesUseCase = getPermissionStatesUseCase,
       _schedulePrayerNotificationsUseCase = schedulePrayerNotificationsUseCase,
       _notificationService = notificationService,
       _log = Logger('SettingsViewModel'),
       isNotificationsEnabled = ValueNotifier<bool>(
         appRepository.appPreferences.value.isNotificationsEnabled,
       ),
       isVibrationEnabled = ValueNotifier<bool>(
         appRepository.appPreferences.value.isVibrationEnabled,
       ) {
    // DEFINE COMMANDS
    toggleNotifications = Command1(
      _toggleNotifications,
      debugLabel: 'SettingsViewModel.toggleNotifications',
    );
    toggleVibration = Command1(
      _toggleVibration,
      debugLabel: 'SettingsViewModel.toggleVibration',
    );
    scheduleTestNotifications = Command0(
      _scheduleTestNotifications,
      debugLabel: 'SettingsViewModel.scheduleTestNotifications',
    );
    cancelTestNotifications = Command0(
      _cancelTestNotifications,
      debugLabel: 'SettingsViewModel.cancelTestNotifications',
    );
  }

  /// İzin durumunu kontrol eder ve AppPreferences ile senkronize eder
  /// Kullanıcı ayarlardan izin verdikten sonra uygulama geri geldiğinde çağrılır
  /// NOT: Bu metod sadece izin verilmişse AppPreferences'i true yapar,
  /// izin verilmemişse AppPreferences'i değiştirmez (kullanıcı tercihini korur)
  Future<void> checkAndSyncPermissionStatus() async {
    try {
      _log.info('Checking and syncing notification permission status...');

      // İzin durumunu kontrol et (sadece kontrol, izin isteme)
      final statusResult = await _getPermissionStatesUseCase.get(
        androidVersionSdkNumber: null,
      );

      switch (statusResult) {
        case Ok():
          final permissionStates = statusResult.asOk.value;
          final currentPreference =
              _appRepository.appPreferences.value.isNotificationsEnabled;
          if (permissionStates.notification == PermissionState.granted &&
              !currentPreference) {
            _log.info(
              'Permission granted but preference is false, updating preference...',
            );
            await _appRepository.updateIsNotificationsEnabled(
              isNotificationsEnabled: true,
            );
            await _scheduleNotifications();
          }
          break;
        case Error():
          _log.warning(
            'Error checking permission status: ${statusResult.asError.error}',
          );
      }
    } catch (e) {
      _log.severe('Exception checking permission status: $e');
    }
  }

  final AppRepository _appRepository;
  final RequestPermissionUseCase _requestPermissionUseCase;
  final GetPermissionStatesUseCase _getPermissionStatesUseCase;
  final SchedulePrayerNotificationsUseCase _schedulePrayerNotificationsUseCase;
  final NotificationService _notificationService;
  final Logger _log;

  // STATE

  final ValueNotifier<bool> isNotificationsEnabled;
  final ValueNotifier<bool> isVibrationEnabled;

  final ValueNotifier<bool> showOpenSettingsDialog = ValueNotifier<bool>(false);

  // COMMANDS
  late Command1<void, bool> toggleNotifications;
  late Command1<void, bool> toggleVibration;
  late Command0<void> scheduleTestNotifications;
  late Command0<void> cancelTestNotifications;

  // ACTIONS
  Future<Result<void>> _toggleNotifications(bool value) async {
    try {
      _log.info('Toggling notifications: $value');

      // Eğer açılıyorsa, önce izin kontrolü yap
      if (value) {
        final permissionResult = Platform.isIOS
            ? await _requestNotificationPermissionIOS()
            : await _requestNotificationPermissionAndroid();

        switch (permissionResult) {
          case Ok():
            await _scheduleNotifications();
            break;
          case Error():
            return permissionResult;
        }
      }

      // Repository'yi güncelle ve bildirimleri planla/iptal et
      return await _updateNotificationPreference(value);
    } catch (e) {
      _log.severe('Exception toggling notifications: $e');
      return Result.error(Exception('Bildirim ayarı güncellenemedi: $e'));
    }
  }

  /// iOS için bildirim izni ister
  Future<Result<void>> _requestNotificationPermissionIOS() async {
    _log.info('Checking notification permission status for iOS...');

    final statusResult = await _getPermissionStatesUseCase.get(
      androidVersionSdkNumber: null,
    );

    switch (statusResult) {
      case Ok():
        final permissionState = statusResult.asOk.value.notification;
        return _handlePermissionState(permissionState, isIOS: true);
      case Error():
        _log.warning(
          'Error checking permission status, attempting request anyway: ${statusResult.asError.error}',
        );
        return await _requestIOSPermissionWithFallback();
    }
  }

  /// Android için bildirim izni ister
  Future<Result<void>> _requestNotificationPermissionAndroid() async {
    _log.info('Checking notification permission status for Android...');

    final statusResult = await _getPermissionStatesUseCase.get(
      androidVersionSdkNumber: null,
    );

    switch (statusResult) {
      case Ok():
        final permissionState = statusResult.asOk.value.notification;
        return _handlePermissionState(permissionState, isIOS: false);
      case Error():
        _log.severe(
          'Error checking notification status on Android: ${statusResult.asError.error}',
        );
        return Result.error(
          Exception(
            'Bildirim izni durumu kontrol edilemedi: ${statusResult.asError.error}',
          ),
        );
    }
  }

  /// Permission state'e göre uygun aksiyonu alır
  Future<Result<void>> _handlePermissionState(
    PermissionState permissionState, {
    required bool isIOS,
  }) async {
    // Zaten izin verilmişse, direkt başarı dön
    if (permissionState == PermissionState.granted) {
      _log.info(
        'Notification permission already granted on ${isIOS ? 'iOS' : 'Android'}',
      );
      return Result.ok(null);
    }

    // Kalıcı olarak reddedilmişse, ayarlara yönlendir
    if (permissionState == PermissionState.permanentlyDenied) {
      _log.warning(
        'Notification permission permanently denied on ${isIOS ? 'iOS' : 'Android'}',
      );
      showOpenSettingsDialog.value = true;
      return Result.error(
        Exception(
          'Bildirim izni kalıcı olarak reddedilmiş. Lütfen ayarlardan izin verin.',
        ),
      );
    }

    // İzin istenebilir durumda, izin iste
    _log.info(
      'Requesting notification permission for ${isIOS ? 'iOS' : 'Android'}...',
    );

    if (isIOS) {
      return await _requestIOSPermissionWithFallback();
    } else {
      return await _requestAndroidPermission();
    }
  }

  /// iOS için izin ister (flutter_local_notifications ile, fallback: permission_handler)
  Future<Result<void>> _requestIOSPermissionWithFallback() async {
    final iosPermissionResult = await _notificationService.requestPermission();

    switch (iosPermissionResult) {
      case Ok():
        final granted = iosPermissionResult.asOk.value;
        if (!granted) {
          _log.warning('Notification permission denied on iOS');
          return Result.error(
            Exception('Bildirim izni verilmedi. Lütfen ayarlardan izin verin.'),
          );
        }
        _log.info('Notification permission granted on iOS');
        return Result.ok(null);
      case Error():
        _log.warning(
          'flutter_local_notifications failed, trying permission_handler: ${iosPermissionResult.asError.error}',
        );
        return await _requestIOSPermissionWithHandler();
    }
  }

  /// iOS için permission_handler ile izin ister
  Future<Result<void>> _requestIOSPermissionWithHandler() async {
    final retryResult = await _requestPermissionUseCase.request(
      permission: Permission.notification,
      androidVersionSdkNumber: null,
    );

    switch (retryResult) {
      case Ok():
        if (retryResult.asOk.value == PermissionState.granted) {
          _log.info('Notification permission granted via permission_handler');
          return Result.ok(null);
        } else {
          return Result.error(
            Exception('Bildirim izni verilmedi. Lütfen ayarlardan izin verin.'),
          );
        }
      case Error():
        return Result.error(
          Exception('Bildirim izni alınamadı: ${retryResult.asError.error}'),
        );
    }
  }

  /// Android için permission_handler ile izin ister
  Future<Result<void>> _requestAndroidPermission() async {
    final permissionResult = await _requestPermissionUseCase.request(
      permission: Permission.notification,
      androidVersionSdkNumber: null,
    );

    switch (permissionResult) {
      case Ok():
        final requestedState = permissionResult.asOk.value;
        if (requestedState != PermissionState.granted) {
          _log.warning('Notification permission not granted on Android');
          return Result.error(
            Exception('Bildirim izni verilmedi. Lütfen ayarlardan izin verin.'),
          );
        }
        _log.info('Notification permission granted on Android');
        return Result.ok(null);
      case Error():
        _log.severe(
          'Error requesting notification permission on Android: ${permissionResult.asError.error}',
        );
        return Result.error(
          Exception(
            'Bildirim izni alınamadı: ${permissionResult.asError.error}',
          ),
        );
    }
  }

  /// Bildirim tercihini günceller ve bildirimleri planlar/iptal eder
  Future<Result<void>> _updateNotificationPreference(bool value) async {
    final updateResult = await _appRepository.updateIsNotificationsEnabled(
      isNotificationsEnabled: value,
    );

    switch (updateResult) {
      case Ok():
        // Bildirimleri planla veya iptal et
        if (value) {
          isNotificationsEnabled.value = value;
          await _scheduleNotifications();
        } else {
          await _cancelNotifications();
        }
        isNotificationsEnabled.value = value;
        return Result.ok(null);
      case Error():
        _log.severe(
          'Error updating notification preference: ${updateResult.asError.error}',
        );
        return updateResult;
    }
  }

  Future<Result<void>> _toggleVibration(bool value) async {
    try {
      _log.info('Toggling vibration: $value');

      // Repository'yi güncelle
      final updateResult = await _appRepository.updateIsVibrationEnabled(
        isVibrationEnabled: value,
      );

      switch (updateResult) {
        case Ok():
          _log.info('Vibration preference updated successfully');
          isVibrationEnabled.value = value;
          return updateResult;
        case Error():
          _log.severe(
            'Error updating vibration preference: ${updateResult.asError.error}',
          );
          return Result.error(
            Exception(
              'Titreşim ayarı güncellenemedi: ${updateResult.asError.error}',
            ),
          );
      }
    } catch (e) {
      _log.severe('Exception toggling vibration: $e');
      return Result.error(Exception('Titreşim ayarı güncellenemedi: $e'));
    }
  }

  /// Bildirimleri planlar
  Future<void> _scheduleNotifications() async {
    try {
      _log.info('Scheduling prayer notifications for week...');
      final result = await _schedulePrayerNotificationsUseCase
          .scheduleForWeek();

      switch (result) {
        case Ok():
          result.asOk.value == true
              ? _log.info('Prayer notifications scheduled successfully')
              : _log.warning('Failed to schedule notifications');
          break;
        case Error():
          _log.warning(
            'Failed to schedule notifications: ${result.asError.error}',
          );
      }
    } catch (e) {
      _log.severe('Exception scheduling notifications: $e');
    }
  }

  /// Bildirimleri iptal eder
  Future<void> _cancelNotifications() async {
    try {
      _log.info('Cancelling prayer notifications...');
      final result = await _schedulePrayerNotificationsUseCase.cancelAll();
      switch (result) {
        case Ok():
          _log.info('Prayer notifications cancelled successfully');
          break;
        case Error():
          _log.warning(
            'Failed to cancel notifications: ${result.asError.error}',
          );
      }
    } catch (e) {
      _log.severe('Exception cancelling notifications: $e');
    }
  }

  /// Test için her 10 dakikada bir bildirim planlar
  Future<Result<void>> _scheduleTestNotifications() async {
    try {
      _log.info('Scheduling test notifications...');
      final result = await _notificationService.scheduleTestNotifications(
        count: 5,
      );
      switch (result) {
        case Ok():
          _log.info('Test notifications scheduled successfully');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to schedule test notifications: ${result.asError.error}',
          );
          return result;
      }
    } catch (e) {
      _log.severe('Exception scheduling test notifications: $e');
      return Result.error(Exception('Test bildirimleri planlanamadı: $e'));
    }
  }

  /// Test bildirimlerini iptal eder
  Future<Result<void>> _cancelTestNotifications() async {
    try {
      _log.info('Cancelling test notifications...');
      final result = await _notificationService.cancelTestNotifications(
        count: 5,
      );
      switch (result) {
        case Ok():
          _log.info('Test notifications cancelled successfully');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to cancel test notifications: ${result.asError.error}',
          );
          return result;
      }
    } catch (e) {
      _log.severe('Exception cancelling test notifications: $e');
      return Result.error(Exception('Test bildirimleri iptal edilemedi: $e'));
    }
  }

  // DISPOSE
  void dispose() {
    toggleNotifications.dispose();
    toggleVibration.dispose();
    scheduleTestNotifications.dispose();
    cancelTestNotifications.dispose();
    showOpenSettingsDialog.dispose();
  }
}
