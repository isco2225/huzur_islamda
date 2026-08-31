import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/app.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  group('AppInitializationErrorView', () {
    testWidgets('shows the user-facing message of the error', (tester) async {
      await tester.pumpWidget(
        AppInitializationErrorView(
          error: const UserMessageException('Uygulama başlatılamadı'),
          onRetry: () {},
          onContinue: () {},
        ),
      );

      expect(find.text('Uygulama başlatılamadı'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('maps typed domain exceptions through the localization', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppInitializationErrorView(
          error: const AppLoadFailed(),
          onRetry: () {},
          onContinue: () {},
        ),
      );

      expect(
        find.text('Uygulama tercihleri yüklenirken bir hata oluştu'),
        findsOneWidget,
      );
    });

    testWidgets('falls back to a generic message when there is no error', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppInitializationErrorView(
          error: null,
          onRetry: () {},
          onContinue: () {},
        ),
      );

      expect(
        find.text(AppInitializationErrorView.fallbackMessage),
        findsOneWidget,
      );
    });

    testWidgets('retry and continue buttons invoke their callbacks', (
      tester,
    ) async {
      var retries = 0;
      var continues = 0;
      await tester.pumpWidget(
        AppInitializationErrorView(
          error: Exception('boom'),
          onRetry: () => retries++,
          onContinue: () => continues++,
        ),
      );

      await tester.tap(find.text(AppInitializationErrorView.retryLabel));
      await tester.pump();
      expect(retries, 1);
      expect(continues, 0);

      await tester.tap(find.text(AppInitializationErrorView.continueLabel));
      await tester.pump();
      expect(retries, 1);
      expect(continues, 1);
    });
  });
}
