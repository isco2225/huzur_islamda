import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';

class AdMobService {
  AdMobService() : _log = Logger('AdMobService');

  final Logger _log;
  bool _isInitialized = false;

  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      _log.info('AdMob service already initialized');
      return Result.ok(null);
    }
    try {
      _log.info('Initializing AdMob service...');
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _log.info('AdMob service initialized successfully');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Error initializing AdMob service: $e');
      return Result.error(Exception('AdMob servisi başlatılamadı: $e'));
    }
  }

  /// Platform'a göre banner ad unit ID'yi döndürür
  String getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return AppAdIds.bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppAdIds.bannerAdUnitIdIOS;
    } else {
      _log.warning('Unsupported platform, using Android ad unit ID');
      return AppAdIds.bannerAdUnitIdAndroid;
    }
  }

  AdRequest createAdRequest() {
    return const AdRequest();
  }
}
