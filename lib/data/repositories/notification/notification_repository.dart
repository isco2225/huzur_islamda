import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class NotificationRepository {
  /// Namaz vakti bildirimi planlar
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey, // Format: "YYYY-MM-DD"
  });

  /// Tüm namaz bildirimlerini iptal eder
  Future<Result<void>> cancelAllPrayerNotifications();

  /// Tüm namaz bildirimlerini yeniden planlar
  /// Önce tüm bildirimleri iptal eder, sonra yeni vakitler için planlar
  Future<Result<void>> rescheduleAllPrayerNotifications({
    required PrayerTimes prayerTimes,
    required String dateKey, // Format: "YYYY-MM-DD"
  });
}
