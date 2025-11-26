import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/data.dart';
import '../edit_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditProfileViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
    );

    // Error handling
    _viewModel.updateProfile.handleError(context, showSnackBar: true);

    // Success handling
    _viewModel.updateProfile.handleCompleted(
      context,
      successMessage: 'Profil başarıyla güncellendi!',
      popCount: 1,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditProfileView(viewModel: _viewModel);
  }
}
