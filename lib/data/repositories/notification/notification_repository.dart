import '../../../app/app.dart';

abstract class NotificationRepository {
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey, // Format: "YYYY-MM-DD"
  });

  /// Schedule a daily dhikr reminder for the given user and day.
  Future<Result<void>> scheduleDhikrReminderNotification({
    required String userId,
    required DateTime day,
  });

  /// Cancel all prayer notifications
  Future<Result<void>> cancelAllPrayerNotifications();

  /// Cancel today's dhikr reminder notifications
  Future<Result<void>> cancelTodayDhikrNotifications({required String userId});
}
