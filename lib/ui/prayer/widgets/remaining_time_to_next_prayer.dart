import 'package:flutter/material.dart';

import '../../../app/app.dart';

class RemainingTimeToNextPrayer extends StatelessWidget {
  const RemainingTimeToNextPrayer({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Ezana Kalan Süre',
            style: TextStyle(
              fontSize: context.isSmallScreen ? 12 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
          Row(
            children: [
              Icon(Icons.timer_sharp, size: 20, color: AppColors.primary),
              Text(
                '24 Dakika',
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
}
