import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/constants/app_colors.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_data.dart';
import 'package:huzur_islamda/app/widgets/texts/subtitle_text.dart';

Widget wrap(Widget child, {TextScaler? textScaler}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final base = MediaQuery.of(context);
        return MediaQuery(
          data: base.copyWith(textScaler: textScaler ?? base.textScaler),
          child: Scaffold(body: Center(child: child)),
        );
      },
    ),
  );
}

void main() {
  group('SubtitleText', () {
    testWidgets('renders the given text', (tester) async {
      await tester.pumpWidget(wrap(const SubtitleText(text: 'Alt başlık')));

      expect(find.text('Alt başlık'), findsOneWidget);
    });

    testWidgets('is centered, regular weight and subtitle colored', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const SubtitleText(text: 'Alt başlık')));

      final context = tester.element(find.byType(SubtitleText));
      final bodyLarge = Theme.of(context).textTheme.bodyLarge;

      final text = tester.widget<Text>(find.text('Alt başlık'));
      expect(text.textAlign, TextAlign.center);
      expect(text.style?.fontWeight, FontWeight.w400);
      expect(text.style?.color, AppColors.subtitleColor);
      // The font size is bodyLarge scaled by the responsive multiplier for
      // the current breakpoint (the default 800x600 test surface is "large").
      expect(
        text.style?.fontSize,
        ResponsiveData.fromContext(context).responsiveFontSize(
          bodyLarge?.fontSize,
        ),
      );
      expect(text.style?.fontSize, isNot(bodyLarge?.fontSize));
    });

    testWidgets('honours the MediaQuery textScaler', (tester) async {
      await tester.pumpWidget(wrap(const SubtitleText(text: 'Alt başlık')));
      final unscaledHeight = tester.getSize(find.text('Alt başlık')).height;

      await tester.pumpWidget(
        wrap(
          const SubtitleText(text: 'Alt başlık'),
          textScaler: const TextScaler.linear(2),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(SubtitleText),
          matching: find.byType(RichText),
        ),
      );
      expect(richText.textScaler, const TextScaler.linear(2));
      // Glyph metrics round to whole pixels, hence the small tolerance.
      expect(
        tester.getSize(find.text('Alt başlık')).height,
        closeTo(unscaledHeight * 2, 2),
      );
    });
  });
}
