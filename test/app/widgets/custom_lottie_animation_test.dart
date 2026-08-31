import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/animations/custom_lottie_animation.dart';
import 'package:lottie/lottie.dart';

const missingAsset = 'assets/animations/does_not_exist.json';

void main() {
  group('CustomLottieAnimation', () {
    testWidgets('renders the error text when the asset does not exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLottieAnimation(assetPath: missingAsset),
          ),
        ),
      );
      // The asset load is asynchronous; give the FutureBuilder a few frames.
      await tester.pump();
      await tester.pump();

      // Lottie reports the load failure through FlutterError.onError before
      // handing it to errorBuilder; drain it so the test stays green.
      final reported = tester.takeException();
      expect(reported, anyOf(isNull, isA<FlutterError>()));

      expect(find.textContaining('Lottie Hatası'), findsOneWidget);
    });

    testWidgets('forwards size, fit, repeat and animate to Lottie', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLottieAnimation(
              assetPath: missingAsset,
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              repeat: false,
              animate: false,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      tester.takeException();

      final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
      expect(lottie.width, 120);
      expect(lottie.height, 80);
      expect(lottie.fit, BoxFit.cover);
      expect(lottie.repeat, isFalse);
      expect(lottie.animate, isFalse);
      expect(lottie.errorBuilder, isNotNull);
    });

    testWidgets('defaults to BoxFit.contain, repeat and animate', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLottieAnimation(assetPath: missingAsset),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      tester.takeException();

      final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
      expect(lottie.fit, BoxFit.contain);
      expect(lottie.repeat, isTrue);
      expect(lottie.animate, isTrue);
    });
  });
}
