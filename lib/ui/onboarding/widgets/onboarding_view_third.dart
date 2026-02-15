import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingViewThird extends StatelessWidget {
  const OnboardingViewThird({super.key});
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          color: AppColors.primary,
          size: responsive.spacingExtraLarge * 4,
        ),
        TitleText(title: AppStrings.onboardingTitle3),
        Padding(
          padding: EdgeInsets.all(responsive.spacingSmall),
          child: SubtitleText(text: AppStrings.onboardingText3),
        ),
      ],
    );
  }
}
