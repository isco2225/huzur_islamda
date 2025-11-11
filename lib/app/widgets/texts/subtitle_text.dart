import 'package:flutter/material.dart';

import '../../../app/app.dart';

class SubtitleText extends StatelessWidget {
  const SubtitleText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.subtitleColor,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
