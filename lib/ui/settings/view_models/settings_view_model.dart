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
    required UserRepository userRepository,
    required SchedulePrayerNotificationsUseCase
    schedulePrayerNotificationsUseCase,
    required NotificationService notificationService,
  }) : _appRepository = appRepository,
       _requestPermissionUseCase = requestPermissionUseCase,
       _getPermissionStatesUseCase = getPermissionStatesUseCase,
       _userRepository = userRepository,
       _schedulePrayerNotificationsUseCase = schedulePrayerNotificationsUseCase,
       _notificationService = notificationService,
       _log = Logger('SettingsViewModel') {
    // DEFINE COMMANDS
    toggleNotifications = Command1(
      _toggleNotifications,
      debugLabel: 'SettingsViewModel.toggleNotifications',
    );

    // DEFINE LISTENERS
    // AppPreferences'ten isNotificationsEnabled ve isVibrationEnabled değerlerini al
    _appRepository.appPreferences.addListener(_onAppPreferencesChanged);
    _onAppPreferencesChanged();
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
          final permissionState = permissionStates.notification;
          final currentPreference =
              _appRepository.appPreferences.value.isNotificationsEnabled;

          // Eğer izin verilmişse ve AppPreferences'te false ise, true yap
          // Bu durum kullanıcı ayarlardan izin verdikten sonra uygulama geri geldiğinde olur
          if (permissionState == PermissionState.granted &&
              !currentPreference) {
            _log.info(
              'Permission granted but preference is false, updating preference...',
            );
            await _appRepository.updateIsNotificationsEnabled(
              isNotificationsEnabled: true,
            );
            // Bildirimleri planla
            await _scheduleNotifications();
          }
          // İzin verilmemişse AppPreferences'i değiştirme
          // Kullanıcı switch'i açmışsa ama izin vermemişse, switch açık kalmalı
          // Kullanıcı izin verdiğinde otomatik olarak güncellenecek
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
  final UserRepository _userRepository;
  final SchedulePrayerNotificationsUseCase _schedulePrayerNotificationsUseCase;
  final NotificationService _notificationService;
  final Logger _log;

  // STATE
  ValueListenable<bool> get isNotificationsEnabled => _isNotificationsEnabled;
  final ValueNotifier<bool> _isNotificationsEnabled = ValueNotifier<bool>(
    false,
  );
  ValueListenable<bool> get isVibrationEnabled => _isVibrationEnabled;
  final ValueNotifier<bool> _isVibrationEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showOpenSettingsDialog = ValueNotifier<bool>(false);

  // COMMANDS
  late Command1<void, bool> toggleNotifications;

  // ACTIONS
  Future<Result<void>> _toggleNotifications(bool value) async {
    try {
      _log.info('Toggling notifications: $value');
      if (value) {
        if (Platform.isIOS) {
          _log.info('Checking notification permission status for iOS...');
          final statusResult = await _getPermissionStatesUseCase.get(
            androidVersionSdkNumber: null,
          );
          switch (statusResult) {
            case Ok():
              final permissionStates = statusResult.asOk.value;
              final permissionState = permissionStates.notification;

              // Eğer zaten izin verilmişse, direkt devam et
              if (permissionState == PermissionState.granted) {
                _log.info('Notification permission already granted on iOS');
                break;
              }

              // Eğer kalıcı olarak reddedilmişse, ayarlara yönlendiren dialog göster
              if (permissionState == PermissionState.permanentlyDenied) {
                _log.warning(
                  'Notification permission permanently denied on iOS',
                );
                // Dialog göstermek için state'i güncelle
                showOpenSettingsDialog.value = true;
                return Result.error(
                  Exception(
                    'Bildirim izni kalıcı olarak reddedilmiş. Lütfen ayarlardan izin verin.',
                  ),
                );
              }
              // İzin istenebilir durumda, flutter_local_notifications ile iste
              _log.info('Requesting notification permission for iOS...');
              final iosPermissionResult = await _notificationService
                  .requestPermission();
              switch (iosPermissionResult) {
                case Ok():
                  final granted = iosPermissionResult.asOk.value;
                  if (!granted) {
                    _log.warning('Notification permission denied on iOS');
                    return Result.error(
                      Exception(
                        'Bildirim izni verilmedi. Lütfen ayarlardan izin verin.',
                      ),
                    );
                  }
                  _log.info('Notification permission granted on iOS');
                  break;
                case Error():
                  _log.severe(
                    'Error requesting notification permission on iOS: ${iosPermissionResult.asError.error}',
                  );
                  final retryResult = await _requestPermissionUseCase.request(
                    permission: Permission.notification,
                    androidVersionSdkNumber: null,
                  );
                  switch (retryResult) {
                    case Ok():
                      if (retryResult.asOk.value == PermissionState.granted) {
                        _log.info(
                          'Notification permission granted via permission_handler',
                        );
                        break;
                      } else {
                        return Result.error(
                          Exception(
                            'Bildirim izni verilmedi. Lütfen ayarlardan izin verin.',
                          ),
                        );
                      }
                    case Error():
                      return Result.error(
                        Exception(
                          'Bildirim izni alınamadı: ${retryResult.asError.error}',
                        ),
                      );
                  }
              }
              break;
            case Error():
              _log.severe(
                'Error checking notification permission status: ${statusResult.asError.error}',
              );
              // Hata olsa bile izin istemeyi dene
              _log.info('Attempting to request permission anyway...');
              final iosPermissionResult = await _notificationService
                  .requestPermission();
              switch (iosPermissionResult) {
                case Ok():
                  final granted = iosPermissionResult.asOk.value;
                  if (!granted) {
                    return Result.error(
                      Exception(
                        'Bildirim izni verilmedi. Lütfen ayarlardan izin verin.',
                      ),
                    );
                  }
                  break;
                case Error():
                  return Result.error(
                    Exception(
                      'Bildirim izni alınamadı: ${iosPermissionResult.asError.error}',
                    ),
                  );
              }
          }
        } else {
          // Android için önce mevcut izin durumunu kontrol et
          _log.info('Checking notification permission status for Android...');
          final androidInfo = await _getAndroidVersion();

          // Önce mevcut izin durumunu kontrol et (sadece kontrol, izin isteme)
          final statusResult = await _getPermissionStatesUseCase.get(
            androidVersionSdkNumber: androidInfo,
          );

          switch (statusResult) {
            case Ok():
              final permissionStates = statusResult.asOk.value;
              final permissionState = permissionStates.notification;

              // Eğer zaten izin verilmişse, direkt devam et
              if (permissionState == PermissionState.granted) {
                _log.info('Notification permission already granted on Android');
                break;
              }

              // Eğer kalıcı olarak reddedilmişse, ayarlara yönlendiren dialog göster
              if (permissionState == PermissionState.permanentlyDenied) {
                _log.warning(
                  'Notification permission permanently denied on Android',
                );
                // Dialog göstermek için state'i güncelle
                showOpenSettingsDialog.value = true;
                return Result.error(
                  Exception(
                    'Bildirim izni kalıcı olarak reddedilmiş. Lütfen ayarlardan izin verin.',
                  ),
                );
              }

              // İzin istenebilir durumda, izin iste
              _log.info('Requesting notification permission for Android...');
              final permissionResult = await _requestPermissionUseCase.request(
                permission: Permission.notification,
                androidVersionSdkNumber: androidInfo,
              );

              switch (permissionResult) {
                case Ok():
                  final requestedState = permissionResult.asOk.value;
                  if (requestedState != PermissionState.granted) {
                    _log.warning(
                      'Notification permission not granted on Android',
                    );
                    return Result.error(
                      Exception(
                        'Bildirim izni verilmedi. Lütfen ayarlardan izin verin.',
                      ),
                    );
                  }
                  _log.info('Notification permission granted on Android');
                  break;
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
              break;
            case Error():
              _log.severe(
                'Error checking notification permission status on Android: ${statusResult.asError.error}',
              );
              return Result.error(
                Exception(
                  'Bildirim izni durumu kontrol edilemedi: ${statusResult.asError.error}',
                ),
              );
          }
        }
      }

      // Repository'yi güncelle
      final updateResult = await _appRepository.updateIsNotificationsEnabled(
        isNotificationsEnabled: value,
      );

      switch (updateResult) {
        case Ok():
          // Bildirimleri planla veya iptal et
          if (value) {
            await _scheduleNotifications();
          } else {
            await _cancelNotifications();
          }
          return Result.ok(null);
        case Error():
          _log.severe(
            'Error updating notification preference: ${updateResult.asError.error}',
          );
          return updateResult;
      }
    } catch (e) {
      _log.severe('Exception toggling notifications: $e');
      return Result.error(Exception('Bildirim ayarı güncellenemedi: $e'));
    }
  }

  void toggleNotificationsFunction(bool value) {
    toggleNotifications.execute(value);
  }

  void toggleVibrationFunction(bool value) {
    toggleVibration(value);
  }

  Future<void> toggleVibration(bool value) async {
    try {
      _log.info('Toggling vibration: $value');

      // Repository'yi güncelle
      final updateResult = await _appRepository.updateIsVibrationEnabled(
        isVibrationEnabled: value,
      );

      switch (updateResult) {
        case Ok():
          _log.info('Vibration preference updated successfully');
          break;
        case Error():
          _log.severe(
            'Error updating vibration preference: ${updateResult.asError.error}',
          );
      }
    } catch (e) {
      _log.severe('Exception toggling vibration: $e');
    }
  }

  /// AppPreferences değiştiğinde çağrılır
  void _onAppPreferencesChanged() {
    final preferences = _appRepository.appPreferences.value;
    _isNotificationsEnabled.value = preferences.isNotificationsEnabled;
    _isVibrationEnabled.value = preferences.isVibrationEnabled;
  }

  /// Bildirimleri planlar
  Future<void> _scheduleNotifications() async {
    try {
      final user = _userRepository.currentUser.value;
      if (user.districtId == null ||
          user.districtId!.isEmpty ||
          user.city == null ||
          user.city!.isEmpty ||
          user.country == null ||
          user.country!.isEmpty) {
        _log.warning('User location not set, cannot schedule notifications');
        return;
      }

      _log.info('Scheduling prayer notifications for week...');
      final result = await _schedulePrayerNotificationsUseCase.scheduleForWeek(
        districtId: user.districtId!,
        city: user.city!,
        country: user.country!,
      );

      switch (result) {
        case Ok():
          _log.info('Prayer notifications scheduled successfully');
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

  /// Android SDK version'ı alır (permission_handler için)
  Future<int?> _getAndroidVersion() async {
    // permission_handler paketi otomatik olarak Android version'ı alır
    // Bu yüzden null döndürebiliriz, permission_handler kendi içinde kontrol eder
    return null;
  }

  // DISPOSE
  void dispose() {
    _appRepository.appPreferences.removeListener(_onAppPreferencesChanged);
    toggleNotifications.dispose();
    _isNotificationsEnabled.dispose();
    _isVibrationEnabled.dispose();
    showOpenSettingsDialog.dispose();
  }
}
