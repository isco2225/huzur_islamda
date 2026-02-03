import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app/app.dart';

// UILocalNotificationDateInterpretation için import
// Bu enum flutter_local_notifications paketinden gelir

class NotificationService {
  NotificationService() : _log = Logger('NotificationService');

  final Logger _log;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Bildirim servisini başlatır
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      _log.info('Notification service already initialized');
      return Result.ok(null);
    }

    try {
      _log.info('Initializing notification service...');

      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == null) {
        _log.severe('Failed to initialize notification plugin');
        return Result.error(Exception('Bildirim servisi başlatılamadı'));
      }

      if (!initialized) {
        _log.severe('Failed to initialize notification plugin');
        return Result.error(Exception('Bildirim servisi başlatılamadı'));
      }

      // Create notification channel for Android
      await _createNotificationChannel();

      _isInitialized = true;
      _log.info('Notification service initialized successfully');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error initializing notification service: $e');
      return Result.error(Exception('Bildirim servisi başlatılamadı: $e'));
    }
  }

  /// Android için bildirim kanalı oluşturur
  Future<void> _createNotificationChannel() async {
    final androidChannel = AndroidNotificationChannel(
      'prayer_times_channel', // id
      'Namaz Vakitleri', // name
      description: 'Namaz vakitleri bildirimleri için kanal',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
      ledColor: const Color(0xFFFFC107), // Amber renk (ARGB: 255, 255, 193, 7)
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Kanal zaten varsa bile yeniden oluştur (Samsung cihazlarda önemli)
      await androidImplementation.deleteNotificationChannel(androidChannel.id);
      await androidImplementation.createNotificationChannel(androidChannel);
      _log.info('Notification channel created/updated: ${androidChannel.id}');
    }
  }

  /// Bildirim tıklandığında çağrılır
  void _onNotificationTapped(NotificationResponse response) {
    _log.info('Notification tapped: ${response.id}');
    // TODO: Navigate to prayer times screen if needed
  }

  /// iOS'ta bildirim izin durumunu kontrol eder (izin istemez, sadece kontrol eder)
  Future<Result<bool>> checkPermissionStatus() async {
    try {
      _log.info('Checking notification permission status...');

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        _log.info('iOS notification permission status: $granted');

        if (granted != null && granted == true) {
          _log.info('Notification permission is granted on iOS');
          return Result.ok(true);
        } else {
          _log.info('Notification permission is not granted on iOS');
          return Result.ok(false);
        }
      }

      // Android ve diğer platformlar için varsayılan olarak true döndür
      // Android için permission_handler paketi kullanılmalı
      _log.info('Notification permission check not needed for this platform');
      return Result.ok(true);
    } catch (e) {
      _log.severe('Error checking notification permission status: $e');
      return Result.error(
        Exception('Bildirim izin durumu kontrol edilemedi: $e'),
      );
    }
  }

  /// Bildirim izni ister (iOS için)
  /// Android için permission_handler paketi kullanılmalı
  ///
  /// NOT: iOS'ta eğer izin durumu daha önce belirlenmişse (granted/denied),
  /// sistem dialog'u tekrar göstermez. Bu durumda mevcut izin durumunu döndürür.
  Future<Result<bool>> requestPermission() async {
    try {
      _log.info('Requesting notification permission...');

      // iOS için izin kontrolü
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        _log.info('iOS implementation found, requesting permissions...');
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        _log.info('requestPermissions() returned: $granted');

        if (granted != null && granted == true) {
          _log.info('Notification permission granted on iOS');
          return Result.ok(true);
        } else {
          _log.warning(
            'Notification permission denied or not determined on iOS. '
            'If dialog was not shown, permission may have been already set. '
            'Check Settings > [App Name] > Notifications to verify.',
          );
          return Result.ok(false);
        }
      }

      // Android ve diğer platformlar için varsayılan olarak true döndür
      // Android için permission_handler paketi kullanılmalı
      _log.info('Notification permission check not needed for this platform');
      return Result.ok(true);
    } catch (e) {
      _log.severe('Error requesting notification permission: $e');
      return Result.error(Exception('Bildirim izni alınamadı: $e'));
    }
  }

  /// Belirli bir tarih/saat için bildirim planlar
  Future<Result<void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (!_isInitialized) {
        _log.warning(
          'Notification service not initialized, initializing now...',
        );
        final initResult = await initialize();
        switch (initResult) {
          case Ok():
            break;
          case Error():
            return Result.error(Exception('Bildirim servisi başlatılamadı'));
        }
      }

      // Geçmiş tarih kontrolü
      if (scheduledDate.isBefore(DateTime.now())) {
        _log.warning(
          'Cannot schedule notification for past date: $scheduledDate',
        );
        return Result.error(
          Exception('Geçmiş tarih için bildirim planlanamaz'),
        );
      }

      _log.info(
        'Scheduling notification: id=$id, title=$title, date=$scheduledDate',
      );

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        'prayer_times_channel',
        'Namaz Vakitleri',
        channelDescription: 'Namaz vakitleri bildirimleri için kanal',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        enableLights: true,
        ledColor: const Color(
          0xFFFFC107,
        ), // Amber renk (ARGB: 255, 255, 193, 7)
        ledOnMs:
            1000, // LED'in yanık kalacağı süre (ms) - Android Oreo öncesi için gerekli
        ledOffMs:
            500, // LED'in sönük kalacağı süre (ms) - Android Oreo öncesi için gerekli
        styleInformation: const BigTextStyleInformation(''),
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ongoing: false,
        autoCancel: true,
        showProgress: false,
        maxProgress: 0,
        indeterminate: false,
        onlyAlertOnce: false,
        channelShowBadge: true,
        ticker: '',
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      _log.info('Notification scheduled successfully: id=$id');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error scheduling notification: $e');
      return Result.error(Exception('Bildirim planlanamadı: $e'));
    }
  }

  /// TZDateTime'a çevirir (timezone desteği için)
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    // Local timezone kullan
    // Eğer local timezone ayarlanmamışsa, Europe/Istanbul kullan
    try {
      return tz.TZDateTime.from(dateTime, tz.local);
    } catch (e) {
      // Local timezone ayarlanmamışsa, Europe/Istanbul kullan
      final location = tz.getLocation('Europe/Istanbul');
      return tz.TZDateTime.from(dateTime, location);
    }
  }

  /// Bildirimi iptal eder
  Future<Result<void>> cancelNotifications({required List<int> ids}) async {
    try {
      _log.info('Cancelling notifications: ids=$ids');
      for (final id in ids) {
        _log.info('Cancelling notification: id=$id');
        await _notificationsPlugin.cancel(id);
        _log.info('Notification cancelled successfully: id=$id');
      }
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error cancelling notification: $e');
      return Result.error(Exception('Bildirim iptal edilemedi: $e'));
    }
  }

  /// Tüm bildirimleri iptal eder
  Future<Result<void>> cancelAllNotifications() async {
    try {
      _log.info('Cancelling all notifications...');
      await _notificationsPlugin.cancelAll();
      _log.info('All notifications cancelled successfully');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error cancelling all notifications: $e');
      return Result.error(Exception('Bildirimler iptal edilemedi: $e'));
    }
  }

  /// Planlanmış bildirimleri getirir
  Future<Result<List<PendingNotificationRequest>>>
  getPendingNotifications() async {
    try {
      _log.info('Getting pending notifications...');
      final pendingNotifications = await _notificationsPlugin
          .pendingNotificationRequests();
      _log.info('Found ${pendingNotifications.length} pending notifications');
      return Result.ok(pendingNotifications);
    } catch (e) {
      _log.severe('Error getting pending notifications: $e');
      return Result.error(Exception('Planlanmış bildirimler alınamadı: $e'));
    }
  }
}
