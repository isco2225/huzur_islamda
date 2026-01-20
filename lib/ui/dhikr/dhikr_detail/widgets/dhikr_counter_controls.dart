import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class DhikrCounterControls extends StatelessWidget {
  const DhikrCounterControls({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.incrementRunning,
    required this.decrementRunning,
    required this.dhikr,
  });

  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueListenable<bool> incrementRunning;
  final ValueListenable<bool> decrementRunning;
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          children: [
            Text(
              dhikr.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacingLarge),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrement Button
                ValueListenableBuilder(
                  valueListenable: decrementRunning,
                  builder: (context, isRunning, child) {
                    return _CounterButton(
                      icon: Icons.remove,
                      label: 'Azalt',
                      onPressed: canDecrement(dhikr) && !isRunning
                          ? onDecrement
                          : null,
                      isLoading: isRunning,
                      color: AppColors.error,
                    );
                  },
                ),

                // Current Count Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dhikr.currentCount.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // Increment Button
                ValueListenableBuilder(
                  valueListenable: incrementRunning,
                  builder: (context, isRunning, child) {
                    return _CounterButton(
                      icon: Icons.add,
                      label: 'Artır',
                      onPressed: canIncrement(dhikr) && !isRunning
                          ? onIncrement
                          : null,
                      isLoading: isRunning,
                      color: AppColors.success,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool canIncrement(Dhikr dhikr) {
    return !dhikr.isCompleted && !dhikr.isExpired;
  }

  bool canDecrement(Dhikr dhikr) {
    return dhikr.currentCount > 0 && !dhikr.isExpired && !dhikr.isCompleted;
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: onPressed == null ? 0 : 4,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(icon, size: 32),
          ),
        ),
        SizedBox(height: context.spacingSmall),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
