import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class DhikrMeanBottomSheet extends StatefulWidget {
  const DhikrMeanBottomSheet({super.key, required this.dhikr});

  final Dhikr dhikr;

  @override
  State<DhikrMeanBottomSheet> createState() => _DhikrMeanBottomSheetState();
}

class _DhikrMeanBottomSheetState extends State<DhikrMeanBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: responsive.horizontalPadding,
        right: responsive.horizontalPadding,
        top: responsive.spacingMedium,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + responsive.spacingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: responsive.screenWidth * 0.1,
              height: 4,
              margin: EdgeInsets.only(bottom: responsive.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(responsive.spacingSmall),
              ),
            ),
          ),
          Center(
            child: Text(
              widget.dhikr.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: responsive.spacingMedium),
          Text(
            'Anlamı',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            widget.dhikr.meaning ?? '',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: responsive.spacingSmall),
          Divider(height: 1, color: Colors.grey.shade400),
          SizedBox(height: responsive.spacingSmall),
          Text(
            'Fazileti',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            widget.dhikr.benefit ?? '',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: responsive.spacingSmall),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: responsive.spacingSmall),
              child: AppButton(
                running: ValueNotifier(false),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: 'Tamam',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
