import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/texts/text_field_title.dart';

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
  group('TextFieldTitle', () {
    testWidgets('renders the given text', (tester) async {
      await tester.pumpWidget(wrap(const TextFieldTitle(text: 'E-posta')));

      expect(find.text('E-posta'), findsOneWidget);
    });

    testWidgets('is centered, medium weight and grey.shade700', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TextFieldTitle(text: 'E-posta')));

      final text = tester.widget<Text>(find.text('E-posta'));
      expect(text.textAlign, TextAlign.center);
      expect(text.style?.fontWeight, FontWeight.w500);
      expect(text.style?.color, Colors.grey.shade700);
    });

    testWidgets('honours the MediaQuery textScaler', (tester) async {
      await tester.pumpWidget(wrap(const TextFieldTitle(text: 'E-posta')));
      final unscaledHeight = tester.getSize(find.text('E-posta')).height;

      await tester.pumpWidget(
        wrap(
          const TextFieldTitle(text: 'E-posta'),
          textScaler: const TextScaler.linear(2),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(TextFieldTitle),
          matching: find.byType(RichText),
        ),
      );
      expect(richText.textScaler, const TextScaler.linear(2));
      // Glyph metrics round to whole pixels, hence the small tolerance.
      expect(
        tester.getSize(find.text('E-posta')).height,
        closeTo(unscaledHeight * 2, 2),
      );
    });
  });
}
