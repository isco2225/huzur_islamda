import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import 'prayer_times_list.dart';

/// The bordered card on the prayer screen that shows today's prayer times,
/// a loading message while they are being fetched, or an error message when
/// the fetch finished without producing any times.
class PrayerTimesCard extends StatelessWidget {
  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
    required this.isLoading,
  });

  final ValueListenable<PrayerTimes?> prayerTimes;
  final ValueListenable<bool> isLoading;

  static const String loadingMessage = 'Namaz vakitleri yükleniyor...';
  static const String failureMessage =
      'Namaz vakitleri alınamadı. Konumu seçip tekrar deneyin.';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: ValueListenableBuilder<PrayerTimes?>(
        valueListenable: prayerTimes,
        builder: (context, times, _) {
          if (times != null) {
            return PrayerTimesList(prayerTimes: times);
          }
          return ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    loading ? loadingMessage : failureMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
