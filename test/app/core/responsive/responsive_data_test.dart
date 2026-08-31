import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_data.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_extensions_v2.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_helper_v2.dart'
    show ResponsiveSpacing;

/// Pumps a [MediaQuery] of the given width and returns the inner
/// [BuildContext] captured during build.
Future<BuildContext> pumpWithWidth(WidgetTester tester, double width) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('ResponsiveData.fromContext', () {
    testWidgets('caches width, height and breakpoint at 320', (tester) async {
      final data = ResponsiveData.fromContext(await pumpWithWidth(tester, 320));

      expect(data.screenWidth, 320);
      expect(data.screenHeight, 800);
      expect(data.breakpoint, ResponsiveBreakpoint.small);
      expect(data.isSmallScreen, isTrue);
      expect(data.isMediumScreen, isFalse);
      expect(data.isLargeScreen, isFalse);
      expect(data.isExtraLargeScreen, isFalse);
      expect(data.horizontalPadding, 16.0);
      expect(data.verticalPadding, 12.0);
      expect(data.maxContentWidth, 420.0);
      expect(data.responsiveFontSize(16), closeTo(14.4, 0.0001));
      expect(data.responsiveFontSize(null), isNull);
    });

    testWidgets('classifies 700 as large', (tester) async {
      final data = ResponsiveData.fromContext(await pumpWithWidth(tester, 700));

      expect(data.breakpoint, ResponsiveBreakpoint.large);
      expect(data.isSmallScreen, isFalse);
      expect(data.isMediumScreen, isFalse);
      expect(data.isLargeScreen, isTrue);
      expect(data.isExtraLargeScreen, isFalse);
      expect(data.horizontalPadding, 32.0);
      expect(data.verticalPadding, 16.0);
      expect(data.maxContentWidth, 500.0);
      expect(data.responsiveFontSize(16), closeTo(19.2, 0.0001));
    });

    testWidgets('classifies 1000 as extraLarge', (tester) async {
      final data = ResponsiveData.fromContext(
        await pumpWithWidth(tester, 1000),
      );

      expect(data.breakpoint, ResponsiveBreakpoint.extraLarge);
      expect(data.isSmallScreen, isFalse);
      expect(data.isMediumScreen, isFalse);
      expect(data.isLargeScreen, isFalse);
      expect(data.isExtraLargeScreen, isTrue);
      expect(data.horizontalPadding, 32.0);
      expect(data.maxContentWidth, 500.0);
      expect(data.responsiveFontSize(16), closeTo(22.4, 0.0001));
    });

    testWidgets('exposes spacing and EdgeInsets getters', (tester) async {
      final smallData = ResponsiveData.fromContext(
        await pumpWithWidth(tester, 320),
      );
      final mediumData = ResponsiveData.fromContext(
        await pumpWithWidth(tester, 400),
      );

      expect(smallData.spacingExtraSmall, 4.0);
      expect(smallData.spacingSmall, 16.0);
      expect(smallData.spacingMedium, 20.0);
      expect(smallData.spacingLarge, 24.0);
      expect(smallData.spacingExtraLarge, 32.0);
      expect(
        smallData.containerPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
      expect(smallData.dialogPadding, const EdgeInsets.all(16));
      expect(
        smallData.dialogTitlePadding,
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        smallData.dialogContentPadding,
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        smallData.dialogActionsPadding,
        const EdgeInsets.fromLTRB(8, 0, 8, 8),
      );

      expect(mediumData.breakpoint, ResponsiveBreakpoint.medium);
      expect(mediumData.spacingExtraSmall, 8.0);
      expect(mediumData.spacingSmall, 20.0);
      expect(mediumData.spacingMedium, 24.0);
      expect(mediumData.spacingLarge, 32.0);
      expect(mediumData.spacingExtraLarge, 40.0);
      expect(
        mediumData.containerPadding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
      expect(mediumData.dialogPadding, const EdgeInsets.all(24));
      expect(
        mediumData.dialogTitlePadding,
        const EdgeInsets.fromLTRB(24, 24, 24, 16),
      );
      expect(
        mediumData.dialogContentPadding,
        const EdgeInsets.fromLTRB(24, 20, 24, 16),
      );
      expect(
        mediumData.dialogActionsPadding,
        const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
    });
  });

  group('ResponsiveExtensionV2 on BuildContext', () {
    testWidgets('320 is a small screen', (tester) async {
      final context = await pumpWithWidth(tester, 320);

      expect(
        ResponsiveExtensionV2(context).responsive.breakpoint,
        ResponsiveBreakpoint.small,
      );
      expect(ResponsiveExtensionV2(context).screenWidth, 320);
      expect(ResponsiveExtensionV2(context).screenHeight, 800);
      expect(ResponsiveExtensionV2(context).isSmallScreen, isTrue);
      expect(ResponsiveExtensionV2(context).isMediumScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isLargeScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isExtraLargeScreen, isFalse);
      expect(ResponsiveExtensionV2(context).horizontalPadding, 16.0);
      expect(ResponsiveExtensionV2(context).verticalPadding, 12.0);
      expect(ResponsiveExtensionV2(context).maxContentWidth, 420.0);
      expect(
        ResponsiveExtensionV2(context).responsiveFontSize(16),
        closeTo(14.4, 0.0001),
      );
      expect(ResponsiveExtensionV2(context).responsiveFontSize(null), isNull);
      expect(
        ResponsiveExtensionV2(context).spacing(ResponsiveSpacing.extraSmall),
        4.0,
      );
      expect(ResponsiveExtensionV2(context).spacingExtraSmall, 4.0);
      expect(ResponsiveExtensionV2(context).spacingSmall, 16.0);
      expect(ResponsiveExtensionV2(context).spacingMedium, 20.0);
      expect(ResponsiveExtensionV2(context).spacingLarge, 24.0);
      expect(ResponsiveExtensionV2(context).spacingExtraLarge, 32.0);
      expect(
        ResponsiveExtensionV2(context).containerPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
      expect(
        ResponsiveExtensionV2(context).dialogPadding,
        const EdgeInsets.all(16),
      );
      expect(
        ResponsiveExtensionV2(context).dialogTitlePadding,
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        ResponsiveExtensionV2(context).dialogContentPadding,
        const EdgeInsets.fromLTRB(16, 16, 16, 8),
      );
      expect(
        ResponsiveExtensionV2(context).dialogActionsPadding,
        const EdgeInsets.fromLTRB(8, 0, 8, 8),
      );
    });

    testWidgets('700 is a large screen in v2', (tester) async {
      final context = await pumpWithWidth(tester, 700);

      expect(ResponsiveExtensionV2(context).isSmallScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isMediumScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isLargeScreen, isTrue);
      expect(ResponsiveExtensionV2(context).isExtraLargeScreen, isFalse);
      expect(ResponsiveExtensionV2(context).horizontalPadding, 32.0);
      expect(ResponsiveExtensionV2(context).maxContentWidth, 500.0);
      expect(
        ResponsiveExtensionV2(context).responsiveFontSize(16),
        closeTo(19.2, 0.0001),
      );
      expect(
        ResponsiveExtensionV2(context).spacing(ResponsiveSpacing.large),
        32.0,
      );
    });

    testWidgets('1000 is an extra large screen in v2', (tester) async {
      final context = await pumpWithWidth(tester, 1000);

      expect(ResponsiveExtensionV2(context).isSmallScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isMediumScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isLargeScreen, isFalse);
      expect(ResponsiveExtensionV2(context).isExtraLargeScreen, isTrue);
      expect(ResponsiveExtensionV2(context).horizontalPadding, 32.0);
      expect(ResponsiveExtensionV2(context).maxContentWidth, 500.0);
      expect(
        ResponsiveExtensionV2(context).responsiveFontSize(16),
        closeTo(22.4, 0.0001),
      );
    });

    testWidgets('responsive getter reflects the current MediaQuery', (
      tester,
    ) async {
      var context = await pumpWithWidth(tester, 320);
      expect(ResponsiveExtensionV2(context).responsive.screenWidth, 320);

      context = await pumpWithWidth(tester, 1000);
      expect(ResponsiveExtensionV2(context).responsive.screenWidth, 1000);
    });
  });

  group('barrel export', () {
    testWidgets('context.isLargeScreen resolves to the v2 breakpoint scheme', (
      tester,
    ) async {
      // Only ResponsiveExtensionV2 is exported by app/core/responsive/
      // responsive.dart, so a 700-wide screen is "large" ([600, 900)).
      final context = await pumpWithWidth(tester, 700);

      expect(context.isLargeScreen, isTrue);
      expect(context.horizontalPadding, 32.0);
      expect(context.maxContentWidth, 500.0);
    });
  });
}
