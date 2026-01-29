import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../fetch_dhikrs/view_models/fetch_dhikrs_view_model.dart';

class GroupDhikrsCard extends StatelessWidget {
  const GroupDhikrsCard({super.key, required this.viewModel});

  final FetchDhikrsViewModel viewModel;

  Color _getBorderColor(bool isGroupCompleted) {
    if (isGroupCompleted) {
      return AppColors.primary;
    } else {
      return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<List<GroupDhikrData>?>(
      valueListenable: viewModel.groupDhikrs,
      builder: (context, groupDhikrs, _) {
        if (groupDhikrs == null || groupDhikrs.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: groupDhikrs.map((group) {
            final borderColor = _getBorderColor(group.isCompleted);
            final totalDhikrs = group.totalCount;
            final completedDhikrs = group.completedCount;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve durum
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group.groupName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Durum gösterimi
                      Text(
                        group.isCompleted ? 'Tamamlandı!' : 'Devam Et',
                        style: textTheme.bodyMedium?.copyWith(
                          color: group.isCompleted
                              ? AppColors.primary
                              : AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Grup toplam ilerleme
                  Text(
                    '$completedDhikrs / $totalDhikrs tamamlandı',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Grup içindeki zikirler
                  ...group.dhikrs.map(
                    (dhikr) => _GroupDhikrItemWidget(
                      dhikr: dhikr,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Grup zikir öğesi widget'ı
class _GroupDhikrItemWidget extends StatelessWidget {
  const _GroupDhikrItemWidget({required this.dhikr, required this.textTheme});

  final Dhikr dhikr;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        dhikr.isCompleted || dhikr.currentCount >= dhikr.targetCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                !isCompleted
                    ? Container(
                        padding: EdgeInsets.all(context.spacingExtraSmall / 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          (dhikr.targetCount - dhikr.currentCount).toString(),
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppColors.success,
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dhikr.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? AppColors.success : Colors.black87,
                      decoration: isCompleted
                          ? TextDecoration.none
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
