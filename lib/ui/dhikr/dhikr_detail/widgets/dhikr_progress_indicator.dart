import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class DhikrProgressIndicator extends StatelessWidget {
  const DhikrProgressIndicator({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.progress,
  });

  final int currentCount;
  final int targetCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remainingCount = targetCount - currentCount;
    final isCompleted = currentCount >= targetCount;

    return Column(
      children: [
        // Circular Progress
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  if (!isCompleted) ...[
                    SizedBox(height: context.spacingSmall),
                    Text(
                      '$remainingCount kalan',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
