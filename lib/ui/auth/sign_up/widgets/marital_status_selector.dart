import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class MaritalStatusSelector extends StatelessWidget {
  const MaritalStatusSelector({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
  });

  final String? selectedStatus;
  final ValueChanged<String>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Evlilik Durumu'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatusButton(
                text: 'Evli',
                isSelected: selectedStatus == 'Evli',
                onTap: () {
                  onStatusChanged?.call('Evli');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusButton(
                text: 'Bekar',
                isSelected: selectedStatus == 'Bekar',
                onTap: () {
                  onStatusChanged?.call('Bekar');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
