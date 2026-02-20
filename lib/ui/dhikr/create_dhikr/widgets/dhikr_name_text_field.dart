import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class DhikrNameTextField extends StatelessWidget {
  const DhikrNameTextField({
    super.key,
    this.controller,
    this.onSuggestDhikr,
  });

  final TextEditingController? controller;
  final VoidCallback? onSuggestDhikr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequiredLabel(label: 'Zikir adı'),
          SizedBox(height: context.spacingExtraSmall),
          TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              hintText: 'Örn. Subhanallah',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              suffixIcon: Icon(Icons.text_fields, color: Colors.grey.shade600),
            ),
          ),
          if (onSuggestDhikr != null) ...[
            SizedBox(height: context.spacingSmall),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onSuggestDhikr,
                icon: Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Zikir Öner',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacingSmall,
                    vertical: context.spacingExtraSmall,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
