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

  /// get prayer times.(cache-first)
  /// 1. check if the prayer times are in the local storage.
  /// 2. if they are, return them.
  /// 3. if they are not, check if the internet connection is available.
  /// 4. if available, fetch the prayer times from the remote and save them to local.
  /// 5. return them.
  Future<Result<PrayerTimes?>> getPrayerTimes({
    required String districtId,
    required String city,
    required String country,
    required String userId,
  }) async {
    try {
      if (districtId.isEmpty || city.isEmpty || country.isEmpty) {
        _log.warning('Empty parameters provided for prayer times');
        return Result.error(const UserMessageException('Lütfen konum bilgilerini seçiniz'));
      }
      _log.info(
        'Getting prayer times for district: $districtId, city: $city, country: $country',
      );
      final localResult = await _prayerRepository.getPrayerTimesLocally(
        districtId: districtId,
        city: city,
        country: country,
      );
      switch (localResult) {
        case Ok():
          final prayer = localResult.asOk.value;
          if (prayer != null) {
            final todayTimes = prayer.getTodayPrayerTimes();
            if (todayTimes != null) {
              _log.info('Found prayer times in local storage');
              return Result.ok(todayTimes);
            }
            _log.info('Prayer times found but today\'s times are missing');
          }
          break;
        case Error():
          _log.warning(
            'Error getting prayer times locally: ${localResult.asError.error}',
          );
          break;
      }

      final connectivityResult = await _connectivityUseCase.connectionType();
      switch (connectivityResult) {
        case Ok():
          if (connectivityResult.asOk.value == ConnectivityEnum.none) {
            _log.severe('No internet connection');
            return Result.error(
              const UserMessageException(
                'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.',
              ),
            );
          }
          break;
        case Error():
          _log.warning('Could not check connectivity, proceeding anyway...');
          break;
      }

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
                break;
            }

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
                break;
            }

            final todayTimes = prayer.getTodayPrayerTimes();
            if (todayTimes != null) {
              _log.info('Successfully fetched prayer times from API');
              return Result.ok(todayTimes);
            }
            return Result.error(
              const UserMessageException('Bugünün namaz vakitleri bulunamadı'),
            );
          }
          return Result.error(const UserMessageException('Namaz vakitleri bulunamadı'));
        case Error():
          _log.severe(
            'Error getting prayer times from remote: ${remoteResult.asError.error}',
          );
          return Result.error(remoteResult.asError.error);
      }
    } catch (e) {
      _log.severe('Exception getting prayer times: $e');
      return Result.error(
        UserMessageException('Namaz vakitleri alınırken hata oluştu', cause: e),
      );
    }
  }
}
