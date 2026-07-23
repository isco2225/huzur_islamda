import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
import '../../../../ui.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key, required this.viewModel});
  final ResetPasswordViewModel viewModel;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final ValueNotifier<bool> _displayEmailError = ValueNotifier(false);
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _displayEmailError.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      safeArea: true,
      appBar: AppBar(title: const TitleText(title: 'Şifremi Unuttum')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(title: 'Şifreni yenilemek için;'),
              Padding(
                padding: EdgeInsets.only(top: responsive.spacingSmall),
                child: SubtitleText(
                  text:
                      'Daha önceden giriş yaptığınız E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: responsive.spacingSmall),
                child: ListenableBuilder(
                  listenable: _displayEmailError,
                  builder: (context, child) {
                    return SignInEmailTextField(
                      email: _emailController,
                      focusNode: _emailFocusNode,
                      displayError: _displayEmailError,
                      onEmailSubmitted: (_) => _onSubmit(),
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
                  child: AppButton(
                    onPressed: _onSubmit,
                    text: 'Sıfırlama Bağlantısı Gönder',
                    running: widget.viewModel.sendResetEmail.running,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final email = _emailController.text.trim();
    final isEmailValid = Email.dirty(email).isValid;
    _displayEmailError.value = !isEmailValid;
    if (!isEmailValid) return;
    _emailFocusNode.unfocus();
    widget.viewModel.sendResetEmail.execute(email);
  }
}
