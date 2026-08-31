import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/constants/app_ad_ids.dart';
import 'package:huzur_islamda/data/data.dart';

/// Only the channel-free parts of [AdMobService] are covered: the ad-unit-id
/// getters. On the host test platform (neither Android nor iOS) the service
/// falls back to the Android ids.
void main() {
  late AdMobService service;

  setUp(() {
    service = AdMobService();
  });

  test('is not initialized after construction', () {
    expect(service.isInitialized.value, isFalse);
  });

  test('getBannerAdUnitId returns a non-empty AdMob unit id', () {
    final id = service.getBannerAdUnitId();

    expect(id, isNotEmpty);
    expect(id, startsWith('ca-app-pub-'));
    expect(id, AppAdIds.bannerAdUnitIdAndroid);
  });

  test('getInterstitialAdUnitId returns a non-empty AdMob unit id', () {
    final id = service.getInterstitialAdUnitId();

    expect(id, isNotEmpty);
    expect(id, startsWith('ca-app-pub-'));
    expect(id, AppAdIds.interstitialAdUnitIdAndroid);
  });

  test('getNativeAdUnitId returns a non-empty AdMob unit id', () {
    final id = service.getNativeAdUnitId();

    expect(id, isNotEmpty);
    expect(id, startsWith('ca-app-pub-'));
    expect(id, AppAdIds.nativeAdUnitIdAndroid);
  });

  test('the three ad unit ids are distinct', () {
    final ids = {
      service.getBannerAdUnitId(),
      service.getInterstitialAdUnitId(),
      service.getNativeAdUnitId(),
    };

    expect(ids.length, 3);
  });
}
