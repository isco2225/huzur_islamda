import 'package:flutter/material.dart';

import '../../../app/app.dart';

class NoDhikrsToShow extends StatelessWidget {
  const NoDhikrsToShow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            'Henüz zikir yok',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.subtitleColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            'Günün ilk zikrini oluşturarak başlayabilirsin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Action button
          AppButton(
            onPressed: () => context.pushCreateDhikr(),
            text: 'Hemen bir zikir oluştur',
            running: ValueNotifier(false),
          ),
        ],
      ),
    );
  }
}
