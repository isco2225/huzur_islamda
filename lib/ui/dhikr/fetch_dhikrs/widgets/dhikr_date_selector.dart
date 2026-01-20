import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class DhikrDateSelector extends StatelessWidget {
  const DhikrDateSelector({super.key, required this.viewModel});

  final FetchDhikrsViewModel viewModel;

  static const List<String> _monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (_isSameDay(dateOnly, today)) {
      return 'Bugün';
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_isSameDay(dateOnly, yesterday)) {
        return 'Dün';
      } else {
        return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ValueListenableBuilder<DateTime>(
      valueListenable: viewModel.selectedDate,
      builder: (context, selectedDate, _) {
        final canGoNext = viewModel.canGoToNextDay;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => viewModel.goToPreviousDay(),
                icon: const Icon(Icons.chevron_left),
                color: AppColors.primary,
                iconSize: 28,
              ),
              GestureDetector(
                onTap: () => viewModel.goToToday(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(selectedDate),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: canGoNext ? () => viewModel.goToNextDay() : null,
                icon: const Icon(Icons.chevron_right),
                color: canGoNext ? AppColors.primary : Colors.grey,
                iconSize: 28,
              ),
            ],
          ),
        );
      },
    );
  }
}
