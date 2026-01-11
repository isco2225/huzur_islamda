import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key, required this.viewModel});
  final SignInViewModel viewModel;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _displayEmailError = ValueNotifier(false);
  final ValueNotifier<bool> _displayPasswordError = ValueNotifier(false);
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayEmailError.dispose();
    _displayPasswordError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(title: 'Hemen Giriş Yap'),
              SubtitleText(
                text: 'Bu eşsiz deneyim için heasp bilgilerini gir.',
              ),
              Padding(
                padding: EdgeInsets.only(top: responsive.spacingSmall),
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _displayEmailError,
                    _displayPasswordError,
                  ]),
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignInEmailTextField(
                          email: _emailController,
                          displayError: _displayEmailError,
                        ),
                        SignInPasswordTextField(
                          password: _passwordController,
                          displayError: _displayPasswordError,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: responsive.isSmallScreen ? 40 : 60,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: responsive.isSmallScreen ? 45 : 50,
                  child: SignInButton(
                    viewModel: widget.viewModel,
                    email: _emailController,
                    password: _passwordController,
                    displayEmailVOError: _displayEmailError,
                    displayPasswordVOError: _displayPasswordError,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsive.spacingSmall),
                child: OrDivider(),
              ),
              SocialLoginButton(
                text: 'Google ile Giriş Yap',
                icon: Icon(Icons.g_mobiledata),
                onPressed: () {
                  widget.viewModel.signInWithGoogle.execute();
                },
              ),
              SizedBox(height: responsive.isSmallScreen ? 8 : 12),
              SocialLoginButton(
                text: 'Apple ile Giriş Yap',
                icon: Icon(Icons.apple),
                onPressed: () {},
              ),
              // you dont have an account?
              Padding(
                padding: EdgeInsets.only(top: responsive.spacingSmall),
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
    final responsive = context.responsive;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabın yok mu?',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: responsive.responsiveFontSize(14),
          ),
        ),
        SizedBox(width: responsive.isSmallScreen ? 3 : 4),
        GestureDetector(
          onTap: () {
            const SignUpRoute().go(context);
          },
          child: Text(
            'Kayıt ol',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: responsive.responsiveFontSize(14),
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
    final responsive = context.responsive;
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.isSmallScreen ? 8 : 12,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: responsive.responsiveFontSize(14),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}
