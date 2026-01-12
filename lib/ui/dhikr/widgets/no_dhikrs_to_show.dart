import 'package:flutter/material.dart';

import '../../../app/app.dart';

class NoDhikrsToShow extends StatelessWidget {
  const NoDhikrsToShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz zikir yok.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => context.pushCreateDhikr(),
          child: const Text(
            'Hemen bir zikir oluştur',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
