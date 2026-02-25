import '../../../app/app.dart';

abstract class NotificationRepository {
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey, // Format: "YYYY-MM-DD"
  });

  /// Schedule a daily dhikr reminder for the given user and day.
  Future<Result<void>> scheduleDhikrCompletionReminderNotification({
    required String userId,
    required DateTime day,
  });

  /// Schedule a dhikr reminder notification for creating a dhikr for the given user and day.
  Future<Result<void>> scheduleDhikrCreationReminderNotification({
    required String userId,
    required DateTime day,
    required String userName,
  });

  /// Cancel all prayer notifications
  Future<Result<void>> cancelAllPrayerNotifications();

  /// Cancel all notifications scheduled by the app
  Future<Result<void>> cancelAllNotifications();

  /// Cancel all dhikr creation reminder notifications
  Future<Result<void>> cancelDhikrCreationReminderNotifications();

  /// Cancel today's dhikr reminder notifications
  Future<Result<void>> cancelTodayDhikrNotifications({required String userId});

  /// Cancel dhikr reminder notification for a specific day
  Future<Result<void>> cancelDhikrReminderNotification({
    required String userId,
    required DateTime day,
  });
}
