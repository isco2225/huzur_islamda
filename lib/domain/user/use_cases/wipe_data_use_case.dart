import '../../../app/app.dart';
import '../../../data/data.dart';

/// Kullanıcı çıkış yaparken veya hesap silinirken tüm kullanıcıya özel verileri temizler
class WipeDataUseCase {
  WipeDataUseCase({
    required DhikrRepository dhikrRepository,
    required PrayerRepository prayerRepository,
    required UserRepository userRepository,
    required NotificationRepository notificationRepository,
  }) : _dhikrRepository = dhikrRepository,
       _prayerRepository = prayerRepository,
       _userRepository = userRepository,
       _notificationRepository = notificationRepository;

  final DhikrRepository _dhikrRepository;
  final PrayerRepository _prayerRepository;
  final UserRepository _userRepository;
  final NotificationRepository _notificationRepository;

  Future<Result<void>> wipeData() async {
    try {
      final dhikrResult = await _dhikrRepository.clearAllDhikrsLocally();
      switch (dhikrResult) {
        case Ok():
          break;
        case Error():
          return Result.error(dhikrResult.asError.error);
      }
      final prayerResult = await _prayerRepository.clearAllPrayerTimesLocally();
      switch (prayerResult) {
        case Ok():
          break;
        case Error():
          return Result.error(prayerResult.asError.error);
      }
      final notificationResult = await _notificationRepository
          .cancelAllPrayerNotifications();
      switch (notificationResult) {
        case Ok():
          break;
        case Error():
          return Result.error(notificationResult.asError.error);
      }
      _userRepository.wipeUser();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to wipe data: $e'));
    }
  }
}
