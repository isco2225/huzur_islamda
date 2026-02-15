import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app/app.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final dotSize = responsive.isSmallScreen ? 12.0 : 15.0;

    return SmoothPageIndicator(
      controller: controller,
      count: 4,
      effect: WormEffect(
        activeDotColor: Colors.black,
        dotWidth: dotSize,
        dotHeight: dotSize,
      ),
    );
  }
}
