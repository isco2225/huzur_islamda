import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }
}
