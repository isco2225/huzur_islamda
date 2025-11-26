import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../ui.dart';

class CreateUserProfileView extends StatefulWidget {
  const CreateUserProfileView({super.key, required this.viewModel});
  final CreateUserProfileViewModel viewModel;

  @override
  State<CreateUserProfileView> createState() => _CreateUserProfileViewState();
}

class _CreateUserProfileViewState extends State<CreateUserProfileView> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String? _selectedMaritalStatus;

  @override
  void dispose() {
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

  void _handleCreateProfile() {
    widget.viewModel.createUserProfile.execute((
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
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleText(title: 'Aramıza Katıl'),
              const SubtitleText(
                text: 'Bilgilerinizi girerek kaydınızı tamamlayın.',
              ),
              NameTextField(controller: _nameController),
              SurnameTextField(controller: _surnameController),
              DateOfBirthTextField(
                controller: _dateOfBirthController,
                onTap: _selectDate,
              ),
              Padding(
                padding: EdgeInsets.only(top: context.isSmallScreen ? 6 : 8),
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
                padding: EdgeInsets.only(top: context.spacingSmall),
                child: SizedBox(
                  width: double.infinity,
                  height: context.isSmallScreen ? 45 : 50,
                  child: AppButton(
                    onPressed: _handleCreateProfile,
                    text: 'Hesap Oluştur',
                    running: widget.viewModel.createUserProfile.running,
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
                            //const SignInRoute().go(context);
                          },
                          child: Text(
                            'Profil oluştur',
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
