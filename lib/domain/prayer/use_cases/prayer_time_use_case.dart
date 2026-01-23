import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class PrayerTimeUseCase {
  PrayerTimeUseCase({
    required PrayerRepository prayerRepository,
    required ConnectivityUseCase connectivityUseCase,
  }) : _prayerRepository = prayerRepository,
       _connectivityUseCase = connectivityUseCase,
       _log = Logger('PrayerTimeUseCase');

  final PrayerRepository _prayerRepository;
  final ConnectivityUseCase _connectivityUseCase;
  final Logger _log;

  /// Namaz vakitlerini getirir (cache-first stratejisi)
  ///
  /// 1. Önce Hive'dan kontrol eder (o yıl için veri var mı?)
  /// 2. Varsa ve güncel ise → Hive'dan getirir
  /// 3. Yoksa veya eski ise → API'den çeker, eski vakitleri temizler, Hive'a kaydeder
  /// 4. Bugünün vakitlerini döndürür
  Future<Result<PrayerTimes?>> getPrayerTimes({
    required String districtId,
    required String city,
    required String country,
    required String userId,
  }) async {
    try {
      // Boş parametre kontrolü
      if (districtId.isEmpty || city.isEmpty || country.isEmpty) {
        _log.warning('Empty parameters provided for prayer times');
        return Result.error(Exception('Lütfen konum bilgilerini seçiniz'));
      }
      _log.info(
        'Getting prayer times for district: $districtId, city: $city, country: $country',
      );

      // 1. Önce Hive'dan kontrol et
      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
      );

      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer != null) {
            // Hive'da güncel veri var, bugünün vakitlerini döndür
            final todayTimes = prayer.getTodayPrayerTimes();
            if (todayTimes != null) {
              _log.info('Found prayer times in local storage');
              return Result.ok(todayTimes);
            }
            _log.info('Prayer times found but today\'s times are missing');
          }
          // Hive'da yok veya eski yıl, API'den çek
          break;
        case Error():
          _log.warning(
            'Error getting prayer times locally: ${localResult.asError.error}',
          );
          // Hive hatası, API'den çek
          break;
      }

      // 2. İnternet bağlantısını kontrol et
      final connectivityResult = await _connectivityUseCase.connectionType();
      switch (connectivityResult) {
        case Ok():
          if (connectivityResult.asOk.value == ConnectivityEnum.none) {
            _log.severe('No internet connection');
            return Result.error(
              Exception(
                'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.',
              ),
            );
          }
          break;
        case Error():
          _log.warning('Could not check connectivity, proceeding anyway...');
          break;
      }

      // 3. API'den yıllık veriyi çek
      _log.info('Fetching prayer times from API...');
      final remoteResult = await _prayerRepository.getPrayerTimesFromRemote(
        districtId: districtId,
        city: city,
        country: country,
        userId: userId,
      );

      switch (remoteResult) {
        case Ok():
          final prayer = remoteResult.asOk.value;
          if (prayer != null) {
            // 4. Eski vakitleri temizle (farklı districtId'ye sahip olanlar)
            final clearResult = await _prayerRepository.clearOldPrayerTimes(
              currentDistrictId: districtId,
              userId: userId,
            );

            switch (clearResult) {
              case Ok():
                _log.info('Old prayer times cleared successfully');
                break;
              case Error():
                _log.warning(
                  'Error clearing old prayer times: ${clearResult.asError.error}',
                );
                // Hata olsa bile devam et
                break;
            }

            // 5. Hive'a kaydet
            final saveResult = await _prayerRepository.savePrayerTimesLocally(
              prayer: prayer,
            );

            switch (saveResult) {
              case Ok():
                _log.info('Prayer times saved to local storage');
                break;
              case Error():
                _log.warning(
                  'Error saving prayer times locally: ${saveResult.asError.error}',
                );
                // Hata olsa bile devam et
                break;
            }

            // 6. Bugünün vakitlerini döndür
            final todayTimes = prayer.getTodayPrayerTimes();
            if (todayTimes != null) {
              _log.info('Successfully fetched prayer times from API');
              return Result.ok(todayTimes);
            }
            return Result.error(
              Exception('Bugünün namaz vakitleri bulunamadı'),
            );
          }
          return Result.error(Exception('Namaz vakitleri bulunamadı'));
        case Error():
          _log.severe(
            'Error getting prayer times from remote: ${remoteResult.asError.error}',
          );
          return Result.error(remoteResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception getting prayer times: $e');
      return Result.error(
        Exception('Namaz vakitleri alınırken hata oluştu: $e'),
      );
    }
  }
}
