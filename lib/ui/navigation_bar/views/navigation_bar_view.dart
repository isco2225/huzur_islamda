import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../ui.dart';

/// View that displays the bottom navigation bar and navigation shell content.
///
/// This is a pure UI component that receives the navigation shell and
/// handles the visual presentation of tabs and content.
class NavigationBarView extends StatelessWidget {
  const NavigationBarView({
    required this.navigationShell,
    required this.viewModel,
    required this.onTabTapped,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final NavigationBarViewModel viewModel;
  final void Function(int) onTabTapped;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: onTabTapped,
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Akış',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Ara',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Vakitler',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Zikir',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
