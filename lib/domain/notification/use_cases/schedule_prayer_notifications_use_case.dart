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

  /// Bugünün namaz vakitleri için bildirim planlar
  Future<Result<void>> scheduleForToday({
    required String districtId,
    required String city,
    required String country,
  }) async {
    try {
      _log.info('Scheduling notifications for today');

      // Bugünün namaz vakitlerini al
      final now = DateTime.now();
      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
        date: now,
      );

      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer == null) {
            _log.warning('No prayer times found locally for today');
            return Result.error(Exception('Namaz vakitleri bulunamadı'));
          }

          final todayTimes = prayer.getTodayPrayerTimes();
          if (todayTimes == null) {
            _log.warning('Today prayer times not found');
            return Result.error(
              Exception('Bugünün namaz vakitleri bulunamadı'),
            );
          }

          final dateKey = Prayer.formatDate(now);
          return await _notificationRepository.rescheduleAllPrayerNotifications(
            prayerTimes: todayTimes,
            dateKey: dateKey,
          );
        case Error():
          _log.severe(
            'Error getting prayer times locally: ${localResult.asError.error}',
          );
          return Result.error(localResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception scheduling notifications for today: $e');
      return Result.error(Exception('Bugünün bildirimleri planlanamadı: $e'));
    }
  }

  /// Bir haftalık bildirim planlar
  /// Önce tüm eski namaz bildirimlerini iptal eder, sonra önümüzdeki 7 gün (bugün dahil) için yeni bildirimleri planlar
  Future<Result<void>> scheduleForWeek({
    required String districtId,
    required String city,
    required String country,
  }) async {
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

      final now = DateTime.now();
      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
        date: now,
      );

      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer == null) {
            _log.warning('No prayer times found locally');
            return Result.error(Exception('Namaz vakitleri bulunamadı'));
          }

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
          return Result.ok(null);
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

  /// Bir aylık bildirim planlar
  Future<Result<void>> scheduleForMonth({
    required String districtId,
    required String city,
    required String country,
  }) async {
    try {
      _log.info('Scheduling notifications for month');

      final now = DateTime.now();
      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
        date: now,
      );

      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer == null) {
            _log.warning('No prayer times found locally');
            return Result.error(Exception('Namaz vakitleri bulunamadı'));
          }

          // Bugünden itibaren 30 gün için bildirim planla
          int scheduledDays = 0;
          for (int i = 0; i < 30; i++) {
            final targetDate = DateTime(now.year, now.month, now.day + i);
            final dateKey = Prayer.formatDate(targetDate);
            final prayerTimes = prayer.getPrayerTimesForDate(dateKey);

            if (prayerTimes != null) {
              final scheduleResult = await _notificationRepository
                  .rescheduleAllPrayerNotifications(
                    prayerTimes: prayerTimes,
                    dateKey: dateKey,
                  );
              switch (scheduleResult) {
                case Ok():
                  scheduledDays++;
                  break;
                case Error():
                  _log.warning(
                    'Failed to schedule notifications for $dateKey: ${scheduleResult.asError.error}',
                  );
              }
            }
          }

          _log.info('Scheduled notifications for $scheduledDays days');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Error getting prayer times locally: ${localResult.asError.error}',
          );
          return Result.error(localResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception scheduling notifications for month: $e');
      return Result.error(Exception('Aylık bildirimler planlanamadı: $e'));
    }
  }

  /// Tüm bildirimleri yeniden planlar (namaz vakitleri güncellendiğinde)
  /// Haftalık planlama yapar (7 gün)
  Future<Result<void>> rescheduleAll({
    required String districtId,
    required String city,
    required String country,
  }) async {
    try {
      _log.info('Rescheduling all prayer notifications (weekly)');
      // scheduleForWeek zaten önce iptal ediyor, sonra planlıyor
      return await scheduleForWeek(
        districtId: districtId,
        city: city,
        country: country,
      );
    } catch (e) {
      _log.severe('Exception rescheduling all notifications: $e');
      return Result.error(Exception('Bildirimler yeniden planlanamadı: $e'));
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
