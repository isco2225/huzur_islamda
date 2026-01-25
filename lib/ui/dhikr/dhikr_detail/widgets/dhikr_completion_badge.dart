import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class DhikrCompletionBadge extends StatelessWidget {
  const DhikrCompletionBadge({
    super.key,
    required this.responsiveWidth,
    required this.dhikr,
  });

  final double responsiveWidth;
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsiveWidth,
      padding: EdgeInsets.all(context.horizontalPadding * 0.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dhikr.isCompleted
              ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
              : [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.spacingMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            dhikr.isCompleted ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: context.spacingMedium),
          Text(
            dhikr.isCompleted
                ? 'Tamamladınız, Tebrikler!'
                : 'Zikir Tamamlanamadı!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
