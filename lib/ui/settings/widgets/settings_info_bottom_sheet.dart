import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class SettingsInfoBottomSheet extends StatelessWidget {
  const SettingsInfoBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

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
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: responsive.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Başlık
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
          SizedBox(height: responsive.spacingMedium),
          // İçerik (kaydırılabilir, uzun metinler için)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(child: child),
          ),
          SizedBox(height: responsive.spacingMedium),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              running: ValueNotifier(false),
              onPressed: () => Navigator.of(context).pop(),
              text: 'Kapat',
            ),
          ),
        ],
      ),
    );
  }
}
