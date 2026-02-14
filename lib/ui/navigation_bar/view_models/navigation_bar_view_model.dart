import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../domain/domain.dart';

/// ViewModel for navigation bar feature.
///
/// Manages tab selection state and business logic related to navigation bar.
/// Reklam stratejisi: Kullanıcı **farklı** sekmeye geçtiğinde en fazla
/// [_interstitialCooldown] sürede bir reklam gösterilir (sık geçişte spam önlenir).
class NavigationBarViewModel {
  NavigationBarViewModel({required ShowAdUseCase showAdUseCase})
    : _showAdUseCase = showAdUseCase {
    _currentTabIndex = ValueNotifier<int>(0);
  }

  final _log = Logger('NavigationBarViewModel');
  final ShowAdUseCase _showAdUseCase;

  late final ValueNotifier<int> _currentTabIndex;
  ValueListenable<int> get currentTabIndex => _currentTabIndex;

  /// it should be at least this duration between two interstitial ads.
  static const Duration _interstitialCooldown = Duration(minutes: 2);

  DateTime? _lastInterstitialShownAt;

  void dispose() {
    _currentTabIndex.dispose();
  }

  /// When the tab changes, it is called. If a different tab is selected and the cooldown has passed,
  /// an interstitial ad is shown; clicking on the same tab or too frequent switching does not show an ad.
  void onTabChanged(int index) {
    final previousIndex = _currentTabIndex.value;
    if (previousIndex == index) return;

    _log.info('Tab changed from $previousIndex to $index');
    _currentTabIndex.value = index;

    final now = DateTime.now();
    final canShowAd =
        _lastInterstitialShownAt == null ||
        now.difference(_lastInterstitialShownAt!) >= _interstitialCooldown;
    if (canShowAd) {
      _lastInterstitialShownAt = now;
      _showAdUseCase.showInterstitialAd();
    }
  }
}
