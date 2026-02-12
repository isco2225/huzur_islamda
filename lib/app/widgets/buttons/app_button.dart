import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.running,
    this.backgroundColor,
  });
  final VoidCallback onPressed;
  final String text;
  final ValueListenable<bool> running;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: running,
      builder: (BuildContext context, bool running, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            side: BorderSide(style: BorderStyle.solid, width: 0.6),
          ),
          onPressed: running ? null : onPressed,
          child: running
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }
}
