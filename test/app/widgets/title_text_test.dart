import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/constants/app_colors.dart';
import 'package:huzur_islamda/app/core/responsive/responsive_data.dart';
import 'package:huzur_islamda/app/widgets/texts/title_text.dart';

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
  group('TitleText', () {
    testWidgets('renders the given title', (tester) async {
      await tester.pumpWidget(wrap(const TitleText(title: 'Hoş geldiniz')));

      expect(find.text('Hoş geldiniz'), findsOneWidget);
    });

    testWidgets('uses semi-bold secondary color based on titleLarge', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TitleText(title: 'Hoş geldiniz')));

      final context = tester.element(find.byType(TitleText));
      final titleLarge = Theme.of(context).textTheme.titleLarge;

      final text = tester.widget<Text>(find.text('Hoş geldiniz'));
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.style?.color, AppColors.secondary);
      expect(text.style?.fontFamily, titleLarge?.fontFamily);
      // The font size is titleLarge scaled by the responsive multiplier for
      // the current breakpoint (the default 800x600 test surface is "large").
      expect(
        text.style?.fontSize,
        ResponsiveData.fromContext(context).responsiveFontSize(
          titleLarge?.fontSize,
        ),
      );
      expect(text.style?.fontSize, isNot(titleLarge?.fontSize));
    });

    testWidgets('honours the MediaQuery textScaler', (tester) async {
      await tester.pumpWidget(wrap(const TitleText(title: 'Hoş geldiniz')));
      final unscaledHeight = tester.getSize(find.text('Hoş geldiniz')).height;

      await tester.pumpWidget(
        wrap(
          const TitleText(title: 'Hoş geldiniz'),
          textScaler: const TextScaler.linear(2),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(TitleText),
          matching: find.byType(RichText),
        ),
      );
      expect(richText.textScaler, const TextScaler.linear(2));
      // Glyph metrics round to whole pixels, hence the small tolerance.
      expect(
        tester.getSize(find.text('Hoş geldiniz')).height,
        closeTo(unscaledHeight * 2, 2),
      );
    });
  });
}
