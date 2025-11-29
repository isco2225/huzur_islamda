import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
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

  // Value Object Error Display Notifiers
  final ValueNotifier<bool> _displayNameError = ValueNotifier(false);
  final ValueNotifier<bool> _displaySurnameError = ValueNotifier(false);
  final ValueNotifier<bool> _displayDateOfBirthError = ValueNotifier(false);
  final ValueNotifier<bool> _displayMaritalStatusError = ValueNotifier(false);

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _dateOfBirthController.dispose();
    _displayNameError.dispose();
    _displaySurnameError.dispose();
    _displayDateOfBirthError.dispose();
    _displayMaritalStatusError.dispose();
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
    if (!_isValueObjectsValid()) return;
    widget.viewModel.createUserProfile.execute((
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text,
      maritalStatus: _selectedMaritalStatus ?? '',
    ));
  }

  bool _isValueObjectsValid() {
    final isNameValid = NameValueObject.dirty(
      _nameController.text.trim(),
    ).isValid;
    final isSurnameValid = SurnameValueObject.dirty(
      _surnameController.text.trim(),
    ).isValid;
    final isDateOfBirthValid = DateOfBirthValueObject.dirty(
      _dateOfBirthController.text,
    ).isValid;
    final isMaritalStatusValid = MaritalStatusValueObject.dirty(
      _selectedMaritalStatus ?? '',
    ).isValid;

    _displayNameError.value = !isNameValid;
    _displaySurnameError.value = !isSurnameValid;
    _displayDateOfBirthError.value = !isDateOfBirthValid;
    _displayMaritalStatusError.value = !isMaritalStatusValid;

    return isNameValid &&
        isSurnameValid &&
        isDateOfBirthValid &&
        isMaritalStatusValid;
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
                    _displayNameError,
                    _displaySurnameError,
                    _displayDateOfBirthError,
                    _displayMaritalStatusError,
                  ]),
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserProfileNameTextField(
                          name: _nameController,
                          displayError: _displayNameError,
                        ),
                        UserProfileSurnameTextField(
                          surname: _surnameController,
                          displayError: _displaySurnameError,
                        ),
                        DateOfBirthTextField(
                          controller: _dateOfBirthController,
                          displayError: _displayDateOfBirthError,
                          onTap: _selectDate,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: context.isSmallScreen ? 6 : 8,
                          ),
                          child: MaritalStatusSelector(
                            selectedStatus: _selectedMaritalStatus,
                            onStatusChanged: (status) {
                              setState(() {
                                _selectedMaritalStatus = status;
                              });
                            },
                            displayError: _displayMaritalStatusError,
                          ),
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
