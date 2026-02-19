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
    // make top left and right radius if its imsak, make bottom left and right radius if its yatsı
    final borderRadius = BorderRadius.only(
      topLeft: name == 'İmsak' ? Radius.circular(12) : Radius.zero,
      topRight: name == 'İmsak' ? Radius.circular(12) : Radius.zero,
      bottomLeft: name == 'Yatsı' ? Radius.circular(12) : Radius.zero,
      bottomRight: name == 'Yatsı' ? Radius.circular(12) : Radius.zero,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isHighlighted ? AppColors.primary.withValues(alpha: 0.5) : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
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
