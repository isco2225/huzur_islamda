import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingViewFirst extends StatefulWidget {
  const OnboardingViewFirst({super.key});

  @override
  State<OnboardingViewFirst> createState() => _OnboardingViewFirstState();
}

class _OnboardingViewFirstState extends State<OnboardingViewFirst> {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.appName,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: context.responsiveFontSize(25) ?? 25,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(responsive.isSmallScreen ? 8.0 : 10.0),
          child: CustomLottieAnimation(assetPath: AppAnimations.handDrawnSalam),
        ),
        TitleText(title: AppStrings.onboardingTitle1),
        Padding(
          padding: EdgeInsets.all(responsive.spacingSmall),
          child: SubtitleText(text: AppStrings.onboardingText1),
        ),
      ],
    );
  }
}
