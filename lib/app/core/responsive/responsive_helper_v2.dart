import 'package:flutter/material.dart';

import 'responsive_data.dart';

/// Improved helper class for responsive design calculations
///
/// Uses ResponsiveData to avoid repeated MediaQuery lookups
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Get responsive padding based on breakpoint
  ///
  /// Returns smaller padding for small screens, larger for big screens
  static double getHorizontalPadding(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.small:
        return 16.0;
      case ResponsiveBreakpoint.medium:
        return 24.0;
      case ResponsiveBreakpoint.large:
        return 32.0;
      case ResponsiveBreakpoint.extraLarge:
        return 32.0;
    }
  }

  /// Get responsive vertical padding based on breakpoint
  static double getVerticalPadding(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.small:
        return 12.0;
      case ResponsiveBreakpoint.medium:
      case ResponsiveBreakpoint.large:
      case ResponsiveBreakpoint.extraLarge:
        return 16.0;
    }
  }

  /// Get responsive spacing values based on breakpoint
  static double getSpacing(
    ResponsiveBreakpoint breakpoint,
    ResponsiveSpacing spacing,
  ) {
    switch (spacing) {
      case ResponsiveSpacing.extraSmall:
        return breakpoint == ResponsiveBreakpoint.small ? 4.0 : 8.0;
      case ResponsiveSpacing.small:
        return breakpoint == ResponsiveBreakpoint.small ? 16.0 : 20.0;
      case ResponsiveSpacing.medium:
        return breakpoint == ResponsiveBreakpoint.small ? 20.0 : 24.0;
      case ResponsiveSpacing.large:
        return breakpoint == ResponsiveBreakpoint.small ? 24.0 : 32.0;
      case ResponsiveSpacing.extraLarge:
        return breakpoint == ResponsiveBreakpoint.small ? 32.0 : 40.0;
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.small:
        return 0.9;
      case ResponsiveBreakpoint.medium:
        return 1.0;
      case ResponsiveBreakpoint.large:
        return 1.2;
      case ResponsiveBreakpoint.extraLarge:
        return 1.4;
    }
  }

  /// Get responsive container padding
  static EdgeInsets getContainerPadding(ResponsiveBreakpoint breakpoint) {
    if (breakpoint == ResponsiveBreakpoint.small) {
      return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0);
    }
  }

  /// Get responsive dialog padding
  static EdgeInsets getDialogPadding(ResponsiveBreakpoint breakpoint) {
    final padding = breakpoint == ResponsiveBreakpoint.small ? 16.0 : 24.0;
    return EdgeInsets.all(padding);
  }

  /// Get responsive dialog title padding
  static EdgeInsets getDialogTitlePadding(ResponsiveBreakpoint breakpoint) {
    final horizontal = breakpoint == ResponsiveBreakpoint.small ? 16.0 : 24.0;
    final vertical = breakpoint == ResponsiveBreakpoint.small ? 16.0 : 24.0;
    final bottom = breakpoint == ResponsiveBreakpoint.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, vertical, horizontal, bottom);
  }

  /// Get responsive dialog content padding
  static EdgeInsets getDialogContentPadding(ResponsiveBreakpoint breakpoint) {
    final horizontal = breakpoint == ResponsiveBreakpoint.small ? 16.0 : 24.0;
    final top = breakpoint == ResponsiveBreakpoint.small ? 16.0 : 20.0;
    final bottom = breakpoint == ResponsiveBreakpoint.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  /// Get responsive dialog actions padding
  static EdgeInsets getDialogActionsPadding(ResponsiveBreakpoint breakpoint) {
    final horizontal = breakpoint == ResponsiveBreakpoint.small ? 8.0 : 16.0;
    final bottom = breakpoint == ResponsiveBreakpoint.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottom);
  }

  /// Get responsive max width for content containers
  static double getMaxContentWidth(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.small:
      case ResponsiveBreakpoint.medium:
        return 420.0;
      case ResponsiveBreakpoint.large:
      case ResponsiveBreakpoint.extraLarge:
        return 500.0;
    }
  }

  /// Get responsive font size
  ///
  /// Returns adjusted font size based on breakpoint
  static double? getResponsiveFontSize(
    ResponsiveBreakpoint breakpoint,
    double? baseFontSize,
  ) {
    if (baseFontSize == null) return null;
    return baseFontSize * getFontSizeMultiplier(breakpoint);
  }
}

/// Spacing size enum for type-safe spacing values
enum ResponsiveSpacing { extraSmall, small, medium, large, extraLarge }
