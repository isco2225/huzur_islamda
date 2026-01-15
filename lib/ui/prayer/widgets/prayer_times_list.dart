import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import 'prayer_time_displayer.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({super.key, required this.prayerTimes});

  final PrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    final currentPrayerTime = prayerTimes.getCurrentPrayerTime();

    return Column(
      children: [
        PrayerTimeDisplayer(
          name: 'İmsak',
          time: _formatTime(prayerTimes.fajr),
          isHighlighted: currentPrayerTime == 'İmsak',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Öğle',
          time: _formatTime(prayerTimes.dhuhr),
          isHighlighted: currentPrayerTime == 'Öğle',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'İkindi',
          time: _formatTime(prayerTimes.asr),
          isHighlighted: currentPrayerTime == 'İkindi',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Akşam',
          time: _formatTime(prayerTimes.maghrib),
          isHighlighted: currentPrayerTime == 'Akşam',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Yatsı',
          time: _formatTime(prayerTimes.isha),
          isHighlighted: currentPrayerTime == 'Yatsı',
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, height: 1, thickness: 1);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
