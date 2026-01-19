import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/app.dart';

class NoLocationToShow extends StatelessWidget {
  const NoLocationToShow({
    super.key,
    required this.onTap,
    required this.running,
  });
  final VoidCallback onTap;
  final ValueListenable<bool> running;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
        Text(
          'Konum seçilmedi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        AppButton(onPressed: onTap, text: 'Konum Seç', running: running),
      ],
    );
  }
}
