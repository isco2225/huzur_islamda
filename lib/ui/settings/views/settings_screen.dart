import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late final SettingsViewModel _viewModel;
  late final LogOutViewModel _logOutViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = SettingsViewModel(
      appRepository: context.read<AppRepository>(),
      requestPermissionUseCase: context.read<RequestPermissionUseCase>(),
      getPermissionStatesUseCase: context.read<GetPermissionStatesUseCase>(),
      schedulePrayerNotificationsUseCase: context
          .read<SchedulePrayerNotificationsUseCase>(),
      notificationService: context.read<NotificationService>(),
    );
    _logOutViewModel = LogOutViewModel(
      authRepository: context.read<AuthRepository>(),
    );
    _viewModel.toggleNotifications.handleError(context, showSnackBar: true);
    _viewModel.toggleNotifications.handleCompleted(context);
    _logOutViewModel.logOut.handleError(context, showSnackBar: true);
    _logOutViewModel.logOut.handleCompleted(
      context,
      successMessage: 'Çıkış yapıldı!',
    );

    _viewModel.showOpenSettingsDialog.addListener(_onShowOpenSettingsDialog);
  }

  void _onShowOpenSettingsDialog() {
    if (_viewModel.showOpenSettingsDialog.value && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const OpenSettingsDialog(),
          ).then((_) {
            _viewModel.showOpenSettingsDialog.value = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.showOpenSettingsDialog.removeListener(_onShowOpenSettingsDialog);
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
