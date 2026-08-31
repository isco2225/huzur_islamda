import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/buttons/app_resend_code_button.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

/// The widget owns a periodic Timer; pumping it out of the tree cancels the
/// timer so the test binding does not report a pending timer.
Future<void> tearDownWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

final RegExp digitsOnly = RegExp(r'^\d+$');

void main() {
  group('AppResendCodeButton', () {
    testWidgets('with no lastResendDate shows the text and is enabled', (
      tester,
    ) async {
      var pressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: null,
            onPressed: () => pressCount++,
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );

      expect(find.text('Resend'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );

      await tester.tap(find.byType(AppResendCodeButton));
      await tester.pump();
      expect(pressCount, 1);

      await tearDownWidget(tester);
    });

    testWidgets('with lastResendDate now shows a countdown', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: DateTime.now(),
            onPressed: () {},
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );

      expect(find.text('Resend'), findsNothing);
      final label = tester.widget<Text>(find.byType(Text)).data!;
      expect(label, matches(digitsOnly));
      final secondsLeft = int.parse(label);
      expect(secondsLeft, inInclusiveRange(58, 60));

      await tearDownWidget(tester);
    });

    testWidgets('countdown reflects the elapsed time since lastResendDate', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: DateTime.now().subtract(
              const Duration(seconds: 30),
            ),
            onPressed: () {},
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );

      final label = tester.widget<Text>(find.byType(Text)).data!;
      expect(label, matches(digitsOnly));
      expect(int.parse(label), inInclusiveRange(28, 30));

      await tearDownWidget(tester);
    });

    testWidgets('periodic timer keeps rebuilding without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: DateTime.now(),
            onPressed: () {},
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );

      // Durations.long2 (500ms) periodic timer: several ticks.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(AppResendCodeButton), findsOneWidget);

      await tearDownWidget(tester);
    });

    testWidgets('shows the text again once 60 seconds have passed', (
      tester,
    ) async {
      var pressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: DateTime.now().subtract(
              const Duration(seconds: 61),
            ),
            onPressed: () => pressCount++,
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );

      expect(find.text('Resend'), findsOneWidget);

      await tester.tap(find.byType(AppResendCodeButton));
      await tester.pump();
      expect(pressCount, 1);

      await tearDownWidget(tester);
    });

    testWidgets('isLoading shows a spinner and blocks taps', (tester) async {
      var pressCount = 0;
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: null,
            onPressed: () => pressCount++,
            text: 'Resend',
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Resend'), findsNothing);

      await tester.tap(find.byType(AppResendCodeButton));
      await tester.pump();
      expect(pressCount, 0);

      await tearDownWidget(tester);
    });

    testWidgets('cancels its timer when removed from the tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppResendCodeButton(
            lastResendDate: DateTime.now(),
            onPressed: () {},
            text: 'Resend',
            isLoading: false,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tearDownWidget(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    group(
      'countdown disables the button',
      () {
        testWidgets('is disabled while the countdown is running', (
          tester,
        ) async {
          var pressCount = 0;
          await tester.pumpWidget(
            wrap(
              AppResendCodeButton(
                lastResendDate: DateTime.now(),
                onPressed: () => pressCount++,
                text: 'Resend',
                isLoading: false,
              ),
            ),
          );

          expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isFalse,
          );

          await tester.tap(find.byType(AppResendCodeButton));
          await tester.pump();
          expect(pressCount, 0);

          await tearDownWidget(tester);
        });
      },
    );

    group(
      'custom resendCooldown',
      () {
        testWidgets('a 5 second cooldown is respected', (tester) async {
          await tester.pumpWidget(
            wrap(
              AppResendCodeButton(
                lastResendDate: DateTime.now().subtract(
                  const Duration(seconds: 6),
                ),
                resendCooldown: 5,
                onPressed: () {},
                text: 'Resend',
                isLoading: false,
              ),
            ),
          );

          // 6s elapsed > 5s cooldown, so the label should be back.
          expect(find.text('Resend'), findsOneWidget);

          await tearDownWidget(tester);
        });

        testWidgets('countdown is computed from resendCooldown', (
          tester,
        ) async {
          await tester.pumpWidget(
            wrap(
              AppResendCodeButton(
                lastResendDate: DateTime.now(),
                resendCooldown: 5,
                onPressed: () {},
                text: 'Resend',
                isLoading: false,
              ),
            ),
          );

          final label = tester.widget<Text>(find.byType(Text)).data!;
          expect(int.parse(label), inInclusiveRange(4, 5));

          await tearDownWidget(tester);
        });
      },
    );
  });
}
