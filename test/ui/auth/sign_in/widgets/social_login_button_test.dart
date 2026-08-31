import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/ui/auth/sign_in/widgets/social_login_button.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

void main() {
  group('SocialLoginButton', () {
    testWidgets('shows icon and text and calls onPressed when idle', (
      tester,
    ) async {
      var pressCount = 0;

      await tester.pumpWidget(
        wrap(
          SocialLoginButton(
            text: 'Google ile Giriş Yap',
            icon: const Icon(Icons.g_mobiledata),
            onPressed: () => pressCount++,
          ),
        ),
      );

      expect(find.text('Google ile Giriş Yap'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(SocialLoginButton));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('shows a spinner and ignores taps while running', (
      tester,
    ) async {
      final running = ValueNotifier<bool>(false);
      addTearDown(running.dispose);
      var pressCount = 0;

      await tester.pumpWidget(
        wrap(
          SocialLoginButton(
            text: 'Google ile Giriş Yap',
            icon: const Icon(Icons.g_mobiledata),
            onPressed: () => pressCount++,
            running: running,
          ),
        ),
      );

      running.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Google ile Giriş Yap'), findsNothing);
      expect(find.byIcon(Icons.g_mobiledata), findsNothing);

      await tester.tap(find.byType(SocialLoginButton));
      await tester.pump();
      expect(pressCount, 0);

      running.value = false;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Google ile Giriş Yap'), findsOneWidget);

      await tester.tap(find.byType(SocialLoginButton));
      await tester.pump();
      expect(pressCount, 1);
    });

    testWidgets('is dimmed and ignores taps while blocked', (tester) async {
      final blocked = ValueNotifier<bool>(true);
      addTearDown(blocked.dispose);
      var pressCount = 0;

      await tester.pumpWidget(
        wrap(
          SocialLoginButton(
            text: 'Apple ile Giriş Yap',
            icon: const Icon(Icons.apple),
            onPressed: () => pressCount++,
            blocked: blocked,
          ),
        ),
      );

      // Label stays visible (no spinner) but the button is dimmed.
      expect(find.text('Apple ile Giriş Yap'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, lessThan(1));

      await tester.tap(find.byType(SocialLoginButton));
      await tester.pump();
      expect(pressCount, 0);

      blocked.value = false;
      await tester.pump();

      await tester.tap(find.byType(SocialLoginButton));
      await tester.pump();
      expect(pressCount, 1);
    });
  });
}
