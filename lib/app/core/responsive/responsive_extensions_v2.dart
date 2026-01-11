import 'package:flutter/material.dart';

import 'responsive_data.dart';
import 'responsive_helper_v2.dart';

/// Improved extension on BuildContext for responsive utilities
///
/// Uses cached ResponsiveData to avoid repeated MediaQuery lookups
extension ResponsiveExtensionV2 on BuildContext {
  /// Get cached responsive data
  ///
  /// This caches MediaQuery values to improve performance when
  /// multiple responsive values are accessed in the same build
  ResponsiveData get responsive {
    return ResponsiveData.fromContext(this);
  }

  /// Get screen width (cached)
  double get screenWidth => responsive.screenWidth;

  /// Get screen height (cached)
  double get screenHeight => responsive.screenHeight;

  /// Check if screen is small (cached)
  bool get isSmallScreen => responsive.isSmallScreen;

  /// Check if screen is medium (cached)
  bool get isMediumScreen => responsive.isMediumScreen;

  /// Check if screen is large (cached)
  bool get isLargeScreen => responsive.isLargeScreen;

  /// Check if screen is extra large (cached)
  bool get isExtraLargeScreen => responsive.isExtraLargeScreen;

  /// Get responsive horizontal padding (cached)
  double get horizontalPadding =>
      ResponsiveHelper.getHorizontalPadding(responsive.breakpoint);

  /// Get responsive vertical padding (cached)
  double get verticalPadding =>
      ResponsiveHelper.getVerticalPadding(responsive.breakpoint);

  /// Get responsive spacing (cached)
  double spacing(ResponsiveSpacing size) =>
      ResponsiveHelper.getSpacing(responsive.breakpoint, size);

  /// Get responsive spacing (small) - for backward compatibility
  double get spacingSmall => ResponsiveHelper.getSpacing(
    responsive.breakpoint,
    ResponsiveSpacing.small,
  );

  /// Get responsive spacing (extra small) - for backward compatibility
  double get spacingExtraSmall => ResponsiveHelper.getSpacing(
    responsive.breakpoint,
    ResponsiveSpacing.extraSmall,
  );

  /// Get responsive spacing (medium) - for backward compatibility
  double get spacingMedium => ResponsiveHelper.getSpacing(
    responsive.breakpoint,
    ResponsiveSpacing.medium,
  );

  /// Get responsive spacing (large) - for backward compatibility
  double get spacingLarge => ResponsiveHelper.getSpacing(
    responsive.breakpoint,
    ResponsiveSpacing.large,
  );

  /// Get responsive spacing (extra large) - for backward compatibility
  double get spacingExtraLarge => ResponsiveHelper.getSpacing(
    responsive.breakpoint,
    ResponsiveSpacing.extraLarge,
  );

  /// Get responsive container padding (cached)
  EdgeInsets get containerPadding =>
      ResponsiveHelper.getContainerPadding(responsive.breakpoint);

  /// Get responsive dialog padding (cached)
  EdgeInsets get dialogPadding =>
      ResponsiveHelper.getDialogPadding(responsive.breakpoint);

  /// Get responsive dialog title padding (cached)
  EdgeInsets get dialogTitlePadding =>
      ResponsiveHelper.getDialogTitlePadding(responsive.breakpoint);

  /// Get responsive dialog content padding (cached)
  EdgeInsets get dialogContentPadding =>
      ResponsiveHelper.getDialogContentPadding(responsive.breakpoint);

  /// Get responsive dialog actions padding (cached)
  EdgeInsets get dialogActionsPadding =>
      ResponsiveHelper.getDialogActionsPadding(responsive.breakpoint);

  /// Get responsive max content width (cached)
  double get maxContentWidth =>
      ResponsiveHelper.getMaxContentWidth(responsive.breakpoint);

  /// Get responsive font size (cached)
  double? responsiveFontSize(double? baseFontSize) =>
      ResponsiveHelper.getResponsiveFontSize(
        responsive.breakpoint,
        baseFontSize,
      );
}
