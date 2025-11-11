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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomLottieAnimation(assetPath: AppAnimations.handDrawnSalam),
        ),
        TitleText(title: AppStrings.onboardingTitle1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SubtitleText(text: AppStrings.onboardingText1),
        ),
      ],
    );
  }
}
