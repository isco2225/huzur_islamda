import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/snackbar.dart';

/// Pumps a MaterialApp + Scaffold and returns the Scaffold body's context,
/// which sits below the ScaffoldMessenger.
Future<BuildContext> pumpScaffold(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: Placeholder())),
  );
  return tester.element(find.byType(Placeholder));
}

/// Lets the SnackBar's auto-dismiss timer elapse so no timers are pending
/// when the test ends.
Future<void> dismissSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  group('showSuccessSnackBar', () {
    testWidgets('shows the message on a greenAccent SnackBar', (tester) async {
      final context = await pumpScaffold(tester);

      context.showSuccessSnackBar('ok');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('ok'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.greenAccent);

      await dismissSnackBars(tester);
    });

    testWidgets('renders the message in black text', (tester) async {
      final context = await pumpScaffold(tester);

      context.showSuccessSnackBar('ok');
      await tester.pump();

      final text = tester.widget<Text>(find.text('ok'));
      expect(text.style?.color, Colors.black);

      await dismissSnackBars(tester);
    });
  });

  group('showErrorSnackBar', () {
    testWidgets('shows the message on a redAccent SnackBar', (tester) async {
      final context = await pumpScaffold(tester);

      context.showErrorSnackBar('err');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('err'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.redAccent);

      await dismissSnackBars(tester);
    });

    testWidgets('uses the theme onSurface color for the text', (tester) async {
      final context = await pumpScaffold(tester);
      final expectedColor = Theme.of(context).colorScheme.onSurface;

      context.showErrorSnackBar('err');
      await tester.pump();

      final text = tester.widget<Text>(find.text('err'));
      expect(text.style?.color, expectedColor);

      await dismissSnackBars(tester);
    });

    testWidgets('hides a currently visible SnackBar before showing', (
      tester,
    ) async {
      final context = await pumpScaffold(tester);

      context.showSuccessSnackBar('first');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('first'), findsOneWidget);

      context.showErrorSnackBar('second');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);

      await dismissSnackBars(tester);
    });
  });
}
