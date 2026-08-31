import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/app.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  late FakeUserRepository userRepository;
  late EditProfileViewModel viewModel;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController dateOfBirthController;
  late ValueNotifier<bool> displayNameError;
  late ValueNotifier<bool> displaySurnameError;
  late ValueNotifier<bool> displayDateOfBirthError;
  late ValueNotifier<bool> displayGenderError;

  setUp(() {
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    final prayerRepository = FakePrayerRepository();
    final notificationRepository = FakeNotificationRepository();
    viewModel = EditProfileViewModel(
      userRepository: userRepository,
      authRepository: FakeAuthRepository(auth: Fixtures.auth()),
      appRepository: FakeAppRepository(preferences: Fixtures.appPreferences()),
      schedulePrayerNotificationsUseCase: SchedulePrayerNotificationsUseCase(
        prayerRepository: prayerRepository,
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
    );
    nameController = TextEditingController(text: 'Ahmet');
    surnameController = TextEditingController(text: 'Yılmaz');
    dateOfBirthController = TextEditingController(text: '01/01/1990');
    displayNameError = ValueNotifier(false);
    displaySurnameError = ValueNotifier(false);
    displayDateOfBirthError = ValueNotifier(false);
    displayGenderError = ValueNotifier(false);
  });

  tearDown(() {
    viewModel.dispose();
    nameController.dispose();
    surnameController.dispose();
    dateOfBirthController.dispose();
    displayNameError.dispose();
    displaySurnameError.dispose();
    displayDateOfBirthError.dispose();
    displayGenderError.dispose();
  });

  Widget buildButton() {
    return MaterialApp(
      home: Scaffold(
        body: SaveEditedProfileChangesButton(
          viewModel: viewModel,
          running: viewModel.updateProfile.running,
          displayNameError: displayNameError,
          displaySurnameError: displaySurnameError,
          displayDateOfBirthError: displayDateOfBirthError,
          displayGenderError: displayGenderError,
          nameController: nameController,
          surnameController: surnameController,
          dateOfBirthController: dateOfBirthController,
          selectedGender: 'male',
        ),
      ),
    );
  }

  testWidgets('flags an invalid date of birth and does not save', (
    tester,
  ) async {
    dateOfBirthController.text = '31/02/2000';
    await tester.pumpWidget(buildButton());

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(displayDateOfBirthError.value, isTrue);
    expect(displayNameError.value, isFalse);
    expect(displaySurnameError.value, isFalse);
    expect(displayGenderError.value, isFalse);
    expect(userRepository.calls, isEmpty);
  });

  testWidgets('clears the date of birth flag once the value is valid', (
    tester,
  ) async {
    displayDateOfBirthError.value = true;
    nameController.text = 'Mehmet';
    await tester.pumpWidget(buildButton());

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(displayDateOfBirthError.value, isFalse);
    expect(
      userRepository.calls,
      contains(startsWith('updateUser(uid=uid-1')),
    );
  });
}
