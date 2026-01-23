import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class SchedulePrayerNotificationsUseCase {
  SchedulePrayerNotificationsUseCase({
    required PrayerRepository prayerRepository,
    required NotificationRepository notificationRepository,
  }) : _prayerRepository = prayerRepository,
       _notificationRepository = notificationRepository,
       _log = Logger('SchedulePrayerNotificationsUseCase');

  final PrayerRepository _prayerRepository;
  final NotificationRepository _notificationRepository;
  final Logger _log;

  /// Bir haftalık bildirim planlar
  /// Önce tüm eski namaz bildirimlerini iptal eder, sonra önümüzdeki 7 gün (bugün dahil) için yeni bildirimleri planlar
  Future<Result<bool>> scheduleForWeek({
    required String districtId,
    required String city,
    required String country,
  }) async {
    if (districtId.isEmpty || city.isEmpty || country.isEmpty) {
      print('Lokasyon bilgileri eksik');
      return Result.ok(false);
    }
    try {
      _log.info('Scheduling notifications for week (7 days including today)');

      // Önce tüm eski namaz bildirimlerini iptal et
      _log.info('Cancelling all old prayer notifications...');
      final cancelResult = await _notificationRepository
          .cancelAllPrayerNotifications();
      switch (cancelResult) {
        case Ok():
          _log.info('Cancelled all old prayer notifications');
          break;
        case Error():
          _log.warning(
            'Failed to cancel old notifications, continuing anyway: ${cancelResult.asError.error}',
          );
        // Devam et, yeni bildirimleri planlamaya çalış
      }

      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
      );

      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer == null) {
            _log.warning('No prayer times found locally');
            return Result.error(Exception('Namaz vakitleri bulunamadı'));
          }

          final now = DateTime.now();
          // Bugünden itibaren 7 gün için bildirim planla (bugün dahil)
          int scheduledDays = 0;
          int totalNotifications = 0;
          for (int i = 0; i < 7; i++) {
            final targetDate = DateTime(now.year, now.month, now.day + i);
            final dateKey = Prayer.formatDate(targetDate);
            final prayerTimes = prayer.getPrayerTimesForDate(dateKey);
            if (prayerTimes != null) {
              // Her namaz vakti için bildirim planla
              final prayers = [
                (name: 'İmsak', time: prayerTimes.fajr),
                (name: 'Öğle', time: prayerTimes.dhuhr),
                (name: 'İkindi', time: prayerTimes.asr),
                (name: 'Akşam', time: prayerTimes.maghrib),
                (name: 'Yatsı', time: prayerTimes.isha),
              ];

              int dayNotifications = 0;
              for (final prayerItem in prayers) {
                // Geçmiş vakitler için bildirim planlanmaz
                if (prayerItem.time.isAfter(now) ||
                    (prayerItem.time.year == now.year &&
                        prayerItem.time.month == now.month &&
                        prayerItem.time.day == now.day &&
                        prayerItem.time.hour == now.hour &&
                        prayerItem.time.minute == now.minute)) {
                  final scheduleResult = await _notificationRepository
                      .schedulePrayerTimeNotification(
                        prayerName: prayerItem.name,
                        prayerTime: prayerItem.time,
                        dateKey: dateKey,
                      );
                  switch (scheduleResult) {
                    case Ok():
                      dayNotifications++;
                      totalNotifications++;
                      break;
                    case Error():
                      _log.warning(
                        'Failed to schedule notification for ${prayerItem.name} on $dateKey: ${scheduleResult.asError.error}',
                      );
                  }
                }
              }

              if (dayNotifications > 0) {
                scheduledDays++;
                _log.info(
                  'Scheduled $dayNotifications notifications for $dateKey',
                );
              }
            }
          }

          _log.info(
            'Scheduled $totalNotifications notifications for $scheduledDays days',
          );
          return Result.ok(true);
        case Error():
          _log.severe(
            'Error getting prayer times locally: ${localResult.asError.error}',
          );
          return Result.error(localResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception scheduling notifications for week: $e');
      return Result.error(Exception('Haftalık bildirimler planlanamadı: $e'));
    }
  }

  /// Tüm namaz bildirimlerini iptal eder
  Future<Result<void>> cancelAll() async {
    try {
      _log.info('Cancelling all prayer notifications');
      return await _notificationRepository.cancelAllPrayerNotifications();
    } catch (e) {
      _log.severe('Exception cancelling all notifications: $e');
      return Result.error(Exception('Bildirimler iptal edilemedi: $e'));
    }
  }
}
