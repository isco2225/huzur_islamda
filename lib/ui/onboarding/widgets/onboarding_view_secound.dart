import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingViewSecound extends StatelessWidget {
  const OnboardingViewSecound({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(responsive.isSmallScreen ? 8.0 : 10.0),
          child: CustomLottieAnimation(assetPath: AppAnimations.fatherAndSon),
        ),
        TitleText(title: 'Sizi Anlayan Bir Deneyim'),
        Padding(
          padding: EdgeInsets.all(responsive.spacingSmall),
          child: SubtitleText(text: AppStrings.onboardingText2),
        ),
      ],
    );
  }
}
