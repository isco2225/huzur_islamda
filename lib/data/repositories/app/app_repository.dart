import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class AppRepository {
  ValueListenable<AppPreferences> get appPreferences;
  Future<Result<AppPreferences>> getPreferences();
  Future<Result<void>> updateIsVibrationEnabled({
    required bool isVibrationEnabled,
  });
  Future<Result<void>> updateIsNotificationsEnabled({
    required bool isNotificationsEnabled,
  });

  Future<Result<void>> updateIsOnboardingCompleted({
    required bool isOnboardingCompleted,
  });
  Future<Result<void>> updateAssistantDailyLimit({
    required int updatedDailyLimit,
  });
  Future<Result<void>> resetAssistantDailyLimit();
}
