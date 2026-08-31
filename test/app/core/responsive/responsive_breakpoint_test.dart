import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_breakpoints.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_data.dart';

void main() {
  group('ResponsiveBreakpoints constants', () {
    test('are strictly increasing', () {
      expect(ResponsiveBreakpoints.small, 360);
      expect(ResponsiveBreakpoints.medium, 600);
      expect(ResponsiveBreakpoints.large, 900);
      expect(ResponsiveBreakpoints.extraLarge, 1200);
      expect(
        ResponsiveBreakpoints.small < ResponsiveBreakpoints.medium &&
            ResponsiveBreakpoints.medium < ResponsiveBreakpoints.large &&
            ResponsiveBreakpoints.large < ResponsiveBreakpoints.extraLarge,
        isTrue,
      );
    });
  });

  group('ResponsiveBreakpoint.fromWidth', () {
    const boundaryTable = <(double, ResponsiveBreakpoint)>[
      (0, ResponsiveBreakpoint.small),
      (359, ResponsiveBreakpoint.small),
      (359.99, ResponsiveBreakpoint.small),
      (360, ResponsiveBreakpoint.medium),
      (599, ResponsiveBreakpoint.medium),
      (600, ResponsiveBreakpoint.large),
      (899, ResponsiveBreakpoint.large),
      (900, ResponsiveBreakpoint.extraLarge),
      (1200, ResponsiveBreakpoint.extraLarge),
      (5000, ResponsiveBreakpoint.extraLarge),
    ];

    for (final (width, expected) in boundaryTable) {
      test('width $width maps to ${expected.name}', () {
        expect(ResponsiveBreakpoint.fromWidth(width), expected);
      });
    }

    test('lower bound of each breakpoint is inclusive', () {
      expect(
        ResponsiveBreakpoint.fromWidth(ResponsiveBreakpoints.small),
        ResponsiveBreakpoint.medium,
      );
      expect(
        ResponsiveBreakpoint.fromWidth(ResponsiveBreakpoints.medium),
        ResponsiveBreakpoint.large,
      );
      expect(
        ResponsiveBreakpoint.fromWidth(ResponsiveBreakpoints.large),
        ResponsiveBreakpoint.extraLarge,
      );
    });

    test('extraLarge constant (1200) is not a distinct boundary', () {
      // Widths at and just below 1200 are both extraLarge, so the constant
      // is never consulted by fromWidth.
      expect(
        ResponsiveBreakpoint.fromWidth(ResponsiveBreakpoints.extraLarge - 1),
        ResponsiveBreakpoint.extraLarge,
      );
      expect(
        ResponsiveBreakpoint.fromWidth(ResponsiveBreakpoints.extraLarge),
        ResponsiveBreakpoint.extraLarge,
      );
    });

    test('enum values are ordered from smallest to largest', () {
      expect(ResponsiveBreakpoint.values, [
        ResponsiveBreakpoint.small,
        ResponsiveBreakpoint.medium,
        ResponsiveBreakpoint.large,
        ResponsiveBreakpoint.extraLarge,
      ]);
    });
  });
}
