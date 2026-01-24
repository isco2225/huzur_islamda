import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class PrayerRepository {
  // Local operations
  Future<Result<Prayer?>> getPrayerTimesLocally({
    required String districtId,
    required String city,
    required String country,
  });
  Future<Result<void>> savePrayerTimesLocally({required Prayer prayer});

  /// Kullanıcının seçtiği yeni konum için eski vakitleri temizler
  /// Sadece farklı districtId'ye sahip vakitleri siler
  Future<Result<void>> clearOldPrayerTimes({
    required String currentDistrictId,
    required String userId,
  });

  // Remote operations
  Future<Result<Prayer?>> getPrayerTimesFromRemote({
    required String districtId,
    required String city,
    required String country,
    required String userId,
  });
}
