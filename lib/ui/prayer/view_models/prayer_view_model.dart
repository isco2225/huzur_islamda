import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

class PrayerViewModel {
  PrayerViewModel({
    required AppRepository appRepository,
    required SchedulePrayerNotificationsUseCase
    schedulePrayerNotificationsUseCase,
  }) : _appRepository = appRepository,
       _schedulePrayerNotificationsUseCase = schedulePrayerNotificationsUseCase,
       _isNotificationsEnabled = ValueNotifier<bool>(
         appRepository.appPreferences.value.isNotificationsEnabled,
       ) {
    // DEFINE COMMANDS
    schedulePrayerNotifications = Command0(
      _schedulePrayerNotifications,
      debugLabel: 'PrayerViewModel.schedulePrayerNotifications',
    );
    // DEFINE LISTENERS
    _appRepository.appPreferences.addListener(_onAppPreferencesChanged);
  }

  // LOGGER
  final _log = Logger('PrayerViewModel');

  // REPOSITORIES & USE CASES
  final AppRepository _appRepository;
  final SchedulePrayerNotificationsUseCase _schedulePrayerNotificationsUseCase;
  // DOMAIN
  ValueListenable<bool> get isNotificationsEnabled => _isNotificationsEnabled;
  final ValueNotifier<bool> _isNotificationsEnabled;
  // COMMANDS
  late Command0<void> schedulePrayerNotifications;

  // DISPOSE
  void dispose() {
    schedulePrayerNotifications.dispose();
    _appRepository.appPreferences.removeListener(_onAppPreferencesChanged);
    _isNotificationsEnabled.dispose();
    _log.fine('PrayerViewModel Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _schedulePrayerNotifications() async {
    if (!_isNotificationsEnabled.value) {
      return Result.ok(null);
    }
    final result = await _schedulePrayerNotificationsUseCase.scheduleForWeek();
    return result;
  }

  void _onAppPreferencesChanged() {
    _isNotificationsEnabled.value =
        _appRepository.appPreferences.value.isNotificationsEnabled;
  }
}
