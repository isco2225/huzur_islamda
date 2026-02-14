import 'package:flutter/material.dart';

import '../app.dart';

class AppSplashView extends StatefulWidget {
  const AppSplashView({super.key});

  @override
  State<AppSplashView> createState() => _AppSplashViewState();
}

class _AppSplashViewState extends State<AppSplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heartbeatScale;

  static const String _logoAsset = 'assets/icons/app_icon.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    // Kalp atışı: iki vuruş (lub-dub) — 1 → büyü → 1 → hafif büyü → 1
    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 48,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final logoSize = responsive.spacingExtraLarge * 3.5;
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _heartbeatScale.value, child: child);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            _logoAsset,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.image_not_supported, size: logoSize),
          ),
        ),
      ),
    );
  }
}
