import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class SchedulePrayerNotificationsUseCase {
  SchedulePrayerNotificationsUseCase({
    required PrayerRepository prayerRepository,
    required NotificationRepository notificationRepository,
    required UserRepository userRepository,
  }) : _prayerRepository = prayerRepository,
       _notificationRepository = notificationRepository,
       _userRepository = userRepository,
       _log = Logger('SchedulePrayerNotificationsUseCase');

  final PrayerRepository _prayerRepository;
  final NotificationRepository _notificationRepository;
  final UserRepository _userRepository;
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  final Logger _log;

  /// Bir haftalık bildirim planlar
  /// Önce tüm eski namaz bildirimlerini iptal eder, sonra önümüzdeki 7 gün (bugün dahil) için yeni bildirimleri planlar
  Future<Result<bool>> scheduleForWeek() async {
    final user = currentUser.value;
    final districtId = user.districtId;
    final city = user.city;
    final country = user.country;
    if (districtId == null ||
        districtId.isEmpty ||
        city == null ||
        city.isEmpty ||
        country == null ||
        country.isEmpty) {
      return Result.ok(false);
    }
    try {
      _log.info('Scheduling notifications for week (7 days including today)');
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
            return Result.error(const UserMessageException('Namaz vakitleri bulunamadı'));
          }

          final now = DateTime.now();
          // schedule for next 7 days
          int scheduledDays = 0;
          int totalNotifications = 0;
          for (int i = 0; i < 7; i++) {
            final targetDate = DateTime(now.year, now.month, now.day + i);
            final dateKey = Prayer.formatDate(targetDate);
            final prayerTimes = prayer.getPrayerTimesForDate(dateKey);
            if (prayerTimes != null) {
              // schedule for each prayer time
              final prayers = [
                (name: 'İmsak', time: prayerTimes.fajr),
                (name: 'Öğle', time: prayerTimes.dhuhr),
                (name: 'İkindi', time: prayerTimes.asr),
                (name: 'Akşam', time: prayerTimes.maghrib),
                (name: 'Yatsı', time: prayerTimes.isha),
              ];

              int dayNotifications = 0;
              for (final prayerItem in prayers) {
                // skip past prayer times
                if (prayerItem.time.isAfter(now)) {
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
      return Result.error(UserMessageException('Haftalık bildirimler planlanamadı', cause: e));
    }
  }

  /// cancel all prayer notifications
  Future<Result<void>> cancelAll() async {
    try {
      _log.info('Cancelling all prayer notifications');
      return await _notificationRepository.cancelAllPrayerNotifications();
    } catch (e) {
      _log.severe('Exception cancelling all notifications: $e');
      return Result.error(UserMessageException('Bildirimler iptal edilemedi', cause: e));
    }
  }
}
