import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool repeat;
  final bool animate;

  const CustomLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.repeat = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      repeat: repeat,
      animate: animate,
      errorBuilder: (context, error, stackTrace) {
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          return Center(child: Text('Lottie Hatası: $error'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
