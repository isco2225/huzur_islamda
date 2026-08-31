import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

/// [AdMobService]'s constructor is channel-free, so a subclass can record
/// interstitial requests without loading a real ad.
class _RecordingAdMobService extends AdMobService {
  int showCalls = 0;
  void Function()? lastOnAdDismissed;
  void Function()? lastOnAdFailedToShow;
  void Function()? lastOnAdFailedToLoad;

  @override
  Future<void> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
    void Function()? onAdFailedToLoad,
  }) async {
    showCalls++;
    lastOnAdDismissed = onAdDismissed;
    lastOnAdFailedToShow = onAdFailedToShow;
    lastOnAdFailedToLoad = onAdFailedToLoad;
  }
}

void main() {
  late _RecordingAdMobService adMobService;
  late FakeUserRepository userRepository;
  late ShowAdUseCase useCase;

  setUp(() {
    adMobService = _RecordingAdMobService();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    useCase = ShowAdUseCase(
      admobService: adMobService,
      userRepository: userRepository,
    );
  });

  group('ShowAdUseCase.showInterstitialAd', () {
    test('skips the ad entirely for a premium user', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.yearly,
      );

      await useCase.showInterstitialAd(onAdDismissed: () {});

      expect(adMobService.showCalls, 0);
    });

    test('shows the ad for a non-premium user', () async {
      await useCase.showInterstitialAd();

      expect(adMobService.showCalls, 1);
    });

    test('shows the ad for an empty (signed-out) user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await useCase.showInterstitialAd();

      expect(adMobService.showCalls, 1);
    });

    test('forwards all three callbacks to the service', () async {
      void dismissed() {}
      void failedToShow() {}
      void failedToLoad() {}

      await useCase.showInterstitialAd(
        onAdDismissed: dismissed,
        onAdFailedToShow: failedToShow,
        onAdFailedToLoad: failedToLoad,
      );

      expect(adMobService.lastOnAdDismissed, same(dismissed));
      expect(adMobService.lastOnAdFailedToShow, same(failedToShow));
      expect(adMobService.lastOnAdFailedToLoad, same(failedToLoad));
    });

    test('re-evaluates premium status on every call', () async {
      await useCase.showInterstitialAd();
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.weekly,
      );
      await useCase.showInterstitialAd();

      expect(adMobService.showCalls, 1);
    });
  });
}
