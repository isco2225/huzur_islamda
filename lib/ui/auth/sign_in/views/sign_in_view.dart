import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
    return BaseScaffold(
      safeArea: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(title: 'Hemen Giriş Yap'),
            SubtitleText(text: 'Bu eşsiz deneyim için heasp bilgilerini gir.'),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: EmailTextField(),
            ),
            PasswordTextField(),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: AppButton(
                  onPressed: () {},
                  text: 'Giriş Yap',
                  running: loading,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(20.0), child: OrDivider()),
            SocialLoginButton(
              text: 'Google ile Giriş Yap',
              // TODO: Add Google icon.
              icon: Icon(Icons.abc),
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialLoginButton(
              text: 'Apple ile Giriş Yap',
              icon: Icon(Icons.apple),
              onPressed: () {},
            ),
            // you dont have an account?
            const DontHaveAnAccount(),
          ],
        ),
      ),
    );
  }
}

class DontHaveAnAccount extends StatelessWidget {
  const DontHaveAnAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Hesabın yok mu?', style: TextStyle(color: Colors.grey.shade800)),
        SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            const SignUpRoute().go(context);
          },
          child: Text(
            'Kayıt ol',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.text = 'veya'});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: TextStyle(color: Colors.grey.shade800)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}
