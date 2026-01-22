import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import 'prayer_time_displayer.dart';

class PrayerTimesList extends StatefulWidget {
  const PrayerTimesList({super.key, required this.prayerTimes});

  final PrayerTimes prayerTimes;

  @override
  State<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends State<PrayerTimesList> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her dakika güncelle (şu anki vakti highlight etmek için)
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayerTime = widget.prayerTimes.getCurrentPrayerTime();

    return Column(
      children: [
        PrayerTimeDisplayer(
          name: 'İmsak',
          time: _formatTime(widget.prayerTimes.fajr),
          isHighlighted: currentPrayerTime == 'İmsak',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Güneş',
          time: _formatTime(widget.prayerTimes.sunrise),
          isHighlighted: currentPrayerTime == 'Güneş',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Öğle',
          time: _formatTime(widget.prayerTimes.dhuhr),
          isHighlighted: currentPrayerTime == 'Öğle',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'İkindi',
          time: _formatTime(widget.prayerTimes.asr),
          isHighlighted: currentPrayerTime == 'İkindi',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Akşam',
          time: _formatTime(widget.prayerTimes.maghrib),
          isHighlighted: currentPrayerTime == 'Akşam',
        ),
        _buildDivider(),
        PrayerTimeDisplayer(
          name: 'Yatsı',
          time: _formatTime(widget.prayerTimes.isha),
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
