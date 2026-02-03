import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';

class VibrationUseCase {
  VibrationUseCase();

  static Future<void> vibrateLight(BuildContext context) async {
    final appRepository = context.read<AppRepository>();
    final appPreferences = appRepository.appPreferences;
    if (!appPreferences.value.isVibrationEnabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> vibrateMedium(BuildContext context) async {
    final appRepository = context.read<AppRepository>();
    final appPreferences = appRepository.appPreferences;
    if (!appPreferences.value.isVibrationEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> vibrateHigh(BuildContext context) async {
    final appRepository = context.read<AppRepository>();
    final appPreferences = appRepository.appPreferences;
    if (!appPreferences.value.isVibrationEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selectionClick(BuildContext context) async {
    final appRepository = context.read<AppRepository>();
    final appPreferences = appRepository.appPreferences;
    if (!appPreferences.value.isVibrationEnabled) return;
    await HapticFeedback.selectionClick();
  }
}
