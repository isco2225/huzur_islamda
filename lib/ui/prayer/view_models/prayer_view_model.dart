import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../data/data.dart';

class PrayerViewModel {
  PrayerViewModel({required AppRepository appRepository})
    : _appRepository = appRepository,
      _isNotificationsEnabled = ValueNotifier<bool>(
        appRepository.appPreferences.value.isNotificationsEnabled,
      ) {
    // DEFINE COMMANDS

    // DEFINE LISTENERS
    _appRepository.appPreferences.addListener(_onAppPreferencesChanged);
  }

  // LOGGER
  final _log = Logger('PrayerViewModel');

  // REPOSITORIES & USE CASES
  final AppRepository _appRepository;
  // DOMAIN
  ValueListenable<bool> get isNotificationsEnabled => _isNotificationsEnabled;
  final ValueNotifier<bool> _isNotificationsEnabled;
  // COMMANDS

  // DISPOSE
  void dispose() {
    _appRepository.appPreferences.removeListener(_onAppPreferencesChanged);
    _isNotificationsEnabled.dispose();
    _log.fine('PrayerViewModel Disposed');
  }

  // FUNCTIONS
  void _onAppPreferencesChanged() {
    _isNotificationsEnabled.value =
        _appRepository.appPreferences.value.isNotificationsEnabled;
  }
}
