import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';

class AdMobService {
  AdMobService() : _log = Logger('AdMobService');

  final Logger _log;
  bool _isInitialized = false;
  final ValueNotifier<bool> _isInitializedNotifier = ValueNotifier<bool>(false);

  /// Dinlenebilir init durumu; tüm ekranlar aynı kaynağı kullanır.
  ValueListenable<bool> get isInitialized => _isInitializedNotifier;

  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      _log.info('AdMob service already initialized');
      return Result.ok(null);
    }
    try {
      _log.info('Initializing AdMob service...');
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _isInitializedNotifier.value = true;
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

  /// Platform'a göre interstitial ad unit ID'yi döndürür
  String getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return AppAdIds.interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppAdIds.interstitialAdUnitIdIOS;
    } else {
      _log.warning('Unsupported platform, using Android ad unit ID');
      return AppAdIds.interstitialAdUnitIdAndroid;
    }
  }

  /// Platform'a göre Native Advanced (template) ad unit ID'yi döndürür
  String getNativeAdUnitId() {
    if (Platform.isAndroid) {
      return AppAdIds.nativeAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppAdIds.nativeAdUnitIdIOS;
    } else {
      _log.warning('Unsupported platform, using Android native ad unit ID');
      return AppAdIds.nativeAdUnitIdAndroid;
    }
  }

  AdRequest createAdRequest() {
    return const AdRequest();
  }

  /// Native Advanced (template) reklam yükler. Yüklenen reklamı [AdWidget] ile gösterebilirsiniz.
  /// Kullanım bitince [NativeAd.dispose] çağrılmalı.
  Future<Result<NativeAd>> loadNativeAd() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult case Error()) {
          return Result.error(initResult.asError.error);
        }
      }
      final adUnitId = getNativeAdUnitId();
      if (adUnitId.isEmpty) {
        return Result.error(Exception('Native ad unit ID bulunamadı'));
      }
      final completer = Completer<Result<NativeAd>>();
      final nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: createAdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _log.info('Native ad loaded successfully');
            if (!completer.isCompleted) {
              completer.complete(Result.ok(ad as NativeAd));
            }
          },
          onAdFailedToLoad: (ad, error) {
            _log.warning('Native ad failed to load: ${error.message}');
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete(
                Result.error(
                  Exception('Native ad yüklenemedi: ${error.message}'),
                ),
              );
            }
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          cornerRadius: 10.0,
        ),
      );
      nativeAd.load();
      return await completer.future;
    } catch (e) {
      _log.severe('Error loading native ad: $e');
      return Result.error(Exception('Native ad yüklenemedi: $e'));
    }
  }

  /// Interstitial ad yükler
  Future<Result<InterstitialAd>> loadInterstitialAd({
    required void Function() onAdDismissed,
    void Function()? onAdFailedToShow,
  }) async {
    try {
      final adUnitId = getInterstitialAdUnitId();
      if (adUnitId.isEmpty) {
        _log.warning('Interstitial ad unit ID is empty');
        return Result.error(Exception('Interstitial ad unit ID bulunamadı'));
      }

      _log.info('Loading interstitial ad with unit ID: $adUnitId');

      final completer = Completer<Result<InterstitialAd>>();
      final adRequest = createAdRequest();

      InterstitialAd.load(
        adUnitId: adUnitId,
        request: adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _log.info('Interstitial ad loaded successfully');
            // Ad kapatıldığında dispose et ve callback çağır
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _log.info('Interstitial ad dismissed');
                ad.dispose();
                onAdDismissed();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _log.warning(
                  'Interstitial ad failed to show: ${error.message}',
                );
                ad.dispose();
                onAdFailedToShow?.call();
              },
              onAdShowedFullScreenContent: (_) {
                _log.info('Interstitial ad showed');
              },
            );
            if (!completer.isCompleted) {
              completer.complete(Result.ok(ad));
            }
          },
          onAdFailedToLoad: (error) {
            _log.warning('Interstitial ad failed to load: ${error.message}');
            if (!completer.isCompleted) {
              completer.complete(
                Result.error(
                  Exception('Interstitial ad yüklenemedi: ${error.message}'),
                ),
              );
            }
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      _log.severe('Error loading interstitial ad: $e');
      return Result.error(Exception('Interstitial ad yüklenemedi: $e'));
    }
  }

  /// Interstitial ad yükler ve gösterir
  /// Ad kapatıldığında veya hata olduğunda pop yapmaz (UI katmanında yapılmalı)
  ///
  /// [onAdDismissed] - Ad kapatıldığında çağrılacak opsiyonel callback
  /// [onAdFailedToShow] - Ad gösterilemediğinde çağrılacak opsiyonel callback
  /// [onAdFailedToLoad] - Ad yüklenemediğinde çağrılacak opsiyonel callback
  Future<void> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
    void Function()? onAdFailedToLoad,
  }) async {
    Timer? disposeFallbackTimer;
    try {
      final loadResult = await loadInterstitialAd(
        onAdDismissed: () {
          disposeFallbackTimer?.cancel();
          onAdDismissed?.call();
        },
        onAdFailedToShow: () {
          disposeFallbackTimer?.cancel();
          onAdFailedToShow?.call();
        },
      );

      switch (loadResult) {
        case Ok<InterstitialAd>():
          final interstitialAd = loadResult.asOk.value;
          try {
            interstitialAd.show();
            disposeFallbackTimer = Timer(const Duration(minutes: 2), () {
              try {
                interstitialAd.dispose();
                _log.warning(
                  'Interstitial ad was not disposed via callback, forcing dispose',
                );
              } catch (e) {
                _log.fine('Interstitial ad already disposed or error: $e');
              }
            });
          } catch (e) {
            _log.warning('Failed to show interstitial ad: $e');
            try {
              interstitialAd.dispose();
            } catch (disposeError) {
              _log.warning('Error disposing interstitial ad: $disposeError');
            }
            onAdFailedToShow?.call();
          }
          break;
        case Error<InterstitialAd>():
          onAdFailedToLoad?.call();
          break;
      }
    } catch (e) {
      onAdFailedToLoad?.call();
    }
  }
}
