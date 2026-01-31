import 'package:flutter/material.dart';

import '../../../app/app.dart';

class DhikrPopMenuButton extends StatelessWidget {
  const DhikrPopMenuButton({
    super.key,
    required this.onCreateDhikrsForPrayerTapped,
  });
  final void Function() onCreateDhikrsForPrayerTapped;
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: responsive.isSmallScreen ? 20.0 : 24.0),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            onCreateDhikrsForPrayerTapped();
          },
          value: 'create_dhikrs_for_prayer',
          child: Row(
            children: [
              Icon(Icons.mosque, size: 20),
              SizedBox(width: 8),
              Text('Namaz Zikirleri Oluştur'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            print('Ruh haline göre zikir oluştur');
          },
          value: 'create_dhikr_by_mood',
          child: Row(
            children: [
              Icon(Icons.mood, size: 20),
              SizedBox(width: 8),
              Text('Ruh haline göre zikir oluştur.'),
            ],
          ),
        ),
      ],
    );
  }
}
