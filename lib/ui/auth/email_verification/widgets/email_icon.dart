import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class EmailIcon extends StatelessWidget {
  const EmailIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.email_outlined, color: AppColors.primary, size: 36),
      ),
    );
  }
}
