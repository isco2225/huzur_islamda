import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
    return BaseScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleText(title: 'Aramıza Katıl'),
              const SubtitleText(
                text: 'Bilgilerinizi girerek kaydınızı tamamlayın.',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmailTextField(),
              ),
              PasswordTextField(),
              const NameTextField(),
              const SurnameTextField(),
              const DateOfBirthTextField(),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: MaritalStatusSelector(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButton(
                    onPressed: () {},
                    text: 'Hesap Oluştur',
                    running: loading,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade800),
                    children: [
                      const TextSpan(text: 'Zaten hesabın var mı? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            const SignInRoute().go(context);
                          },
                          child: Text(
                            'Giriş Yap',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
