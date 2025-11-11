import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingText extends StatelessWidget {
  const OnboardingText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.secondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
