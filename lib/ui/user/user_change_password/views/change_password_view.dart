import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
import '../../../ui.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key, required this.viewModel});
  final ChangePasswordViewModel viewModel;

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final ValueNotifier<bool> _displayCurrentPasswordError = ValueNotifier(false);
  final ValueNotifier<bool> _displayNewPasswordError = ValueNotifier(false);
  final ValueNotifier<bool> _displayConfirmPasswordError = ValueNotifier(false);
  final FocusNode _currentPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _displayCurrentPasswordError.dispose();
    _displayNewPasswordError.dispose();
    _displayConfirmPasswordError.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final currentValid =
        Password.dirty(_currentPasswordController.text).isValid;
    final newValid = Password.dirty(_newPasswordController.text).isValid;
    final confirmValid = ConfirmPassword.dirty(
      password: _newPasswordController.text,
      value: _confirmNewPasswordController.text,
    ).isValid;

    _displayCurrentPasswordError.value = !currentValid;
    _displayNewPasswordError.value = !newValid;
    _displayConfirmPasswordError.value = !confirmValid;

    if (!currentValid || !newValid || !confirmValid) return;

    _confirmPasswordFocusNode.unfocus();
    widget.viewModel.changePassword.execute((
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: const Text('Şifreyi Değiştir')),
      safeArea: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TitleText(title: 'Şifre Güncelle'),
              const SubtitleText(
                text: 'Mevcut şifrenizi girip yeni şifrenizi belirleyin.',
              ),
              SizedBox(height: context.isSmallScreen ? 24 : 32),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _displayCurrentPasswordError,
                  _displayNewPasswordError,
                  _displayConfirmPasswordError,
                ]),
                builder: (context, child) {
                  return Column(
                    children: [
                      _PasswordField(
                        controller: _currentPasswordController,
                        label: 'Mevcut Şifre',
                        focusNode: _currentPasswordFocusNode,
                        displayError: _displayCurrentPasswordError,
                        onSubmitted: (_) =>
                            _newPasswordFocusNode.requestFocus(),
                        errorMessage: _displayCurrentPasswordError.value
                            ? context.voFailureToUserFriendlyMessage(
                                Password.dirty(_currentPasswordController.text)
                                    .error,
                              )
                            : null,
                      ),
                      SizedBox(height: context.isSmallScreen ? 16 : 20),
                      _PasswordField(
                        controller: _newPasswordController,
                        label: 'Yeni Şifre',
                        focusNode: _newPasswordFocusNode,
                        displayError: _displayNewPasswordError,
                        onSubmitted: (_) =>
                            _confirmPasswordFocusNode.requestFocus(),
                        errorMessage: _displayNewPasswordError.value
                            ? context.voFailureToUserFriendlyMessage(
                                Password.dirty(_newPasswordController.text)
                                    .error,
                              )
                            : null,
                      ),
                      SizedBox(height: context.isSmallScreen ? 16 : 20),
                      _PasswordField(
                        controller: _confirmNewPasswordController,
                        label: 'Yeni Şifre Tekrar',
                        focusNode: _confirmPasswordFocusNode,
                        displayError: _displayConfirmPasswordError,
                        onSubmitted: (_) => _submit(),
                        errorMessage: _displayConfirmPasswordError.value
                            ? context.voFailureToUserFriendlyMessage(
                                ConfirmPassword.dirty(
                                  password: _newPasswordController.text,
                                  value: _confirmNewPasswordController.text,
                                ).error,
                              )
                            : null,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: context.spacingLarge),
              SizedBox(
                width: double.infinity,
                height: context.isSmallScreen ? 48 : 52,
                child: AppButton(
                  onPressed: _submit,
                  text: 'Şifreyi Güncelle',
                  running: widget.viewModel.changePassword.running,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.focusNode,
    required this.displayError,
    this.onSubmitted,
    this.errorMessage,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode focusNode;
  final ValueNotifier<bool> displayError;
  final void Function(String)? onSubmitted;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(text: label),
        AppTextField(
          label,
          hideText: 'gizle',
          showText: 'göster',
          isPassword: true,
          focusNode: focusNode,
          textEditingController: controller,
          onSubmitted: onSubmitted,
          errorText: errorMessage,
        ),
      ],
    );
  }
}
