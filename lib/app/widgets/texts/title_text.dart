import 'package:flutter/material.dart';

import '../../../app/app.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
        fontSize: context.responsiveFontSize(textTheme.titleLarge?.fontSize),
      ),
    );
  }
}
