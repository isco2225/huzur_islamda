import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';

/// Outlined social sign-in button (Google / Apple).
///
/// While [running] is true the icon and label are replaced by a spinner and
/// taps are ignored. While [blocked] is true (e.g. another sign-in method is
/// in flight) the button is dimmed and taps are ignored as well.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.running,
    this.blocked,
  });

  final String text;
  final Widget icon;
  final VoidCallback onPressed;

  /// Listenable that reports whether this button's action is in progress.
  final ValueListenable<bool>? running;

  /// Listenable that reports whether the button must stay disabled because
  /// something else (e.g. a sibling sign-in action) is in progress.
  final ValueListenable<bool>? blocked;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([running, blocked]),
      builder: (context, _) {
        final isRunning = running?.value ?? false;
        final isEnabled = !isRunning && !(blocked?.value ?? false);
        return Opacity(
          opacity: isEnabled || isRunning ? 1 : 0.5,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isRunning
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 24, height: 24, child: icon),
                          const SizedBox(width: 12),
                          Text(
                            text,
                            textScaler: MediaQuery.textScalerOf(context),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
