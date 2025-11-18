import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/auth/email_verification/view_models/view_models.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key, required this.viewModel});

  final EmailVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'E-mailini Doğrula',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const EmailIcon(),
                const SizedBox(height: 24),
                Text(
                  'E-mailini Kontrol Et',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulamaya giriş yapmak için email hesabını doğrula. Aşağıdaki adımları takip et:',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                UserEmailDisplayer(
                  email: viewModel.currentUserEmail.value ?? '',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                            'Gelen kutunu veya “İstenmeyen / Spam” klasörünü kontrol et.',
                      ),
                      VerificationStepsDisplayer(
                        stepNumber: 2,
                        text: '“E-mailini doğrula” başlıklı mesajı aç.',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: VerificationStepsDisplayer(
                          stepNumber: 3,
                          text:
                              'İçindeki bağlantıya dokunarak kaydını tamamla.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: viewModel.sendEmailVerification.execute,
                  text: 'Doğrulama E-postasını Tekrar Gönder',
                  running: viewModel.sendEmailVerification.running,
                ),
                const SizedBox(height: 12),
                // TextButton(
                //   onPressed: onSkipPressed,
                //   child: const Text('Şimdilik atla'),
                // ),
                const SizedBox(height: 24),
                Text(
                  'Eğer yanlış email hesabı ile kayıt olduysan lütfen tekrar kayıt ol.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
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
