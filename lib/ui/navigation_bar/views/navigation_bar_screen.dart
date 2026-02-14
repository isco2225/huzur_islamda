import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/domain.dart';
import '../../ui.dart';

/// Screen that manages the bottom navigation bar and stateful shell navigation.
///
/// This screen wraps the [StatefulNavigationShell] and provides the bottom
/// navigation bar UI. Each branch maintains its own navigation stack.
class NavigationBarScreen extends StatefulWidget {
  const NavigationBarScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<NavigationBarScreen> createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  late final NavigationBarViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NavigationBarViewModel(
      showAdUseCase: context.read<ShowAdUseCase>(),
    );
    // Initialize with current tab index
    _viewModel.onTabChanged(widget.navigationShell.currentIndex);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _viewModel.onTabChanged(index);

    widget.navigationShell.goBranch(
      index,
      // If already on the selected branch, pop to first route
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarView(
      navigationShell: widget.navigationShell,
      viewModel: _viewModel,
      onTabTapped: _onTabTapped,
    );
  }
}
