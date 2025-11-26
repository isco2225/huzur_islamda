import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/app.dart';

class SettingsLogOutCard extends StatelessWidget {
  const SettingsLogOutCard({super.key, required this.onTap});

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
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: context.isSmallScreen ? 20 : 22,
              ),
            ),
            SizedBox(width: context.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Çıkış Yap',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                      fontSize: context.responsiveFontSize(
                        textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Hesabınızdan güvenle ayrılın',
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
          ],
        ),
      ),
    );
  }
}
