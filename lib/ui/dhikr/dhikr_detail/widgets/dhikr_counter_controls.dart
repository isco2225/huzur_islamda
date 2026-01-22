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
      color: AppColors.background,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrement Button
                ValueListenableBuilder(
                  valueListenable: decrementRunning,
                  builder: (context, isRunning, child) {
                    return _CounterButton(
                      icon: Icons.remove,
                      onPressed: canDecrement(dhikr) && !isRunning
                          ? onDecrement
                          : null,
                      color: AppColors.error,
                      size: 60,
                    );
                  },
                ),

                // Increment Button
                _CounterButton(
                  size: 100,
                  icon: Icons.add,
                  onPressed: canIncrement(dhikr) ? onIncrement : null,
                  color: AppColors.success,
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
    required this.onPressed,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: onPressed == null ? 0 : 4,
            ),
            child: Icon(icon, size: size / 2),
          ),
        ),
      ],
    );
  }
}
