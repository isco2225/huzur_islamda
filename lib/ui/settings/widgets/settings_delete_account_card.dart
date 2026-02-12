import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../ui.dart';

class SettingsDeleteAccountCard extends StatelessWidget {
  const SettingsDeleteAccountCard({super.key, required this.userViewModel});

  final UserViewModel userViewModel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Dikkat!',
          content:
              'Hesabınızı silmek istediğinize emin misiniz? Verileriniz silinecektir ve bu işlem geri alınamaz.',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel),
            ),
            AppButton(
              onPressed: userViewModel.deleteAccount.execute,
              text: 'Sil',
              running: userViewModel.deleteAccount.running,
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      ),
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
                Icons.delete_outline_rounded,
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
                    'Hesabı Sil',
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
                    'Hesabınızı kalıcı olarak silin',
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
