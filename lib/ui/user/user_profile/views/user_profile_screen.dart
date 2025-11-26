import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../ui.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileViewModel _viewModel;
  late final LogOutViewModel _logOutViewModel;
  late final FetchUserViewModel _userViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = UserProfileViewModel();
    _logOutViewModel = LogOutViewModel(
      authRepository: context.read<AuthRepository>(),
    );
    _userViewModel = FetchUserViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
    _logOutViewModel.logOut.handleError(context, showSnackBar: true);
    _logOutViewModel.logOut.handleCompleted(
      context,
      successMessage: 'Çıkış yapıldı!',
      onCompleted: (_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            const SignInRoute().go(context);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _logOutViewModel.dispose();
    _userViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserProfileView(
      viewModel: _logOutViewModel,
      userViewModel: _userViewModel,
    );
  }
}
