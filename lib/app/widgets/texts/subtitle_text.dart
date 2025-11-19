import 'package:flutter/material.dart';

import '../../../app/app.dart';

class SubtitleText extends StatelessWidget {
  const SubtitleText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      text,
      textAlign: TextAlign.center,
      style: textTheme.bodyLarge?.copyWith(
        color: AppColors.subtitleColor,
        fontWeight: FontWeight.w400,
        fontSize: context.responsiveFontSize(textTheme.bodyLarge?.fontSize),
      ),
    );
  }
}
