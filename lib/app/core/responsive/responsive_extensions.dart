import 'package:flutter/material.dart';

import 'responsive_helper.dart';

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if screen is small
  bool get isSmallScreen => ResponsiveHelper.isSmallScreen(screenWidth);

  /// Check if screen is medium
  bool get isMediumScreen => ResponsiveHelper.isMediumScreen(screenWidth);

  /// Check if screen is large
  bool get isLargeScreen => ResponsiveHelper.isLargeScreen(screenWidth);

  /// Get responsive horizontal padding
  double get horizontalPadding =>
      ResponsiveHelper.getHorizontalPadding(screenWidth);

  /// Get responsive vertical padding
  double get verticalPadding =>
      ResponsiveHelper.getVerticalPadding(screenWidth);

  /// Get responsive spacing (small)
  double get spacingSmall => ResponsiveHelper.getSpacingSmall(screenWidth);

  /// Get responsive spacing (medium)
  double get spacingMedium => ResponsiveHelper.getSpacingMedium(screenWidth);

  /// Get responsive spacing (large)
  double get spacingLarge => ResponsiveHelper.getSpacingLarge(screenWidth);

  /// Get responsive spacing (extra large)
  double get spacingExtraLarge =>
      ResponsiveHelper.getSpacingExtraLarge(screenWidth);

  /// Get responsive container padding
  EdgeInsets get containerPadding =>
      ResponsiveHelper.getContainerPadding(screenWidth);

  /// Get responsive dialog padding
  EdgeInsets get dialogPadding =>
      ResponsiveHelper.getDialogPadding(screenWidth);

  /// Get responsive dialog title padding
  EdgeInsets get dialogTitlePadding =>
      ResponsiveHelper.getDialogTitlePadding(screenWidth);

  /// Get responsive dialog content padding
  EdgeInsets get dialogContentPadding =>
      ResponsiveHelper.getDialogContentPadding(screenWidth);

  /// Get responsive dialog actions padding
  EdgeInsets get dialogActionsPadding =>
      ResponsiveHelper.getDialogActionsPadding(screenWidth);

  /// Get responsive max content width
  double get maxContentWidth =>
      ResponsiveHelper.getMaxContentWidth(screenWidth);

  /// Get responsive font size
  double? responsiveFontSize(double? baseFontSize) =>
      ResponsiveHelper.getResponsiveFontSize(screenWidth, baseFontSize);
}
