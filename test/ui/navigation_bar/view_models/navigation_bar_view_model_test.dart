import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late RecordingAdMobService adMobService;
  late FakeUserRepository userRepository;
  late NavigationBarViewModel viewModel;

  setUp(() {
    adMobService = RecordingAdMobService();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    viewModel = NavigationBarViewModel(
      showAdUseCase: ShowAdUseCase(
        admobService: adMobService,
        userRepository: userRepository,
      ),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts on tab 0', () {
    expect(viewModel.currentTabIndex.value, 0);
  });

  test('selecting the current tab again is a no-op', () async {
    var notifications = 0;
    viewModel.currentTabIndex.addListener(() => notifications++);

    viewModel.onTabChanged(0);
    viewModel.onTabChanged(0);
    viewModel.onTabChanged(0);
    await pumpEventQueue();

    expect(notifications, 0);
    expect(adMobService.showInterstitialCalls, 0);
  });

  test('updates the current tab index on a distinct change', () {
    viewModel.onTabChanged(2);

    expect(viewModel.currentTabIndex.value, 2);
  });

  test('shows an interstitial exactly once every third distinct tab change', () async {
    viewModel.onTabChanged(1);
    viewModel.onTabChanged(2);
    await pumpEventQueue();
    expect(adMobService.showInterstitialCalls, 0);

    viewModel.onTabChanged(0);
    await pumpEventQueue();
    expect(adMobService.showInterstitialCalls, 1);

    viewModel.onTabChanged(1);
    viewModel.onTabChanged(0);
    await pumpEventQueue();
    expect(adMobService.showInterstitialCalls, 1);

    viewModel.onTabChanged(2);
    await pumpEventQueue();
    expect(adMobService.showInterstitialCalls, 2);
  });

  test('repeated taps on the same tab do not count toward the ad cadence', () async {
    viewModel.onTabChanged(1);
    viewModel.onTabChanged(1);
    viewModel.onTabChanged(1);
    viewModel.onTabChanged(2);
    await pumpEventQueue();

    expect(adMobService.showInterstitialCalls, 0);
  });

  test('never shows an ad to a premium user', () async {
    userRepository.currentUserNotifier.value = Fixtures.user(
      supportPackage: SupportPackage.yearly,
    );

    viewModel.onTabChanged(1);
    viewModel.onTabChanged(2);
    viewModel.onTabChanged(0);
    await pumpEventQueue();

    expect(adMobService.showInterstitialCalls, 0);
  });
}
