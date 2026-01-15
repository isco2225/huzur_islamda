import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class RemainingTimeToNextPrayer extends StatefulWidget {
  const RemainingTimeToNextPrayer({super.key, required this.prayerTimes});

  final PrayerTimes? prayerTimes;

  @override
  State<RemainingTimeToNextPrayer> createState() =>
      _RemainingTimeToNextPrayerState();
}

class _RemainingTimeToNextPrayerState extends State<RemainingTimeToNextPrayer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her saniye güncelle
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    if (widget.prayerTimes == null) {
      return const SizedBox.shrink();
    }

    final nextPrayer = widget.prayerTimes!.getNextPrayerTime();
    if (nextPrayer == null) {
      return const SizedBox.shrink();
    }

    final remainingTime = widget.prayerTimes!.getRemainingTimeToNextPrayer();
    if (remainingTime == null) {
      return const SizedBox.shrink();
    }

    final formattedTime = _formatDuration(remainingTime);
    final prayerName = nextPrayer.name;

    return Container(
      padding: context.containerPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$prayerName\'e Kalan Süre',
            style: TextStyle(
              fontSize: context.isSmallScreen ? 12 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
          Row(
            children: [
              Icon(Icons.timer_sharp, size: 20, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: context.isSmallScreen ? 12 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Duration'ı "X Saat Y Dakika" veya "Y Dakika" formatına çevirir
  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Vakit geçti';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours Saat $minutes Dakika';
    } else if (minutes > 0) {
      return '$minutes Dakika $seconds Saniye';
    } else {
      return '$seconds Saniye';
    }
  }
}
