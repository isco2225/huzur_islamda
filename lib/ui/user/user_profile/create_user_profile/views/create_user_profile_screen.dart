import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
import '../../../../ui.dart';

class CreateUserProfileScreen extends StatefulWidget {
  const CreateUserProfileScreen({super.key});

  @override
  State<CreateUserProfileScreen> createState() =>
      _CreateUserProfileScreenState();
}

class _CreateUserProfileScreenState extends State<CreateUserProfileScreen> {
  late final CreateUserProfileViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = CreateUserProfileViewModel(
      createUserProfileUseCase: context.read<CreateUserProfileUseCase>(),
    );

    // Error handling
    _viewModel.createUserProfile.handleError(context, showSnackBar: true);

    // Success handling - navigate to navigation bar after successful profile creation
    _viewModel.createUserProfile.handleCompleted(
      context,
      successMessage: 'Profil başarıyla oluşturuldu!',
      onCompleted: (_) {
        // Navigate to navigation bar (FlowRoute)
        context.goToFlow();
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CreateUserProfileView(viewModel: _viewModel);
  }
}
