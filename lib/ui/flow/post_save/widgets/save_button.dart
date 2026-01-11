import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.isSaved});
  final bool isSaved;
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: AppColors.primary,
          size: responsive.isSmallScreen ? 20.0 : 24.0,
        ),
        onPressed: () {},
        tooltip: 'Kaydet',
      ),
    );
  }
}
