import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
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
  final ValueNotifier<bool> _displayEmailError = ValueNotifier(false);
  final ValueNotifier<bool> _displayPasswordError = ValueNotifier(false);
  final ValueNotifier<bool> _displayConfirmPasswordError = ValueNotifier(false);
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayEmailError.dispose();
    _displayPasswordError.dispose();
    _displayConfirmPasswordError.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _displayEmailError,
                    _displayPasswordError,
                    _displayConfirmPasswordError,
                  ]),
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignUpEmailTextField(
                          email: _emailController,
                          displayError: _displayEmailError,
                          focusNode: _emailFocusNode,
                          onEmailSubmitted: (email) {
                            _emailFocusNode.unfocus();
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                        SignUpPasswordTextField(
                          password: _passwordController,
                          displayError: _displayPasswordError,
                          focusNode: _passwordFocusNode,
                          onPasswordSubmitted: (password) {
                            _passwordFocusNode.unfocus();
                            _confirmPasswordFocusNode.requestFocus();
                          },
                        ),
                        ConfirmPasswordTextField(
                          password: _passwordController,
                          confirmPassword: _confirmPasswordController,
                          displayError: _displayConfirmPasswordError,
                          focusNode: _confirmPasswordFocusNode,
                          onConfirmPasswordSubmitted: (confirmPassword) {
                            _confirmPasswordFocusNode.unfocus();
                            if (!_isValueObjectsValid()) return;
                            widget.viewModel.requestSignUp.execute((
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: context.spacingSmall),
                child: SizedBox(
                  width: double.infinity,
                  height: context.isSmallScreen ? 45 : 50,
                  child: AppButton(
                    onPressed: () {
                      if (!_isValueObjectsValid()) return;
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
                            context.goToSignIn();
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

  bool _isValueObjectsValid() {
    final isEmailValid = Email.dirty(_emailController.text.trim()).isValid;
    final isPasswordValid = Password.dirty(_passwordController.text).isValid;
    final isConfirmPasswordValid = ConfirmPassword.dirty(
      password: _passwordController.text,
      value: _confirmPasswordController.text,
    ).isValid;

    _displayEmailError.value = !isEmailValid;
    _displayPasswordError.value = !isPasswordValid;
    _displayConfirmPasswordError.value = !isConfirmPasswordValid;

    return isEmailValid && isPasswordValid && isConfirmPasswordValid;
  }
}
