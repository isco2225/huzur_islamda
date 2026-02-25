import 'dart:math';

import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../data.dart';

class NotificationRepositoryRemote implements NotificationRepository {
  NotificationRepositoryRemote({
    required NotificationService notificationService,
  }) : _notificationService = notificationService,
       _log = Logger('NotificationRepositoryRemote');

  final NotificationService _notificationService;
  final Logger _log;

  /// Namaz vakti için bildirim ID'si oluşturur
  /// Format: {prayerType}_{dateKey} -> hash code
  /// Örnek: fajr_2024-01-15 -> 1001, dhuhr_2024-01-15 -> 1002
  int _generateNotificationId(String prayerType, String dateKey) {
    // Her namaz tipi için base ID
    final baseIds = {
      'fajr': 1000,
      'dhuhr': 2000,
      'asr': 3000,
      'maghrib': 4000,
      'isha': 5000,
    };

    final baseId = baseIds[prayerType] ?? 0;
    // Tarih string'inden hash oluştur (basit bir hash)
    final dateHash = dateKey.hashCode % 1000;
    return baseId + dateHash;
  }

  /// Prayer name'i namaz tipi string'ine çevirir
  String _getPrayerType(String prayerName) {
    switch (prayerName) {
      case 'İmsak':
        return 'fajr';
      case 'Öğle':
        return 'dhuhr';
      case 'İkindi':
        return 'asr';
      case 'Akşam':
        return 'maghrib';
      case 'Yatsı':
        return 'isha';
      default:
        return prayerName.toLowerCase();
    }
  }

  /// Generate a notification ID for a dhikr reminder
  int _generateDhikrReminderId({
    required String userId,
    required DateTime day,
  }) {
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final compositeKey = '$userId-$dateKey';
    final hash = compositeKey.hashCode.abs() % 1000;
    return 11000 + hash;
  }

  /// Generate a notification ID for a dhikr creation reminder
  int _generateDhikrCreationReminderId({
    required String userId,
    required DateTime day,
  }) {
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final compositeKey = '$userId-$dateKey';
    final hash = compositeKey.hashCode.abs() % 1000;
    return 12000 + hash;
  }

  @override
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey,
  }) async {
    try {
      // Skip notifications for past prayer times
      if (prayerTime.isBefore(DateTime.now())) {
        _log.info(
          'Skipping notification for past prayer time: $prayerName at $prayerTime',
        );
        return Result.ok(null);
      }

      // Convert prayer name to prayer type
      final prayerType = _getPrayerType(prayerName);
      final notificationId = _generateNotificationId(prayerType, dateKey);
      final title = '$prayerName Vakti';
      final body = '$prayerName vakti geldi';

      _log.info(
        'Scheduling prayer notification: id=$notificationId, prayer=$prayerName, time=$prayerTime',
      );

      final result = await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: prayerTime,
      );

      switch (result) {
        case Ok():
          _log.info('Prayer notification scheduled successfully: $prayerName');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to schedule prayer notification: ${result.asError.error}',
          );
          return result;
      }
    } catch (e) {
      _log.severe('Error scheduling prayer notification: $e');
      return Result.error(Exception('Namaz bildirimi planlanamadı: $e'));
    }
  }

  @override
  Future<Result<void>> scheduleDhikrCompletionReminderNotification({
    required String userId,
    required DateTime day,
  }) async {
    try {
      // Normalize the day (hour/minute/second is set to 0)
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final now = DateTime.now();

      // For past days, skip scheduling the notification
      final today = DateTime(now.year, now.month, now.day);
      if (normalizedDay.isBefore(today)) {
        _log.info(
          'Skipping dhikr reminder scheduling for past day: $normalizedDay',
        );
        return Result.ok(null);
      }

      // Target time: 22:00
      final scheduledDate = DateTime(
        normalizedDay.year,
        normalizedDay.month,
        normalizedDay.day,
        22,
      );

      // If today's 22:00 has already passed, skip scheduling the notification
      if (!scheduledDate.isAfter(now)) {
        _log.info(
          'Skipping dhikr reminder for today because 22:00 has already passed. Now: $now, target: $scheduledDate',
        );
        return Result.ok(null);
      }

      final notificationId = _generateDhikrReminderId(
        userId: userId,
        day: normalizedDay,
      );
      const title = 'Zikir Hatırlatma';
      const body = 'Bugünkü zikirlerini tamamlamayı unutma.';

      _log.info(
        'Scheduling dhikr reminder notification: id=$notificationId, day=$normalizedDay, dateTime=$scheduledDate',
      );

      final result = await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      switch (result) {
        case Ok():
          _log.info('Dhikr reminder notification scheduled successfully');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to schedule dhikr reminder notification: ${result.asError.error}',
          );
          return result;
      }
    } catch (e) {
      _log.severe('Error scheduling dhikr reminder notification: $e');
      return Result.error(
        Exception('Zikir hatırlatma bildirimi planlanamadı: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cancelAllPrayerNotifications() async {
    try {
      _log.info('Cancelling all prayer notifications...');
      final pendingResult = await _notificationService
          .getPendingNotifications();
      switch (pendingResult) {
        case Ok():
          final pendingNotifications = pendingResult.asOk.value;
          _log.info(
            'Found ${pendingNotifications.length} pending notifications',
          );

          // Sadece namaz bildirimlerini iptal et (ID aralığı 1000-9999)
          final idsToCancel = <int>[];
          for (final notification in pendingNotifications) {
            if (notification.id >= 1000 && notification.id < 10000) {
              idsToCancel.add(notification.id);
            }
          }

          if (idsToCancel.isNotEmpty) {
            final cancelResult = await _notificationService.cancelNotifications(
              ids: idsToCancel,
            );
            switch (cancelResult) {
              case Ok():
                _log.info(
                  'Cancelled ${idsToCancel.length} prayer notifications',
                );
                return Result.ok(null);
              case Error():
                _log.warning(
                  'Failed to cancel notifications: ${cancelResult.asError.error}',
                );
                return Result.error(cancelResult.asError.error);
            }
          }

          _log.info('No prayer notifications to cancel');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to get pending notifications: ${pendingResult.asError.error}',
          );
          return pendingResult;
      }
    } catch (e) {
      _log.severe('Error cancelling all prayer notifications: $e');
      return Result.error(Exception('Namaz bildirimleri iptal edilemedi: $e'));
    }
  }

  @override
  Future<Result<void>> cancelTodayDhikrNotifications({
    required String userId,
  }) async {
    try {
      _log.info('Cancelling today\'s dhikr notifications...');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final pendingResult = await _notificationService
          .getPendingNotifications();
      switch (pendingResult) {
        case Ok():
          final notificationId = _generateDhikrReminderId(
            userId: userId,
            day: today,
          );
          final cancelResult = await _notificationService.cancelNotifications(
            ids: [notificationId],
          );
          switch (cancelResult) {
            case Ok():
              _log.info('Cancelled today\'s dhikr reminder notification');
              return Result.ok(null);
            case Error():
              _log.warning(
                'Failed to cancel today\'s dhikr reminder notification: ${cancelResult.asError.error}',
              );
              return Result.error(cancelResult.asError.error);
          }
        case Error():
          _log.severe(
            'Failed to get pending notifications: ${pendingResult.asError.error}',
          );
          return pendingResult;
      }
    } catch (e) {
      _log.severe('Error cancelling all dhikr reminder notifications: $e');
      return Result.error(
        Exception('Zikir hatırlatma bildirimleri iptal edilemedi: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cancelDhikrReminderNotification({
    required String userId,
    required DateTime day,
  }) {
    // TODO: implement cancelDhikrReminderNotification
    throw UnimplementedError();
  }

  /// Schedule message generator.
  List<Map<String, String>> _generateDhikrCreationReminderMessage({
    required String userName,
  }) {
    return [
      {
        'title': 'Zikir Vakti',
        'body': 'Allah’ı çokça zikret ki kalbin huzur bulsun, $userName.',
      },
      {
        'title': 'Zikir Hatırlatma',
        'body':
            'Günün yoğun geçse de birkaç dakikalık zikir tüm ruhunu tazeler.',
      },
      {'title': 'Hey $userName!', 'body': 'Bugün zikirlerini yapmadın!.'},
      {
        'title': 'Kalp Huzuru',
        'body':
            '“Kalpler ancak Allah’ı zikretmekle huzur bulur.” Bugün zikrine vakit ayırmayı unutma.',
      },
      {
        'title': 'Kısa Bir Mola',
        'body':
            'Yoğunluğa kısa bir ara ver ve dilini tesbih, tahmid ve tekbir ile süsle.',
      },
      {
        'title': 'Gizli Hazine',
        'body':
            '“Lâ havle ve lâ kuvvete illâ billâh” zikri bugün sana güç ve teslimiyet versin.',
      },
      {
        'title': 'Akşam Sükûneti',
        'body':
            'Günü, kalbini Rabbine çeviren birkaç tesbihle kapatmaya ne dersin?',
      },
      {
        'title': 'Tevekkül Hatırlatması',
        'body':
            'Zikir, teslimiyetini tazeler. Bugün Rabbine sığınarak O’nu anmayı ihmal etme.',
      },
      {
        'title': 'Şükür Vakti',
        'body':
            'Bugün nimetlerini düşünerek “Elhamdülillah” demeyi çoğalt, $userName.',
      },
    ];
  }

  @override
  Future<Result<void>> scheduleDhikrCreationReminderNotification({
    required String userId,
    required DateTime day,
    required String userName,
  }) async {
    try {
      // Normalize the day (hour/minute/second is set to 0)
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final now = DateTime.now();

      // For past days, skip scheduling the notification
      final today = DateTime(now.year, now.month, now.day);
      if (normalizedDay.isBefore(today)) {
        _log.info(
          'Skipping dhikr reminder scheduling for past day: $normalizedDay',
        );
        return Result.ok(null);
      }

      // Target time: 19:00
      final scheduledDate = DateTime(
        normalizedDay.year,
        normalizedDay.month,
        normalizedDay.day,
        19,
      );

      // If today's 19:00 has already passed, skip scheduling the notification
      if (!scheduledDate.isAfter(now)) {
        _log.info(
          'Skipping dhikr reminder for today because 19:00 has already passed. Now: $now, target: $scheduledDate',
        );
        return Result.ok(null);
      }

      final notificationId = _generateDhikrCreationReminderId(
        userId: userId,
        day: normalizedDay,
      );
      final messages = _generateDhikrCreationReminderMessage(
        userName: userName,
      );
      final randomIndex = Random().nextInt(messages.length);
      final randomMessage = messages[randomIndex];
      final title = randomMessage['title'] ?? 'Zikir Hatırlatma';
      final body =
          randomMessage['body'] ?? 'Gün bitmeden zikirlerini yapmayı unutma.';
      _log.info(
        'Scheduling dhikr reminder notification: id=$notificationId, day=$normalizedDay, dateTime=$scheduledDate',
      );

      final result = await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      switch (result) {
        case Ok():
          _log.info('Dhikr reminder notification scheduled successfully');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Failed to schedule dhikr reminder notification: ${result.asError.error}',
          );
          return result;
      }
    } catch (e) {
      _log.severe('Error scheduling dhikr reminder notification: $e');
      return Result.error(
        Exception('Zikir hatırlatma bildirimi planlanamadı: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cancelDhikrCreationReminderNotifications() async {
    return await _notificationService
        .cancelDhikrCreationReminderNotifications();
  }

  @override
  Future<Result<void>> cancelAllNotifications() async {
    return await _notificationService.cancelAllNotifications();
  }
}
