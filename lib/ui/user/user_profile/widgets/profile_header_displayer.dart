import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class ProfileHeaderDisplayer extends StatelessWidget {
  const ProfileHeaderDisplayer({
    super.key,
    required this.user,
    required this.textTheme,
  });
  final User user;
  final TextTheme textTheme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Premium Badge
          if (user.isPremium) ...[
            Align(
              alignment: Alignment.topRight,
              child: PremiumBadge(textTheme: textTheme),
            ),
          ],
          // Avatar Circle
          UserProfileAvatar(user: user),
          SizedBox(height: context.spacingSmall),
          // Name
          Text(
            '${user.name} ${user.surname}',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subtitleColor,
              fontSize: context.responsiveFontSize(
                textTheme.headlineSmall?.fontSize,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
