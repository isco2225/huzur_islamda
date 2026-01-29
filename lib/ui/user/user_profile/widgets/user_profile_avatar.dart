import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({required this.user, super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    final bool isMale = user.gender == 'Erkek';
    return Container(
      width: context.isSmallScreen ? 60 : 80,
      height: context.isSmallScreen ? 60 : 80,
      decoration: BoxDecoration(
        color: isMale
            ? AppColors.maleColor.withAlpha(100)
            : AppColors.femaleColor.withAlpha(100),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: Center(
        child: Icon(isMale ? Icons.person_2_outlined : Icons.person_outline),
      ),
    );
  }
}
