import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late ValueNotifier<PrayerTimes?> prayerTimes;
  late ValueNotifier<bool> isLoading;

  setUp(() {
    prayerTimes = ValueNotifier<PrayerTimes?>(null);
    isLoading = ValueNotifier<bool>(false);
  });

  tearDown(() {
    prayerTimes.dispose();
    isLoading.dispose();
  });

  Widget build() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PrayerTimesCard(prayerTimes: prayerTimes, isLoading: isLoading),
        ),
      ),
    );
  }

  testWidgets('shows the loading message while a fetch is running', (
    tester,
  ) async {
    isLoading.value = true;
    await tester.pumpWidget(build());

    expect(find.text(PrayerTimesCard.loadingMessage), findsOneWidget);
    expect(find.text(PrayerTimesCard.failureMessage), findsNothing);
  });

  testWidgets('shows the failure message when nothing loaded and idle', (
    tester,
  ) async {
    await tester.pumpWidget(build());

    expect(find.text(PrayerTimesCard.failureMessage), findsOneWidget);
    expect(find.text(PrayerTimesCard.loadingMessage), findsNothing);
  });

  testWidgets('switches from loading to failure when the fetch ends empty', (
    tester,
  ) async {
    isLoading.value = true;
    await tester.pumpWidget(build());
    expect(find.text(PrayerTimesCard.loadingMessage), findsOneWidget);

    isLoading.value = false;
    await tester.pump();

    expect(find.text(PrayerTimesCard.failureMessage), findsOneWidget);
  });

  testWidgets('renders the prayer times list once times are available', (
    tester,
  ) async {
    await tester.pumpWidget(build());

    prayerTimes.value = Fixtures.prayerTimes();
    await tester.pump();

    expect(find.byType(PrayerTimesList), findsOneWidget);
    expect(find.text(PrayerTimesCard.failureMessage), findsNothing);
    expect(find.text(PrayerTimesCard.loadingMessage), findsNothing);

    // PrayerTimesList owns a periodic Timer; unmount it so the timer is
    // cancelled before the test binding checks for pending timers.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
