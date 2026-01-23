import '../../../app/app.dart';

abstract class NotificationRepository {
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey, // Format: "YYYY-MM-DD"
  });

  /// Cancel all prayer notifications
  Future<Result<void>> cancelAllPrayerNotifications();
}
