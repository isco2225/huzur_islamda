import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_data.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_helper_v2.dart'
    as v2;

/// Tests for the breakpoint-based (v2) `ResponsiveHelper`.
void main() {
  const small = ResponsiveBreakpoint.small;
  const medium = ResponsiveBreakpoint.medium;
  const large = ResponsiveBreakpoint.large;
  const extraLarge = ResponsiveBreakpoint.extraLarge;

  group('ResponsiveHelper (v2) padding', () {
    test('getHorizontalPadding returns 16 / 24 / 32 / 32', () {
      expect(v2.ResponsiveHelper.getHorizontalPadding(small), 16.0);
      expect(v2.ResponsiveHelper.getHorizontalPadding(medium), 24.0);
      expect(v2.ResponsiveHelper.getHorizontalPadding(large), 32.0);
      expect(v2.ResponsiveHelper.getHorizontalPadding(extraLarge), 32.0);
    });

    test('getVerticalPadding returns 12 for small and 16 otherwise', () {
      expect(v2.ResponsiveHelper.getVerticalPadding(small), 12.0);
      expect(v2.ResponsiveHelper.getVerticalPadding(medium), 16.0);
      expect(v2.ResponsiveHelper.getVerticalPadding(large), 16.0);
      expect(v2.ResponsiveHelper.getVerticalPadding(extraLarge), 16.0);
    });
  });

  group('ResponsiveHelper (v2) getSpacing', () {
    const expectedSpacing = <v2.ResponsiveSpacing, (double, double)>{
      // (small breakpoint value, all other breakpoints value)
      v2.ResponsiveSpacing.extraSmall: (4.0, 8.0),
      v2.ResponsiveSpacing.small: (16.0, 20.0),
      v2.ResponsiveSpacing.medium: (20.0, 24.0),
      v2.ResponsiveSpacing.large: (24.0, 32.0),
      v2.ResponsiveSpacing.extraLarge: (32.0, 40.0),
    };

    test('covers every ResponsiveSpacing value', () {
      expect(expectedSpacing.keys, containsAll(v2.ResponsiveSpacing.values));
    });

    for (final entry in expectedSpacing.entries) {
      final (smallValue, otherValue) = entry.value;

      test('${entry.key.name} is $smallValue on small', () {
        expect(v2.ResponsiveHelper.getSpacing(small, entry.key), smallValue);
      });

      test('${entry.key.name} is $otherValue on medium/large/extraLarge', () {
        for (final breakpoint in [medium, large, extraLarge]) {
          expect(
            v2.ResponsiveHelper.getSpacing(breakpoint, entry.key),
            otherValue,
            reason: 'breakpoint ${breakpoint.name}',
          );
        }
      });
    }

    test('spacing values grow monotonically within a breakpoint', () {
      for (final breakpoint in ResponsiveBreakpoint.values) {
        final values = v2.ResponsiveSpacing.values
            .map((s) => v2.ResponsiveHelper.getSpacing(breakpoint, s))
            .toList();
        for (var i = 1; i < values.length; i++) {
          expect(
            values[i],
            greaterThan(values[i - 1]),
            reason: 'breakpoint ${breakpoint.name}',
          );
        }
      }
    });
  });

  group('ResponsiveHelper (v2) font size', () {
    test('getFontSizeMultiplier returns 0.9 / 1.0 / 1.2 / 1.4', () {
      expect(v2.ResponsiveHelper.getFontSizeMultiplier(small), 0.9);
      expect(v2.ResponsiveHelper.getFontSizeMultiplier(medium), 1.0);
      expect(v2.ResponsiveHelper.getFontSizeMultiplier(large), 1.2);
      expect(v2.ResponsiveHelper.getFontSizeMultiplier(extraLarge), 1.4);
    });

    test('getResponsiveFontSize returns null for a null base size', () {
      for (final breakpoint in ResponsiveBreakpoint.values) {
        expect(
          v2.ResponsiveHelper.getResponsiveFontSize(breakpoint, null),
          isNull,
        );
      }
    });

    test('getResponsiveFontSize scales the base size by the multiplier', () {
      expect(
        v2.ResponsiveHelper.getResponsiveFontSize(small, 10),
        closeTo(9.0, 0.0001),
      );
      expect(v2.ResponsiveHelper.getResponsiveFontSize(medium, 10), 10.0);
      expect(
        v2.ResponsiveHelper.getResponsiveFontSize(large, 10),
        closeTo(12.0, 0.0001),
      );
      expect(
        v2.ResponsiveHelper.getResponsiveFontSize(extraLarge, 10),
        closeTo(14.0, 0.0001),
      );
    });

  });

  group('ResponsiveHelper (v2) EdgeInsets', () {
    test('getContainerPadding', () {
      expect(
        v2.ResponsiveHelper.getContainerPadding(small),
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
      for (final breakpoint in [medium, large, extraLarge]) {
        expect(
          v2.ResponsiveHelper.getContainerPadding(breakpoint),
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          reason: 'breakpoint ${breakpoint.name}',
        );
      }
    });

    test('getDialogPadding', () {
      expect(
        v2.ResponsiveHelper.getDialogPadding(small),
        const EdgeInsets.all(16),
      );
      for (final breakpoint in [medium, large, extraLarge]) {
        expect(
          v2.ResponsiveHelper.getDialogPadding(breakpoint),
          const EdgeInsets.all(24),
          reason: 'breakpoint ${breakpoint.name}',
        );
      }
    });

    test('getDialogTitlePadding', () {
      expect(
        v2.ResponsiveHelper.getDialogTitlePadding(small),
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      for (final breakpoint in [medium, large, extraLarge]) {
        expect(
          v2.ResponsiveHelper.getDialogTitlePadding(breakpoint),
          const EdgeInsets.fromLTRB(24, 24, 24, 16),
          reason: 'breakpoint ${breakpoint.name}',
        );
      }
    });

    test('getDialogContentPadding', () {
      expect(
        v2.ResponsiveHelper.getDialogContentPadding(small),
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      for (final breakpoint in [medium, large, extraLarge]) {
        expect(
          v2.ResponsiveHelper.getDialogContentPadding(breakpoint),
          const EdgeInsets.fromLTRB(24, 20, 24, 16),
          reason: 'breakpoint ${breakpoint.name}',
        );
      }
    });

    test('getDialogActionsPadding', () {
      expect(
        v2.ResponsiveHelper.getDialogActionsPadding(small),
        const EdgeInsets.fromLTRB(8, 0, 8, 8),
      );
      for (final breakpoint in [medium, large, extraLarge]) {
        expect(
          v2.ResponsiveHelper.getDialogActionsPadding(breakpoint),
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          reason: 'breakpoint ${breakpoint.name}',
        );
      }
    });
  });

  group('ResponsiveHelper (v2) max content width', () {
    test('returns 420 for small/medium and 500 for large/extraLarge', () {
      expect(v2.ResponsiveHelper.getMaxContentWidth(small), 420.0);
      expect(v2.ResponsiveHelper.getMaxContentWidth(medium), 420.0);
      expect(v2.ResponsiveHelper.getMaxContentWidth(large), 500.0);
      expect(v2.ResponsiveHelper.getMaxContentWidth(extraLarge), 500.0);
    });
  });
}
