import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingSmall,
        vertical: context.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.duaColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PRO',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.duaColor,
            ),
          ),
          Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.duaColor,
            size: context.isSmallScreen ? 20 : 24,
          ),
        ],
      ),
    );
  }
}
