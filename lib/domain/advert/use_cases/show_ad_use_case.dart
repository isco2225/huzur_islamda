import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class ShowAdUseCase {
  ShowAdUseCase({
    required AdMobService admobService,
    required UserRepository userRepository,
  }) : _admobService = admobService,
       _userRepository = userRepository;

  final Logger _log = Logger('ShowInterstitialAdUseCase');
  final AdMobService _admobService;
  final UserRepository _userRepository;

  ValueListenable<User> get currentUser => _userRepository.currentUser;

  Future<void> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
    void Function()? onAdFailedToLoad,
  }) async {
    _log.info('Showing interstitial ad');
    // check if user is premium
    if (currentUser.value.isPremium) {
      _log.info('User is premium, skipping ad');
      return;
    }
    await _admobService.showInterstitialAd(
      onAdDismissed: onAdDismissed,
      onAdFailedToShow: onAdFailedToShow,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  String getBannerAdUnitId() {
    _log.info('Getting banner ad unit ID');
    return _admobService.getBannerAdUnitId();
  }

  AdRequest createBannerAdRequest() {
    _log.info('Creating banner ad request');
    return _admobService.createAdRequest();
  }

  String getNativeAdUnitId() {
    return _admobService.getNativeAdUnitId();
  }

  Future<Result<NativeAd>> loadNativeAd() async {
    return _admobService.loadNativeAd();
  }
}
