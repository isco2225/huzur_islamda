import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class DhikrStatusDisplayer extends StatelessWidget {
  const DhikrStatusDisplayer({super.key, required this.dhikr});
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (dhikr.isCompleted) {
      return Text(
        'Tamamlandı!',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
      );
    } else if (dhikr.isExpired && !dhikr.isCompleted) {
      return Text(
        'Süresi Doldu',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
      );
    } else {
      return Text(
        'Devam Et',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.info),
      );
    }
  }
}
