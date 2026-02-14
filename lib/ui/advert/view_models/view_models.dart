import 'package:flutter/foundation.dart';

import '../../../data/data.dart';

/// AdMob init durumunu AdMobService'ten expose eder.
/// Init AppScreen'deki _DeferredAdMobInit ile tek sefer yapılır; tüm ekranlar aynı isInitialized'i dinler.
class AdvertViewModel {
  AdvertViewModel({required AdMobService admobService})
      : _admobService = admobService;

  final AdMobService _admobService;

  ValueListenable<bool> get isAdMobInitialized => _admobService.isInitialized;

  void dispose() {}
}
