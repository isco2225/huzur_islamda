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
  late String _selectedGender;
  final ValueNotifier<bool> _displayGenderError = ValueNotifier(false);
  final ValueNotifier<bool> _displayNameError = ValueNotifier(false);
  final ValueNotifier<bool> _displaySurnameError = ValueNotifier(false);
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
    _selectedGender = widget.viewModel.currentUserGender.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _dateOfBirthController.dispose();
    _displayGenderError.dispose();
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
              ListenableBuilder(
                listenable: Listenable.merge([
                  _displayNameError,
                  _displaySurnameError,
                  _displayGenderError,
                ]),
                builder: (context, child) {
                  return Column(
                    children: [
                      UserProfileNameTextField(
                        name: _nameController,
                        displayError: _displayNameError,
                      ),
                      SizedBox(height: context.isSmallScreen ? 16 : 20),
                      UserProfileSurnameTextField(
                        surname: _surnameController,
                        displayError: _displaySurnameError,
                      ),
                      SizedBox(height: context.isSmallScreen ? 16 : 20),
                      DateOfBirthTextField(
                        controller: _dateOfBirthController,
                        onTap: _selectDate,
                      ),
                      SizedBox(height: context.isSmallScreen ? 16 : 20),
                      GenderSelector(
                        selectedGender: _selectedGender,
                        onGenderChanged: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        displayError: _displayGenderError,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: context.spacingLarge),
              SizedBox(
                width: double.infinity,
                height: context.isSmallScreen ? 48 : 52,
                child: SaveEditedProfileChangesButton(
                  viewModel: widget.viewModel,
                  running: widget.viewModel.updateProfile.running,
                  displayNameError: _displayNameError,
                  displaySurnameError: _displaySurnameError,
                  displayGenderError: _displayGenderError,
                  nameController: _nameController,
                  surnameController: _surnameController,
                  dateOfBirthController: _dateOfBirthController,
                  selectedGender: _selectedGender,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
