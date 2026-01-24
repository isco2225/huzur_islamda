import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../data.dart';

/// Remote implementation of PrayerRepository
///
/// Handles both local (Hive) and remote (API) operations
class PrayerRepositoryRemote implements PrayerRepository {
  PrayerRepositoryRemote({
    required HiveService<Prayer> hiveService,
    required PrayerService prayerService,
  }) : _hiveService = hiveService,
       _prayerService = prayerService,
       _log = Logger('PrayerRepositoryRemote');

  final HiveService<Prayer> _hiveService;
  final PrayerService _prayerService;
  final Logger _log;

  /// Key oluşturma helper'ı
  /// Format: "prayer_{year}_{districtId}"
  String _generateKey(int year, String districtId) {
    return 'prayer_${year}_$districtId';
  }

  // ========== LOCAL OPERATIONS (HIVE) ==========

  @override
  Future<Result<Prayer?>> getPrayerTimesLocally({
    required String districtId,
    required String city,
    required String country,
  }) async {
    try {
      _log.info('Getting prayer times locally for district: $districtId');
      final now = DateTime.now();
      final key = _generateKey(now.year, districtId);

      final result = await _hiveService.getById(key);

      switch (result) {
        case Ok():
          final prayer = result.asOk.value;
          // Eğer bulunduysa ve location eşleşiyorsa döndür
          if (prayer != null &&
              prayer.districtId == districtId &&
              prayer.city == city &&
              prayer.country == country) {
            _log.info('Found prayer times in local storage');
            return Result.ok(prayer);
          }
          _log.info('Prayer times not found or location mismatch');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Error getting prayer times locally: ${result.asError.error}',
          );
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Exception getting prayer times locally: $e');
      return Result.error(Exception('Failed to get prayer times locally: $e'));
    }
  }

  @override
  Future<Result<void>> savePrayerTimesLocally({required Prayer prayer}) async {
    try {
      _log.info('Saving prayer times locally: ${prayer.id}');

      final key = _generateKey(prayer.year, prayer.districtId);
      final result = await _hiveService.save(key, prayer);

      switch (result) {
        case Ok():
          _log.info('Successfully saved prayer times locally');
          return Result.ok(null);
        case Error():
          _log.severe(
            'Error saving prayer times locally: ${result.asError.error}',
          );
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Exception saving prayer times locally: $e');
      return Result.error(Exception('Failed to save prayer times locally: $e'));
    }
  }

  @override
  Future<Result<void>> clearOldPrayerTimes({
    required String currentDistrictId,
    required String userId,
  }) async {
    try {
      _log.info(
        'Clearing old prayer times for user: $userId, current district: $currentDistrictId',
      );

      // Tüm prayer kayıtlarını al
      final allPrayersResult = await _hiveService.getAll();

      switch (allPrayersResult) {
        case Ok():
          final allPrayers = allPrayersResult.asOk.value;

          // Kullanıcıya ait ve farklı districtId'ye sahip olanları bul
          final prayersToDelete = allPrayers
              .where(
                (prayer) =>
                    prayer.userId == userId &&
                    prayer.districtId != currentDistrictId,
              )
              .toList();

          if (prayersToDelete.isEmpty) {
            _log.info('No old prayer times to clear');
            return Result.ok(null);
          }

          // Key'leri oluştur ve sil
          final keysToDelete = prayersToDelete
              .map((prayer) => _generateKey(prayer.year, prayer.districtId))
              .toList();

          final deleteResult = await _hiveService.deleteMany(keysToDelete);

          switch (deleteResult) {
            case Ok():
              _log.info(
                'Successfully cleared ${prayersToDelete.length} old prayer times',
              );
              return Result.ok(null);
            case Error():
              _log.severe(
                'Error clearing old prayer times: ${deleteResult.asError.error}',
              );
              return Result.error(deleteResult.asError.error);
          }
        case Error():
          _log.severe(
            'Error getting all prayers: ${allPrayersResult.asError.error}',
          );
          return Result.error(allPrayersResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception clearing old prayer times: $e');
      return Result.error(Exception('Failed to clear old prayer times: $e'));
    }
  }

  // ========== REMOTE OPERATIONS (API) ==========

  @override
  Future<Result<Prayer?>> getPrayerTimesFromRemote({
    required String districtId,
    required String city,
    required String country,
    required String userId,
  }) async {
    try {
      _log.info('Getting prayer times from remote for district: $districtId');

      // API'den veriyi çek
      final apiResult = await _prayerService.getPrayerTimes(
        districtId: districtId,
      );

      switch (apiResult) {
        case Ok():
          final apiJson = apiResult.asOk.value;

          // Prayer.fromApiJson ile parse et
          final prayer = Prayer.fromApiJson(
            apiJson,
            userId,
            districtId,
            city,
            country,
          );

          _log.info('Successfully fetched prayer times from remote');
          return Result.ok(prayer);
        case Error():
          _log.severe(
            'Error getting prayer times from remote: ${apiResult.asError.error}',
          );
          return Result.error(apiResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception getting prayer times from remote: $e');
      return Result.error(
        Exception('Failed to get prayer times from remote: $e'),
      );
    }
  }
}
