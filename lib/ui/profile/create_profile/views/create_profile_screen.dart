import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  late final CreateProfileViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = CreateProfileViewModel(
      authRepository: context.read<AuthRepository>(),
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
        const FlowRoute().go(context);
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
    return CreateProfileView(viewModel: _viewModel);
  }
}
