import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PrayerTimesViewModel {
  PrayerTimesViewModel({
    required PrayerTimeUseCase prayerTimeUseCase,
    required AppRepository appRepository,
  }) : _prayerTimeUseCase = prayerTimeUseCase,
       _appRepository = appRepository,
       _isNotificationsEnabled = ValueNotifier<bool>(
         appRepository.appPreferences.value.isNotificationsEnabled,
       ) {
    // DEFINE COMMANDS
    getPrayerTimes =
        Command1<
          void,
          ({String districtId, String city, String country, String userId})
        >(_getPrayerTimes, debugLabel: 'getPrayerTimes');

    // DEFINE LISTENERS
    _appRepository.appPreferences.addListener(_onAppPreferencesChanged);
  }

  // LOGGER
  final _log = Logger('PrayerTimesViewModel');

  // REPOSITORIES & USE CASES
  final PrayerTimeUseCase _prayerTimeUseCase;
  final AppRepository _appRepository;
  // STATE (ValueNotifiers)
  ValueListenable<PrayerTimes?> get prayerTimes => _prayerTimes;
  final ValueNotifier<PrayerTimes?> _prayerTimes = ValueNotifier<PrayerTimes?>(
    null,
  );
  ValueListenable<bool> get isNotificationsEnabled => _isNotificationsEnabled;
  final ValueNotifier<bool> _isNotificationsEnabled;

  // COMMANDS
  late final Command1<
    void,
    ({String districtId, String city, String country, String userId})
  >
  getPrayerTimes;

  // DISPOSE
  void dispose() {
    getPrayerTimes.dispose();
    _prayerTimes.dispose();
    _isNotificationsEnabled.dispose();
    _appRepository.appPreferences.removeListener(_onAppPreferencesChanged);
    _log.fine('PrayerTimesViewModel Disposed');
  }

  // FUNCTIONS

  Future<Result<void>> _getPrayerTimes(
    ({String districtId, String city, String country, String userId}) params,
  ) async {
    final result = await _prayerTimeUseCase.getPrayerTimes(
      districtId: params.districtId,
      city: params.city,
      country: params.country,
      userId: params.userId,
    );

    switch (result) {
      case Ok():
        _prayerTimes.value = result.asOk.value;
        return Result.ok(null);
      case Error():
        // Hata durumunda state'i temizle
        _prayerTimes.value = null;
        return Result.error(result.asError.error);
    }
  }

  void _onAppPreferencesChanged() {
    _isNotificationsEnabled.value =
        _appRepository.appPreferences.value.isNotificationsEnabled;
  }
}
