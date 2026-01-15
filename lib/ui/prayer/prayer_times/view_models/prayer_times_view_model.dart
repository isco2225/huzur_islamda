import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class PrayerTimesViewModel {
  PrayerTimesViewModel({required PrayerTimeUseCase prayerTimeUseCase})
    : _prayerTimeUseCase = prayerTimeUseCase {
    // DEFINE COMMANDS
    getPrayerTimes =
        Command1<
          void,
          ({String districtId, String city, String country, String userId})
        >(_getPrayerTimes, debugLabel: 'getPrayerTimes');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('PrayerTimesViewModel');

  // REPOSITORIES & USE CASES
  final PrayerTimeUseCase _prayerTimeUseCase;

  // STATE (ValueNotifiers)
  /// Bugünün namaz vakitleri
  ValueListenable<PrayerTimes?> get prayerTimes => _prayerTimes;
  final ValueNotifier<PrayerTimes?> _prayerTimes = ValueNotifier<PrayerTimes?>(
    null,
  );

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
        // Use case'den dönen PrayerTimes'ı state'e set et
        _prayerTimes.value = result.asOk.value;
        return Result.ok(null);
      case Error():
        // Hata durumunda state'i temizle
        _prayerTimes.value = null;
        return Result.error(result.asError.error);
    }
  }
}
