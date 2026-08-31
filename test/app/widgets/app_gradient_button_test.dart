import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/buttons/app_gradient_button.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('AppGradientButton', () {
    testWidgets('renders the text', (tester) async {
      await tester.pumpWidget(wrap(const AppGradientButton(text: 'Continue')));

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppGradientButton(text: 'Continue', onPressed: () => pressCount++),
        ),
      );

      await tester.tap(find.byType(AppGradientButton));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      var longPressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppGradientButton(
            text: 'Continue',
            onPressed: () {},
            onLongPress: () => longPressCount++,
          ),
        ),
      );

      await tester.longPress(find.byType(AppGradientButton));
      await tester.pump();

      expect(longPressCount, 1);
    });

    testWidgets('is disabled when no onPressed is given', (tester) async {
      await tester.pumpWidget(wrap(const AppGradientButton(text: 'Continue')));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(button.enabled, isFalse);
    });

    testWidgets('isLoading shows a spinner and disables callbacks', (
      tester,
    ) async {
      var pressCount = 0;
      var longPressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppGradientButton(
            text: 'Continue',
            isLoading: true,
            onPressed: () => pressCount++,
            onLongPress: () => longPressCount++,
          ),
        ),
      );

      expect(find.text('Continue'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(button.onLongPress, isNull);

      await tester.tap(find.byType(AppGradientButton));
      await tester.longPress(find.byType(AppGradientButton));
      await tester.pump();

      expect(pressCount, 0);
      expect(longPressCount, 0);
    });

    testWidgets('uses the provided width and height', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppGradientButton(text: 'Continue', width: 200, height: 50),
        ),
      );

      final size = tester.getSize(find.byType(AppGradientButton));
      expect(size.width, 200);
      expect(size.height, 50);
    });

    testWidgets('defaults to 320x44', (tester) async {
      await tester.pumpWidget(wrap(const AppGradientButton(text: 'Continue')));

      final size = tester.getSize(find.byType(AppGradientButton));
      expect(size.width, 320);
      expect(size.height, 44);
    });

    testWidgets('paints the gradient by default', (tester) async {
      await tester.pumpWidget(wrap(const AppGradientButton(text: 'Continue')));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.border, isNull);
    });

    testWidgets('isBordered replaces the gradient with a primary border', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AppGradientButton(text: 'Continue', isBordered: true)),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('isDestructive uses the errorContainer color', (tester) async {
      await tester.pumpWidget(
        wrap(const AppGradientButton(text: 'Delete', isDestructive: true)),
      );

      final context = tester.element(find.byType(AppGradientButton));
      final errorContainer = Theme.of(context).colorScheme.errorContainer;

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, everyElement(errorContainer));
      expect(decoration.border, isNull);
    });

    testWidgets('applies a custom textStyle', (tester) async {
      const style = TextStyle(fontSize: 30, color: Colors.purple);
      await tester.pumpWidget(
        wrap(const AppGradientButton(text: 'Continue', textStyle: style)),
      );

      final text = tester.widget<Text>(find.text('Continue'));
      expect(text.style, style);
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
