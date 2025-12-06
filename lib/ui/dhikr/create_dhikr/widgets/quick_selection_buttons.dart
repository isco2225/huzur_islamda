import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class QuickSelectionButtons extends StatelessWidget {
  const QuickSelectionButtons({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  static const List<int> _quickValues = [33, 99, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _quickValues.map((value) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: value != _quickValues.last ? context.spacingExtraSmall : 0,
            ),
            child: ElevatedButton(
              onPressed: () => onSelected(value),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: context.spacingSmall),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
