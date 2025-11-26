import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../ui.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key, required this.viewModel});
  final EditProfileViewModel viewModel;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _dateOfBirthController;
  late String _selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.viewModel.currentUserName.value,
    );
    _surnameController = TextEditingController(
      text: widget.viewModel.currentUserSurname.value,
    );
    _dateOfBirthController = TextEditingController(
      text: widget.viewModel.currentUserDateOfBirth.value,
    );
    _selectedMaritalStatus = widget.viewModel.currentUserMaritalStatus.value;
  }

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

  void _handleUpdateProfile() {
    widget.viewModel.updateProfile.execute((
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text,
      maritalStatus: _selectedMaritalStatus,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BaseScaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveFontSize(
              textTheme.titleLarge?.fontSize,
            ),
          ),
        ),
      ),
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
              const TitleText(title: 'Profil Bilgilerini Güncelle'),
              const SubtitleText(text: 'Bilgilerinizi düzenleyebilirsiniz.'),
              SizedBox(height: context.isSmallScreen ? 24 : 32),
              NameTextField(controller: _nameController),
              SizedBox(height: context.isSmallScreen ? 16 : 20),
              SurnameTextField(controller: _surnameController),
              SizedBox(height: context.isSmallScreen ? 16 : 20),
              DateOfBirthTextField(
                controller: _dateOfBirthController,
                onTap: _selectDate,
              ),
              SizedBox(height: context.isSmallScreen ? 16 : 20),
              MaritalStatusSelector(
                selectedStatus: _selectedMaritalStatus,
                onStatusChanged: (status) {
                  setState(() {
                    _selectedMaritalStatus = status;
                  });
                },
              ),
              SizedBox(height: context.spacingLarge),
              SizedBox(
                width: double.infinity,
                height: context.isSmallScreen ? 48 : 52,
                child: AppButton(
                  onPressed: _handleUpdateProfile,
                  text: 'Değişiklikleri Kaydet',
                  running: widget.viewModel.updateProfile.running,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
