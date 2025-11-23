import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// ViewModel for navigation bar feature.
///
/// Manages tab selection state and business logic related to navigation bar.
class NavigationBarViewModel {
  NavigationBarViewModel() {
    // DEFINE LISTENERS
    _currentTabIndex = ValueNotifier<int>(0);
  }

  // LOGGER
  final _log = Logger('NavigationBarViewModel');

  // REPOSITORIES & USE CASES
  // TODO: Add repositories and use cases if needed

  // DOMAIN

  // STATE
  late final ValueNotifier<int> _currentTabIndex;

  /// Current selected tab index (0-based).
  ValueListenable<int> get currentTabIndex => _currentTabIndex;

  // DISPOSE
  void dispose() {
    _currentTabIndex.dispose();
  }

  // FUNCTIONS
  void onTabChanged(int index) {
    if (_currentTabIndex.value != index) {
      _log.info('Tab changed from ${_currentTabIndex.value} to $index');
      _currentTabIndex.value = index;
      // TODO: Add business logic here (analytics, data refresh, etc.)
    }
  }
}
