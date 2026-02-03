import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

/// Badge widget to display content type (Hadis, Ayet, Dua)
class ContentTypeBadge extends StatelessWidget {
  const ContentTypeBadge({super.key, required this.type});

  final ContentType type;

  Color get _backgroundColor {
    switch (type) {
      case ContentType.hadis:
        return AppColors.hadisColor.withValues(alpha: 0.1);
      case ContentType.kuran:
        return AppColors.kuranColor.withValues(alpha: 0.1);
      case ContentType.dua:
        return AppColors.duaColor.withValues(alpha: 0.1);
    }
  }

  Color get _textColor {
    switch (type) {
      case ContentType.hadis:
        return AppColors.hadisColor;
      case ContentType.kuran:
        return AppColors.kuranColor;
      case ContentType.dua:
        return AppColors.duaColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isSmallScreen ? 8.0 : 12.0,
        vertical: responsive.isSmallScreen ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _textColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        type.name,
        style: TextStyle(
          fontSize: responsive.responsiveFontSize(
            responsive.isSmallScreen ? 10.0 : 12.0,
          ),
          fontWeight: FontWeight.w600,
          color: _textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
