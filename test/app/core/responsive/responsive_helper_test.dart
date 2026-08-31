import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_helper.dart';

/// Tests for the width-based (v1) [ResponsiveHelper].
///
/// Representative widths: 320 is below the small breakpoint (360),
/// 480 sits between small and medium, 1000 is at or above large (900).
void main() {
  const smallWidth = 320.0;
  const mediumWidth = 480.0;
  const largeWidth = 1000.0;

  group('ResponsiveHelper (v1) padding', () {
    test('getHorizontalPadding returns 16 / 24 / 32', () {
      expect(ResponsiveHelper.getHorizontalPadding(smallWidth), 16.0);
      expect(ResponsiveHelper.getHorizontalPadding(mediumWidth), 24.0);
      expect(ResponsiveHelper.getHorizontalPadding(largeWidth), 32.0);
    });

    test('getHorizontalPadding boundaries at 360 and 900 are inclusive', () {
      expect(ResponsiveHelper.getHorizontalPadding(359), 16.0);
      expect(ResponsiveHelper.getHorizontalPadding(360), 24.0);
      expect(ResponsiveHelper.getHorizontalPadding(899), 24.0);
      expect(ResponsiveHelper.getHorizontalPadding(900), 32.0);
    });

    test('getVerticalPadding returns 12 for small and 16 otherwise', () {
      expect(ResponsiveHelper.getVerticalPadding(smallWidth), 12.0);
      expect(ResponsiveHelper.getVerticalPadding(mediumWidth), 16.0);
      expect(ResponsiveHelper.getVerticalPadding(largeWidth), 16.0);
    });
  });

  group('ResponsiveHelper (v1) spacing', () {
    test('getSpacingExtraSmall returns 4 / 8', () {
      expect(ResponsiveHelper.getSpacingExtraSmall(smallWidth), 4.0);
      expect(ResponsiveHelper.getSpacingExtraSmall(mediumWidth), 8.0);
      expect(ResponsiveHelper.getSpacingExtraSmall(largeWidth), 8.0);
    });

    test('getSpacingSmall returns 16 / 20', () {
      expect(ResponsiveHelper.getSpacingSmall(smallWidth), 16.0);
      expect(ResponsiveHelper.getSpacingSmall(mediumWidth), 20.0);
      expect(ResponsiveHelper.getSpacingSmall(largeWidth), 20.0);
    });

    test('getSpacingMedium returns 20 / 24', () {
      expect(ResponsiveHelper.getSpacingMedium(smallWidth), 20.0);
      expect(ResponsiveHelper.getSpacingMedium(mediumWidth), 24.0);
      expect(ResponsiveHelper.getSpacingMedium(largeWidth), 24.0);
    });

    test('getSpacingLarge returns 24 / 32', () {
      expect(ResponsiveHelper.getSpacingLarge(smallWidth), 24.0);
      expect(ResponsiveHelper.getSpacingLarge(mediumWidth), 32.0);
      expect(ResponsiveHelper.getSpacingLarge(largeWidth), 32.0);
    });

    test('getSpacingExtraLarge returns 32 / 40', () {
      expect(ResponsiveHelper.getSpacingExtraLarge(smallWidth), 32.0);
      expect(ResponsiveHelper.getSpacingExtraLarge(mediumWidth), 40.0);
      expect(ResponsiveHelper.getSpacingExtraLarge(largeWidth), 40.0);
    });
  });

  group('ResponsiveHelper (v1) font size', () {
    test('getFontSizeMultiplier returns 0.9 / 1.0 / 1.1', () {
      expect(ResponsiveHelper.getFontSizeMultiplier(smallWidth), 0.9);
      expect(ResponsiveHelper.getFontSizeMultiplier(mediumWidth), 1.0);
      expect(ResponsiveHelper.getFontSizeMultiplier(largeWidth), 1.1);
    });

    test('getResponsiveFontSize returns null for a null base size', () {
      expect(ResponsiveHelper.getResponsiveFontSize(smallWidth, null), isNull);
      expect(ResponsiveHelper.getResponsiveFontSize(mediumWidth, null), isNull);
      expect(ResponsiveHelper.getResponsiveFontSize(largeWidth, null), isNull);
    });

    test('getResponsiveFontSize scales the base size by the multiplier', () {
      expect(
        ResponsiveHelper.getResponsiveFontSize(smallWidth, 20),
        closeTo(18.0, 0.0001),
      );
      expect(ResponsiveHelper.getResponsiveFontSize(mediumWidth, 20), 20.0);
      expect(
        ResponsiveHelper.getResponsiveFontSize(largeWidth, 20),
        closeTo(22.0, 0.0001),
      );
    });

    test('getResponsiveFontSize agrees with getFontSizeMultiplier', () {
      for (final width in [smallWidth, mediumWidth, largeWidth]) {
        expect(
          ResponsiveHelper.getResponsiveFontSize(width, 16),
          closeTo(16 * ResponsiveHelper.getFontSizeMultiplier(width), 0.0001),
        );
      }
    });
  });

  group('ResponsiveHelper (v1) EdgeInsets', () {
    test('getContainerPadding', () {
      expect(
        ResponsiveHelper.getContainerPadding(smallWidth),
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
      expect(
        ResponsiveHelper.getContainerPadding(mediumWidth),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
      expect(
        ResponsiveHelper.getContainerPadding(largeWidth),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    });

    test('getDialogPadding', () {
      expect(
        ResponsiveHelper.getDialogPadding(smallWidth),
        const EdgeInsets.all(16),
      );
      expect(
        ResponsiveHelper.getDialogPadding(mediumWidth),
        const EdgeInsets.all(24),
      );
      expect(
        ResponsiveHelper.getDialogPadding(largeWidth),
        const EdgeInsets.all(24),
      );
    });

    test('getDialogTitlePadding', () {
      expect(
        ResponsiveHelper.getDialogTitlePadding(smallWidth),
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        ResponsiveHelper.getDialogTitlePadding(mediumWidth),
        const EdgeInsets.fromLTRB(24, 24, 24, 16),
      );
      expect(
        ResponsiveHelper.getDialogTitlePadding(largeWidth),
        const EdgeInsets.fromLTRB(24, 24, 24, 16),
      );
    });

    test('getDialogContentPadding', () {
      expect(
        ResponsiveHelper.getDialogContentPadding(smallWidth),
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        ResponsiveHelper.getDialogContentPadding(mediumWidth),
        const EdgeInsets.fromLTRB(24, 20, 24, 16),
      );
      expect(
        ResponsiveHelper.getDialogContentPadding(largeWidth),
        const EdgeInsets.fromLTRB(24, 20, 24, 16),
      );
    });

    test('getDialogActionsPadding', () {
      expect(
        ResponsiveHelper.getDialogActionsPadding(smallWidth),
        const EdgeInsets.fromLTRB(8, 0, 8, 8),
      );
      expect(
        ResponsiveHelper.getDialogActionsPadding(mediumWidth),
        const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
      expect(
        ResponsiveHelper.getDialogActionsPadding(largeWidth),
        const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
    });
  });

  group('ResponsiveHelper (v1) max content width', () {
    test('returns 420 below large and 500 at or above large', () {
      expect(ResponsiveHelper.getMaxContentWidth(smallWidth), 420.0);
      expect(ResponsiveHelper.getMaxContentWidth(mediumWidth), 420.0);
      expect(ResponsiveHelper.getMaxContentWidth(899), 420.0);
      expect(ResponsiveHelper.getMaxContentWidth(900), 500.0);
      expect(ResponsiveHelper.getMaxContentWidth(largeWidth), 500.0);
    });
  });

  group('ResponsiveHelper (v1) screen size predicates', () {
    test('isSmallScreen is true only below 360', () {
      expect(ResponsiveHelper.isSmallScreen(smallWidth), isTrue);
      expect(ResponsiveHelper.isSmallScreen(359), isTrue);
      expect(ResponsiveHelper.isSmallScreen(360), isFalse);
      expect(ResponsiveHelper.isSmallScreen(mediumWidth), isFalse);
      expect(ResponsiveHelper.isSmallScreen(largeWidth), isFalse);
    });

    test('isMediumScreen is true only in [360, 600)', () {
      expect(ResponsiveHelper.isMediumScreen(smallWidth), isFalse);
      expect(ResponsiveHelper.isMediumScreen(360), isTrue);
      expect(ResponsiveHelper.isMediumScreen(mediumWidth), isTrue);
      expect(ResponsiveHelper.isMediumScreen(599), isTrue);
      expect(ResponsiveHelper.isMediumScreen(600), isFalse);
      expect(ResponsiveHelper.isMediumScreen(largeWidth), isFalse);
    });

    test('isLargeScreen is true only at or above 900', () {
      expect(ResponsiveHelper.isLargeScreen(smallWidth), isFalse);
      expect(ResponsiveHelper.isLargeScreen(mediumWidth), isFalse);
      expect(ResponsiveHelper.isLargeScreen(899), isFalse);
      expect(ResponsiveHelper.isLargeScreen(900), isTrue);
      expect(ResponsiveHelper.isLargeScreen(largeWidth), isTrue);
    });

    test('widths in [600, 900) match none of the v1 predicates', () {
      // v1 has no "extra large" concept and leaves a gap between medium
      // (< 600) and large (>= 900).
      const gapWidth = 700.0;
      expect(ResponsiveHelper.isSmallScreen(gapWidth), isFalse);
      expect(ResponsiveHelper.isMediumScreen(gapWidth), isFalse);
      expect(ResponsiveHelper.isLargeScreen(gapWidth), isFalse);
    });
  });
}
