import 'package:flutter/material.dart';

import '../../../app/app.dart';

class SettingsDisplayerCard extends StatelessWidget {
  const SettingsDisplayerCard({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(context.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveFontSize(
                textTheme.titleMedium?.fontSize,
              ),
            ),
          ),
          if (description != null) ...[
            SizedBox(height: context.spacingExtraSmall),
            Text(
              description!,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.6),
                fontSize: context.responsiveFontSize(
                  textTheme.bodyMedium?.fontSize,
                ),
              ),
            ),
            SizedBox(height: context.spacingSmall),
          ] else
            SizedBox(height: context.spacingExtraSmall),
          ...children,
        ],
      ),
    );
  }
}
