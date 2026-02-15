import 'package:flutter/material.dart';
import '../../../app/app.dart';

class OnboardingViewFourth extends StatelessWidget {
  const OnboardingViewFourth({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(responsive.isSmallScreen ? 8.0 : 10.0),
            child: CustomLottieAnimation(assetPath: AppAnimations.fatherAndSon),
          ),
          TitleText(title: AppStrings.onboardingTitle4),
          SizedBox(height: responsive.spacingSmall),
          SubtitleText(text: AppStrings.onboardingText4),
        ],
      ),
    );
  }
}
