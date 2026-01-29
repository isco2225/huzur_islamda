import 'package:flutter/material.dart';

import '../../../app/app.dart';

class GroupDhikrsCard extends StatelessWidget {
  const GroupDhikrsCard({super.key});

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

    // Örnek grup zikir verileri (şimdilik UI tasarımı için)
    final groupDhikrs = [
      _GroupDhikrItem(
        name: 'Subhanallah',
        currentCount: 25,
        targetCount: 33,
        isCompleted: false,
      ),
      _GroupDhikrItem(
        name: 'Elhamdulillah',
        currentCount: 33,
        targetCount: 33,
        isCompleted: true,
      ),
      _GroupDhikrItem(
        name: 'Allahu Ekber',
        currentCount: 2,
        targetCount: 33,
        isCompleted: false,
      ),
    ];
    final totalDhikrs = groupDhikrs.length;
    final completedDhikrs = groupDhikrs
        .where((d) => d.isCompleted || d.currentCount >= d.targetCount)
        .length;
    final isGroupCompleted = completedDhikrs == totalDhikrs && totalDhikrs > 0;
    final borderColor = _getBorderColor(isGroupCompleted);
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
                  'Namaz Tesbihatı',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Durum gösterimi
              Text(
                isGroupCompleted ? 'Tamamlandı!' : 'Devam Et',
                style: textTheme.bodyMedium?.copyWith(
                  color: isGroupCompleted ? AppColors.primary : AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...groupDhikrs.map(
            (dhikr) =>
                _GroupDhikrItemWidget(dhikr: dhikr, textTheme: textTheme),
          ),
        ],
      ),
    );
  }
}

// Geçici veri modeli (UI tasarımı için)
class _GroupDhikrItem {
  final String name;
  final int currentCount;
  final int targetCount;
  final bool isCompleted;

  const _GroupDhikrItem({
    required this.name,
    required this.currentCount,
    required this.targetCount,
    required this.isCompleted,
  });
}

// Grup zikir öğesi widget'ı
class _GroupDhikrItemWidget extends StatelessWidget {
  const _GroupDhikrItemWidget({required this.dhikr, required this.textTheme});

  final _GroupDhikrItem dhikr;
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
