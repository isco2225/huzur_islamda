import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;
  late final LogOutViewModel _logOutViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _logOutViewModel = LogOutViewModel(
      authRepository: context.read<AuthRepository>(),
    );
    _logOutViewModel.logOut.handleError(context, showSnackBar: true);
    _logOutViewModel.logOut.handleCompleted(
      context,
      successMessage: 'Çıkış yapıldı!',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _logOutViewModel.logOut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsView(
      viewModel: _viewModel,
      logOutViewModel: _logOutViewModel,
    );
  }
}
