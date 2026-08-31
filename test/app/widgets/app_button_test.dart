import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/constants/app_colors.dart';
import 'package:huzur_islamda/app/utils/command.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/app/widgets/buttons/app_button.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('AppButton with a ValueNotifier', () {
    testWidgets('shows the text and calls onPressed when not running', (
      tester,
    ) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);
      var pressCount = 0;

      await tester.pumpWidget(
        wrap(
          AppButton(
            onPressed: () => pressCount++,
            text: 'Save',
            running: running,
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('shows a spinner and ignores taps while running', (
      tester,
    ) async {
      final running = ValueNotifier<bool>(true);
      addTearDown(running.dispose);
      var pressCount = 0;

      await tester.pumpWidget(
        wrap(
          AppButton(
            onPressed: () => pressCount++,
            text: 'Save',
            running: running,
          ),
        ),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressCount, 0);
    });

    testWidgets('reacts to notifier changes in both directions', (
      tester,
    ) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);

      await tester.pumpWidget(
        wrap(AppButton(onPressed: () {}, text: 'Save', running: running)),
      );
      expect(find.text('Save'), findsOneWidget);

      running.value = true;
      await tester.pump();
      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      running.value = false;
      await tester.pump();
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses AppColors.primary as the default background', (
      tester,
    ) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);

      await tester.pumpWidget(
        wrap(AppButton(onPressed: () {}, text: 'Save', running: running)),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), AppColors.primary);
    });

    testWidgets('honours a custom backgroundColor', (tester) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);

      await tester.pumpWidget(
        wrap(
          AppButton(
            onPressed: () {},
            text: 'Save',
            running: running,
            backgroundColor: Colors.orange,
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), Colors.orange);
    });

    testWidgets('renders the label in bold white text', (tester) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);

      await tester.pumpWidget(
        wrap(AppButton(onPressed: () {}, text: 'Save', running: running)),
      );

      final text = tester.widget<Text>(find.text('Save'));
      expect(text.style?.color, Colors.white);
      expect(text.style?.fontWeight, FontWeight.bold);
    });
  });

  group('AppButton driven by a real Command0', () {
    testWidgets('shows a spinner while the command action is in flight', (
      tester,
    ) async {
      final completer = Completer<Result<int>>();
      var actionCalls = 0;
      final command = Command0<int>(() {
        actionCalls++;
        return completer.future;
      }, debugLabel: 'test');
      addTearDown(command.dispose);

      await tester.pumpWidget(
        wrap(
          AppButton(
            onPressed: command.execute,
            text: 'Run',
            running: command.running,
          ),
        ),
      );
      expect(find.text('Run'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(actionCalls, 1);
      expect(command.running.value, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Run'), findsNothing);

      // A second tap while running must not start the action again.
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(actionCalls, 1);

      completer.complete(const Ok(42));
      await tester.pump();

      expect(command.running.value, isFalse);
      expect(command.completed.value, isTrue);
      expect(find.text('Run'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('returns to idle after the command reports an Error', (
      tester,
    ) async {
      final completer = Completer<Result<int>>();
      final command = Command0<int>(
        () => completer.future,
        debugLabel: 'test',
      );
      addTearDown(command.dispose);

      await tester.pumpWidget(
        wrap(
          AppButton(
            onPressed: command.execute,
            text: 'Run',
            running: command.running,
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Error<int>(Exception('boom')));
      await tester.pump();

      expect(command.error.value, isTrue);
      expect(find.text('Run'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
