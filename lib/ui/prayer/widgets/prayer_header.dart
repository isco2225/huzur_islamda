import 'package:flutter/material.dart';

import '../../../domain/domain.dart';

class PrayerHeader extends StatelessWidget {
  const PrayerHeader({
    super.key,
    required this.user,
    required this.onLocationTap,
  });

  final User user;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ülke ve Şehir bilgisi
        Expanded(
          child: GestureDetector(
            onTap: onLocationTap,
            child: Text(
              _buildLocationText(user),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Tarih bilgisi
        Text(
          _formatTodayDate(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _buildLocationText(User user) {
    if (user.country != null && user.city != null) {
      return '${user.city}, ${user.country}';
    } else if (user.country != null) {
      return user.country!;
    } else if (user.city != null) {
      return user.city!;
    }
    return 'Konum seçilmedi';
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    final day = now.day;
    final month = _getTurkishMonthName(now.month);
    final weekday = _getTurkishWeekdayName(now.weekday);

    return '$day $month - $weekday';
  }

  String _getTurkishMonthName(int month) {
    const months = [
      'ocak',
      'şubat',
      'mart',
      'nisan',
      'mayıs',
      'haziran',
      'temmuz',
      'ağustos',
      'eylül',
      'ekim',
      'kasım',
      'aralık',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  String _getTurkishWeekdayName(int weekday) {
    const weekdays = [
      'Pazartesi', // 1
      'Salı', // 2
      'Çarşamba', // 3
      'Perşembe', // 4
      'Cuma', // 5
      'Cumartesi', // 6
      'Pazar', // 7
    ];
    if (weekday >= 1 && weekday <= 7) {
      return weekdays[weekday - 1];
    }
    return '';
  }
}
