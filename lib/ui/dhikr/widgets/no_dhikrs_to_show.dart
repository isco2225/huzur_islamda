import 'package:flutter/material.dart';

import '../../../app/app.dart';

class NoDhikrsToShow extends StatelessWidget {
  const NoDhikrsToShow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with background
          Container(
            width: context.screenWidth * 0.25,
            height: context.screenWidth * 0.25,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: context.screenWidth * 0.15,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: responsive.spacingMedium),
          // Title
          Text(
            'Henüz zikir yok',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.subtitleColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacingExtraSmall),
          Text(
            '\'Kalpler Allah\'ı anmakla huzur bulur\'',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtitleColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacingMedium),
          // Description
          Text(
            'Günün ilk zikrini oluşturarak başlayabilirsin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacingSmall),
          // Action button
          AppButton(
            onPressed: () async {
              final dhikrId = await context.pushCreateDhikr<String>();
              if (dhikrId != null && context.mounted) {
                await context.pushToDhikrDetail(dhikrId);
              }
            },
            text: 'Hemen bir zikir oluştur',
            running: ValueNotifier(false),
          ),
        ],
      ),
    );
  }
}
