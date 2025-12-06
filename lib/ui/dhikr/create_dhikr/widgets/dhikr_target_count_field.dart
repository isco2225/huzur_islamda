import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class DhikrTargetCountField extends StatelessWidget {
  const DhikrTargetCountField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredLabel(label: 'Hedef sayı'),
        SizedBox(height: context.spacingExtraSmall),
        TargetCountCounter(value: value, onChanged: onChanged),
        SizedBox(height: context.spacingSmall),
        QuickSelectionButtons(onSelected: onChanged),
      ],
    );
  }
}
