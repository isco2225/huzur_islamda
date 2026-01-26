import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import '../../../data/data.dart';

class ShowAdUseCase {
  ShowAdUseCase({required AdMobService admobService})
    : _admobService = admobService;

  final Logger _log = Logger('ShowInterstitialAdUseCase');
  final AdMobService _admobService;

  /// Interstitial ad gösterir
  /// InterstitialAd.show() metodu BuildContext gerektirmez
  /// Ad kapatıldığında veya hata olduğunda pop yapmaz (UI katmanında yapılmalı)
  ///
  /// [context] - Reklam gösterimi için BuildContext (opsiyonel, ad show() için gerekli değil)
  /// [onAdDismissed] - Ad kapatıldığında çağrılacak opsiyonel callback
  /// [onAdFailedToShow] - Ad gösterilemediğinde çağrılacak opsiyonel callback
  /// [onAdFailedToLoad] - Ad yüklenemediğinde çağrılacak opsiyonel callback
  Future<void> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
    void Function()? onAdFailedToLoad,
  }) async {
    _log.info('Showing interstitial ad');
    await _admobService.showInterstitialAd(
      onAdDismissed: onAdDismissed,
      onAdFailedToShow: onAdFailedToShow,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  /// Banner ad unit ID'yi döndürür
  /// Banner ad widget'ları için ad unit ID sağlar
  String getBannerAdUnitId() {
    _log.info('Getting banner ad unit ID');
    return _admobService.getBannerAdUnitId();
  }

  /// Banner ad request oluşturur
  /// Banner ad widget'ları için AdRequest sağlar
  AdRequest createBannerAdRequest() {
    _log.info('Creating banner ad request');
    return _admobService.createAdRequest();
  }
}
