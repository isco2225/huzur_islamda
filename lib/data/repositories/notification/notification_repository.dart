import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class NotificationRepository {
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey, // Format: "YYYY-MM-DD"
  });

  /// Cancel all prayer notifications
  Future<Result<void>> cancelAllPrayerNotifications();

  /// Reschedule all prayer notifications
  /// First cancel all notifications, then schedule new times
  Future<Result<void>> rescheduleAllPrayerNotifications({
    required PrayerTimes prayerTimes,
    required String dateKey, // Format: "YYYY-MM-DD"
  });
}
