import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';

/// Helper class for responsive design calculations
///
/// Provides methods to calculate responsive values based on screen size
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Get responsive padding based on screen width
  ///
  /// Returns smaller padding for small screens, larger for big screens
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth < ResponsiveBreakpoints.small) {
      return 16.0;
    } else if (screenWidth >= ResponsiveBreakpoints.large) {
      return 32.0;
    } else {
      return 24.0;
    }
  }

  /// Get responsive vertical padding based on screen width
  static double getVerticalPadding(double screenWidth) {
    if (screenWidth < ResponsiveBreakpoints.small) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  /// Get responsive spacing (small)
  static double getSpacingSmall(double screenWidth) {
    return screenWidth < ResponsiveBreakpoints.small ? 16.0 : 20.0;
  }

  /// Get responsive spacing (medium)
  static double getSpacingMedium(double screenWidth) {
    return screenWidth < ResponsiveBreakpoints.small ? 20.0 : 24.0;
  }

  /// Get responsive spacing (large)
  static double getSpacingLarge(double screenWidth) {
    return screenWidth < ResponsiveBreakpoints.small ? 24.0 : 32.0;
  }

  /// Get responsive spacing (extra large)
  static double getSpacingExtraLarge(double screenWidth) {
    return screenWidth < ResponsiveBreakpoints.small ? 32.0 : 40.0;
  }

  /// Get responsive font size multiplier
  ///
  /// Returns smaller multiplier for small screens
  static double getFontSizeMultiplier(double screenWidth) {
    if (screenWidth < ResponsiveBreakpoints.small) {
      return 0.9;
    } else if (screenWidth >= ResponsiveBreakpoints.large) {
      return 1.1;
    } else {
      return 1.0;
    }
  }

  /// Get responsive container padding
  static EdgeInsets getContainerPadding(double screenWidth) {
    final horizontal = screenWidth < ResponsiveBreakpoints.small ? 12.0 : 16.0;
    final vertical = screenWidth < ResponsiveBreakpoints.small ? 12.0 : 14.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Get responsive dialog padding
  static EdgeInsets getDialogPadding(double screenWidth) {
    final padding = screenWidth < ResponsiveBreakpoints.small ? 16.0 : 24.0;
    return EdgeInsets.all(padding);
  }

  /// Get responsive dialog title padding
  static EdgeInsets getDialogTitlePadding(double screenWidth) {
    final horizontal = screenWidth < ResponsiveBreakpoints.small ? 16.0 : 24.0;
    final vertical = screenWidth < ResponsiveBreakpoints.small ? 16.0 : 24.0;
    final bottom = screenWidth < ResponsiveBreakpoints.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, vertical, horizontal, bottom);
  }

  /// Get responsive dialog content padding
  static EdgeInsets getDialogContentPadding(double screenWidth) {
    final horizontal = screenWidth < ResponsiveBreakpoints.small ? 16.0 : 24.0;
    final top = screenWidth < ResponsiveBreakpoints.small ? 16.0 : 20.0;
    final bottom = screenWidth < ResponsiveBreakpoints.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  /// Get responsive dialog actions padding
  static EdgeInsets getDialogActionsPadding(double screenWidth) {
    final horizontal = screenWidth < ResponsiveBreakpoints.small ? 8.0 : 16.0;
    final bottom = screenWidth < ResponsiveBreakpoints.small ? 8.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottom);
  }

  /// Get responsive max width for content containers
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth >= ResponsiveBreakpoints.large) {
      return 500.0;
    } else {
      return 420.0;
    }
  }

  /// Check if screen is small
  static bool isSmallScreen(double screenWidth) {
    return screenWidth < ResponsiveBreakpoints.small;
  }

  /// Check if screen is medium
  static bool isMediumScreen(double screenWidth) {
    return screenWidth >= ResponsiveBreakpoints.small &&
        screenWidth < ResponsiveBreakpoints.medium;
  }

  /// Check if screen is large
  static bool isLargeScreen(double screenWidth) {
    return screenWidth >= ResponsiveBreakpoints.medium;
  }

  /// Get responsive font size
  ///
  /// Returns adjusted font size based on screen width
  static double? getResponsiveFontSize(
    double screenWidth,
    double? baseFontSize,
  ) {
    if (baseFontSize == null) return null;
    if (screenWidth < ResponsiveBreakpoints.small) {
      return baseFontSize * 0.9;
    } else if (screenWidth >= ResponsiveBreakpoints.large) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }
}
