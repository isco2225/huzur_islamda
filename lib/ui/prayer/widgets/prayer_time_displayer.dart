import 'package:flutter/material.dart';

import '../../../app/app.dart';

class PrayerTimeDisplayer extends StatelessWidget {
  const PrayerTimeDisplayer({
    super.key,
    required this.name,
    required this.time,
    required this.isHighlighted,
  });
  final String name;
  final String time;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isHighlighted ? AppColors.primary.withValues(alpha: 0.5) : null,
      padding: context.containerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
