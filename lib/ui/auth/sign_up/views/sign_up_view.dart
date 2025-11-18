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
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String? _selectedMaritalStatus;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleSignUp() {
    widget.viewModel.requestSignUp.execute((
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text,
      maritalStatus: _selectedMaritalStatus ?? '',
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                child: EmailTextField(controller: _emailController),
              ),
              PasswordTextField(
                controller: _passwordController,
                showForgotPassword: false,
              ),
              NameTextField(controller: _nameController),
              SurnameTextField(controller: _surnameController),
              DateOfBirthTextField(
                controller: _dateOfBirthController,
                onTap: _selectDate,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MaritalStatusSelector(
                  selectedStatus: _selectedMaritalStatus,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedMaritalStatus = status;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButton(
                    onPressed: _handleSignUp,
                    text: 'Hesap Oluştur',
                    running: widget.viewModel.requestSignUp.running,
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
