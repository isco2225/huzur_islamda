import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
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

  /// Namaz tipi string'ini prayer name'e çevirir
  String _getPrayerName(String prayerType) {
    switch (prayerType) {
      case 'fajr':
        return 'İmsak';
      case 'dhuhr':
        return 'Öğle';
      case 'asr':
        return 'İkindi';
      case 'maghrib':
        return 'Akşam';
      case 'isha':
        return 'Yatsı';
      default:
        return prayerType;
    }
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
      String prayerType = '';
      switch (prayerName) {
        case 'İmsak':
          prayerType = 'fajr';
          break;
        case 'Öğle':
          prayerType = 'dhuhr';
          break;
        case 'İkindi':
          prayerType = 'asr';
          break;
        case 'Akşam':
          prayerType = 'maghrib';
          break;
        case 'Yatsı':
          prayerType = 'isha';
          break;
        default:
          _log.warning('Unknown prayer name: $prayerName');
          return Result.error(Exception('Bilinmeyen namaz adı: $prayerName'));
      }

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
  Future<Result<void>> cancelAllPrayerNotifications() async {
    try {
      _log.info('Cancelling all prayer notifications...');

      // Tüm planlanmış bildirimleri al
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
            final cancelResult = await _notificationService
                .cancelOldPrayerNotifications(idsToCancel);
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
  Future<Result<void>> rescheduleAllPrayerNotifications({
    required PrayerTimes prayerTimes,
    required String dateKey,
  }) async {
    try {
      _log.info('Rescheduling all prayer notifications for date: $dateKey');

      // Önce tüm eski bildirimleri iptal et
      final cancelResult = await cancelAllPrayerNotifications();
      switch (cancelResult) {
        case Ok():
          break;
        case Error():
          _log.warning(
            'Failed to cancel old notifications, continuing anyway: ${cancelResult.asError.error}',
          );
      }

      // Yeni vakitler için bildirimleri planla
      final prayers = [
        (name: 'İmsak', time: prayerTimes.fajr),
        (name: 'Öğle', time: prayerTimes.dhuhr),
        (name: 'İkindi', time: prayerTimes.asr),
        (name: 'Akşam', time: prayerTimes.maghrib),
        (name: 'Yatsı', time: prayerTimes.isha),
      ];

      int scheduledCount = 0;
      for (final prayer in prayers) {
        final scheduleResult = await schedulePrayerTimeNotification(
          prayerName: prayer.name,
          prayerTime: prayer.time,
          dateKey: dateKey,
        );
        switch (scheduleResult) {
          case Ok():
            scheduledCount++;
            break;
          case Error():
            _log.warning(
              'Failed to schedule notification for ${prayer.name}: ${scheduleResult.asError.error}',
            );
        }
      }

      _log.info('Rescheduled $scheduledCount prayer notifications');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error rescheduling prayer notifications: $e');
      return Result.error(
        Exception('Namaz bildirimleri yeniden planlanamadı: $e'),
      );
    }
  }
}
