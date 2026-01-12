import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class DhikrCard extends StatelessWidget {
  const DhikrCard({super.key, required this.dhikr});

  final Dhikr dhikr;

  Color _getBorderColor() {
    if ((dhikr.isExpired && !dhikr.isCompleted)) {
      return AppColors.border;
    } else if (dhikr.isCompleted) {
      return AppColors.primary;
    } else {
      return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = (dhikr.currentCount / dhikr.targetCount).clamp(0.0, 1.0);
    final borderColor = _getBorderColor();
    return GestureDetector(
      onTap: () => context.pushToDhikrDetail(dhikr.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dhikr.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DhikrStatusDisplayer(dhikr: dhikr),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dhikr.currentCount} / ${dhikr.targetCount}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  dhikr.isCompleted
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.7),
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),

              const SizedBox(height: 8),
              Text(
                _formatDate(dhikr.day),
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Bugün';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Dün';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
