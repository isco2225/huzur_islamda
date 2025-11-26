import 'package:flutter/foundation.dart';

class SettingsViewModel {
  SettingsViewModel() {
    // DEFINE COMMANDS
    // TODO: Add commands here

    // DEFINE LISTENERS
  }

  // STATE
  final ValueNotifier<bool> isNotificationsEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isVibrationEnabled = ValueNotifier<bool>(true);

  // ACTIONS
  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
  }

  void toggleVibration(bool value) {
    isVibrationEnabled.value = value;
  }

  // DISPOSE
  void dispose() {
    isNotificationsEnabled.dispose();
    isVibrationEnabled.dispose();
  }
}
