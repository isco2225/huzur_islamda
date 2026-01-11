import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';
import 'responsive_helper_v2.dart';

/// Cached responsive data for a BuildContext
///
/// This class caches MediaQuery values to avoid repeated lookups
class ResponsiveData {
  ResponsiveData._({
    required this.screenWidth,
    required this.screenHeight,
    required this.breakpoint,
  });

  final double screenWidth;
  final double screenHeight;
  final ResponsiveBreakpoint breakpoint;

  /// Create ResponsiveData from BuildContext
  /// Caches MediaQuery values to improve performance
  factory ResponsiveData.fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final screenWidth = mediaQuery.width;
    final screenHeight = mediaQuery.height;
    final breakpoint = ResponsiveBreakpoint.fromWidth(screenWidth);

    return ResponsiveData._(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      breakpoint: breakpoint,
    );
  }

  /// Check if screen is small
  bool get isSmallScreen => breakpoint == ResponsiveBreakpoint.small;

  /// Check if screen is medium
  bool get isMediumScreen => breakpoint == ResponsiveBreakpoint.medium;

  /// Check if screen is large
  bool get isLargeScreen => breakpoint == ResponsiveBreakpoint.large;

  /// Check if screen is extra large
  bool get isExtraLargeScreen => breakpoint == ResponsiveBreakpoint.extraLarge;

  // Responsive değerler - ResponsiveHelper metodlarını kullanarak
  double get horizontalPadding =>
      ResponsiveHelper.getHorizontalPadding(breakpoint);
  double get verticalPadding => ResponsiveHelper.getVerticalPadding(breakpoint);
  double get spacingSmall =>
      ResponsiveHelper.getSpacing(breakpoint, ResponsiveSpacing.small);
  double get spacingExtraSmall =>
      ResponsiveHelper.getSpacing(breakpoint, ResponsiveSpacing.extraSmall);
  double get spacingMedium =>
      ResponsiveHelper.getSpacing(breakpoint, ResponsiveSpacing.medium);
  double get spacingLarge =>
      ResponsiveHelper.getSpacing(breakpoint, ResponsiveSpacing.large);
  double get spacingExtraLarge =>
      ResponsiveHelper.getSpacing(breakpoint, ResponsiveSpacing.extraLarge);
  EdgeInsets get containerPadding =>
      ResponsiveHelper.getContainerPadding(breakpoint);
  EdgeInsets get dialogPadding => ResponsiveHelper.getDialogPadding(breakpoint);
  EdgeInsets get dialogTitlePadding =>
      ResponsiveHelper.getDialogTitlePadding(breakpoint);
  EdgeInsets get dialogContentPadding =>
      ResponsiveHelper.getDialogContentPadding(breakpoint);
  EdgeInsets get dialogActionsPadding =>
      ResponsiveHelper.getDialogActionsPadding(breakpoint);
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(breakpoint);
  double? responsiveFontSize(double? baseFontSize) =>
      ResponsiveHelper.getResponsiveFontSize(breakpoint, baseFontSize);
}

/// Screen size breakpoint enum
enum ResponsiveBreakpoint {
  small,
  medium,
  large,
  extraLarge;

  /// Determine breakpoint from screen width
  static ResponsiveBreakpoint fromWidth(double width) {
    if (width < ResponsiveBreakpoints.small) {
      return ResponsiveBreakpoint.small;
    } else if (width < ResponsiveBreakpoints.medium) {
      return ResponsiveBreakpoint.medium;
    } else if (width < ResponsiveBreakpoints.large) {
      return ResponsiveBreakpoint.large;
    } else {
      return ResponsiveBreakpoint.extraLarge;
    }
  }
}
