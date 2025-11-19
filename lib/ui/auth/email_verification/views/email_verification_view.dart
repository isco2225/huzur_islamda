import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/auth/email_verification/view_models/view_models.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key, required this.viewModel});

  final EmailVerificationViewModel viewModel;

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          'Hesabı Sil',
          style: TextStyle(fontSize: context.responsiveFontSize(18)),
        ),
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz. Doğru email adresi ile tekrar kayıt olabilirsiniz.',
          style: TextStyle(fontSize: context.responsiveFontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              viewModel.deleteAccount.execute();
            },
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
        contentPadding: context.dialogContentPadding,
        titlePadding: context.dialogTitlePadding,
        actionsPadding: context.dialogActionsPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: context.verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.maxContentWidth,
              minHeight: context.screenHeight * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'E-mailini Doğrula',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: context.responsiveFontSize(
                      textTheme.headlineSmall?.fontSize,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingMedium),
                const EmailIcon(),
                SizedBox(height: context.spacingMedium),
                Text(
                  'E-mailini Kontrol Et',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: context.responsiveFontSize(
                      textTheme.titleLarge?.fontSize,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.isSmallScreen ? 6 : 8),
                Text(
                  'Uygulamaya giriş yapmak için email hesabını doğrula. Aşağıdaki adımları takip et:',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontSize: context.responsiveFontSize(
                      textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingSmall),
                UserEmailDisplayer(
                  email: viewModel.currentUserEmail.value ?? '',
                ),
                SizedBox(height: context.isSmallScreen ? 12 : 16),
                Container(
                  padding: context.containerPadding,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      VerificationStepsDisplayer(
                        stepNumber: 1,
                        text:
                            'Gelen kutunu veya "İstenmeyen / Spam" klasörünü kontrol et.',
                      ),
                      VerificationStepsDisplayer(
                        stepNumber: 2,
                        text: '"E-mailini doğrula" başlıklı mesajı aç.',
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: context.isSmallScreen ? 4 : 5,
                        ),
                        child: VerificationStepsDisplayer(
                          stepNumber: 3,
                          text:
                              'İçindeki bağlantıya dokunarak kaydını tamamla.',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacingMedium),
                AppButton(
                  onPressed: viewModel.sendEmailVerification.execute,
                  text: 'Doğrulama E-postasını Tekrar Gönder',
                  running: viewModel.sendEmailVerification.running,
                ),
                SizedBox(height: context.isSmallScreen ? 8 : 12),

                // TextButton(
                //   onPressed: onSkipPressed,
                //   child: const Text('Şimdilik atla'),
                // ),
                SizedBox(height: context.isSmallScreen ? 6 : 8),
                Center(
                  child: GestureDetector(
                    onTap: () => _showDeleteAccountConfirmation(context),
                    child: Column(
                      children: [
                        Text('Yanlış email mi?'),
                        Text(
                          'Hesabı sil ve tekrar kayıt ol',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
