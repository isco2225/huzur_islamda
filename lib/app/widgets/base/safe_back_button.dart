import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A safe back button that waits for route to be in idle state before popping.
///
/// This widget can be used as AppBar's leading widget to prevent navigation
/// assertion errors when quickly navigating back.
class SafeBackButton extends StatelessWidget {
  const SafeBackButton({super.key, this.color, this.onPressed});

  final Color? color;
  final VoidCallback? onPressed;

  Future<void> _safePop(BuildContext context) async {
    // Wait for route to be in idle state by waiting multiple frames
    // This ensures route animations are complete before popping
    for (int frame = 0; frame < 2; frame++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!context.mounted) return;
    }

    if (!context.mounted) return;

    try {
      final navigator = Navigator.of(context, rootNavigator: false);

      // Check if we can pop before attempting
      if (!navigator.canPop() || !context.canPop()) return;

      // Call custom onPressed if provided
      if (onPressed != null) {
        onPressed!();
        return;
      }

      // Perform the pop operation
      context.pop();
    } catch (e) {
      // Silently ignore navigation errors when context is disposed
      // or route is in an invalid state (e.g., already popped)
      debugPrint('Navigation error in SafeBackButton: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      onPressed: () => _safePop(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
