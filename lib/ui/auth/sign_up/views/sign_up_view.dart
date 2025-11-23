import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key, required this.viewModel});
  final SignUpViewModel viewModel;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // Text Field Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleText(title: 'Aramıza Katıl'),
              const SubtitleText(
                text: 'Bilgilerinizi girerek kaydınızı tamamlayın.',
              ),
              Padding(
                padding: EdgeInsets.only(top: context.isSmallScreen ? 40 : 60),
                child: EmailTextField(controller: _emailController),
              ),
              PasswordTextField(
                controller: _passwordController,
                showForgotPassword: false,
              ),
              PasswordTextField(
                controller: _confirmPasswordController,
                showForgotPassword: false,
              ),
              Padding(
                padding: EdgeInsets.only(top: context.spacingSmall),
                child: SizedBox(
                  width: double.infinity,
                  height: context.isSmallScreen ? 45 : 50,
                  child: AppButton(
                    onPressed: () {
                      widget.viewModel.requestSignUp.execute((
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      ));
                    },
                    text: 'Hesap Oluştur',
                    running: widget.viewModel.requestSignUp.running,
                  ),
                ),
              ),
              SizedBox(height: context.isSmallScreen ? 32 : 40),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: context.responsiveFontSize(14),
                    ),
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
                              fontSize: context.responsiveFontSize(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.isSmallScreen ? 12 : 16),
            ],
          ),
        ),
      ),
    );
  }
}
