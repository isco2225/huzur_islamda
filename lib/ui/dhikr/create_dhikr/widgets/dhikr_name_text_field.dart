import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class DhikrNameTextField extends StatelessWidget {
  const DhikrNameTextField({super.key, this.controller});

  final TextEditingController? controller;

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
        ],
      ),
    );
  }
}
