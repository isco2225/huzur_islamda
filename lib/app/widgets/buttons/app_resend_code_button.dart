import 'dart:async';

import 'package:flutter/material.dart';

import 'app_gradient_button.dart';

class AppResendCodeButton extends StatefulWidget {
  const AppResendCodeButton({
    super.key,
    required this.lastResendDate,
    required this.onPressed,
    required this.text,
    required this.isLoading,
    this.resendCooldown = 60,
  });

  final DateTime? lastResendDate;
  final int resendCooldown;
  final void Function() onPressed;
  final String text;
  final bool isLoading;

  @override
  State<AppResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<AppResendCodeButton>
    with SingleTickerProviderStateMixin {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Durations.long2,
      (timer) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastResendDate = widget.lastResendDate;

    final resendableDuration = lastResendDate != null
        ? DateTime.now().difference(lastResendDate)
        : null;

    final hasResendableDuration = resendableDuration != null;

    final isResendableDurationDisplayable =
        hasResendableDuration && resendableDuration.inSeconds < 60;
    final resendableDurationLeftString =
        (60 - (resendableDuration?.inSeconds ?? 0)).toString();

    return AppGradientButton(
      text: isResendableDurationDisplayable
          ? resendableDurationLeftString
          : widget.text,
      isLoading: widget.isLoading,
      isBordered: true,
      onPressed: widget.onPressed,
    );
  }
}
