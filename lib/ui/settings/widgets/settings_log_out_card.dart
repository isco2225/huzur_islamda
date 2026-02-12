import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/app.dart';

import '../../ui.dart';

class SettingsLogOutCard extends StatelessWidget {
  const SettingsLogOutCard({super.key, required this.logOutViewModel});

  final LogOutViewModel logOutViewModel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: 'Çıkış Yap',
            content: 'Hesabınızdan güvenle ayrılın',
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              AppButton(
                onPressed: logOutViewModel.logOut.execute,
                text: 'Çıkış Yap',
                running: logOutViewModel.logOut.running,
                backgroundColor: AppColors.error,
              ),
            ],
          ),
        );
      },
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
