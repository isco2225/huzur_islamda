import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/app.dart';

class NavigatableSettingTile extends StatelessWidget {
  const NavigatableSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.isSmallScreen ? 10 : 12,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: context.isSmallScreen ? 20 : 22),
            ),
            SizedBox(width: context.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: context.responsiveFontSize(
                        textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: context.responsiveFontSize(
                        textTheme.bodyMedium?.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
