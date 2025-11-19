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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(title: 'Hemen Giriş Yap'),
              SubtitleText(
                text: 'Bu eşsiz deneyim için heasp bilgilerini gir.',
              ),
              Padding(
                padding: EdgeInsets.only(top: context.isSmallScreen ? 40 : 60),
                child: EmailTextField(),
              ),
              PasswordTextField(),
              Padding(
                padding: EdgeInsets.only(top: context.spacingSmall),
                child: SizedBox(
                  width: double.infinity,
                  height: context.isSmallScreen ? 45 : 50,
                  child: AppButton(
                    onPressed: () {
                      const EmailVerificationRoute().go(context);
                    },
                    text: 'Giriş Yap',
                    running: loading,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.spacingSmall),
                child: OrDivider(),
              ),
              SocialLoginButton(
                text: 'Google ile Giriş Yap',
                // TODO: Add Google icon.
                icon: Icon(Icons.abc),
                onPressed: () {},
              ),
              SizedBox(height: context.isSmallScreen ? 8 : 12),
              SocialLoginButton(
                text: 'Apple ile Giriş Yap',
                icon: Icon(Icons.apple),
                onPressed: () {},
              ),
              // you dont have an account?
              Padding(
                padding: EdgeInsets.only(top: context.spacingSmall),
                child: const DontHaveAnAccount(),
              ),
            ],
          ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabın yok mu?',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: context.responsiveFontSize(14),
          ),
        ),
        SizedBox(width: context.isSmallScreen ? 3 : 4),
        GestureDetector(
          onTap: () {
            const SignUpRoute().go(context);
          },
          child: Text(
            'Kayıt ol',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveFontSize(14),
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
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 8 : 12,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: context.responsiveFontSize(14),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}
