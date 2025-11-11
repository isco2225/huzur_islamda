import 'package:flutter/material.dart';

import '../../../app/app.dart';

class OnboardingViewSecound extends StatelessWidget {
  const OnboardingViewSecound({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomLottieAnimation(assetPath: AppAnimations.fatherAndSon),
        TitleText(title: 'Sizi Anlayan Bir Deneyim'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SubtitleText(
            text:
                'Namaz ve zikir takibini kolayca yapın. Ruh halinize göre size özel seçilmiş ayet ve hadislerle sizin için hazırlanmıştır.',
          ),
        ),
      ],
    );
  }
}
