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
  late final UserViewModel _userViewModel;
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
    _userViewModel = UserViewModel(
      deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
      userRepository: context.read<UserRepository>(),
    );
    _userViewModel.deleteAccount.handleError(context, showSnackBar: true);
    _userViewModel.deleteAccount.handleCompleted(
      context,
      successMessage: 'Hesap silindi!',
    );
    _viewModel.toggleNotifications.handleError(context, showSnackBar: true);
    _viewModel.toggleNotifications.handleCompleted(context);
    _viewModel.toggleVibration.handleError(context, showSnackBar: true);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // The user may have changed the notification permission in the OS
    // settings; re-sync the toggle when the app comes back to the foreground.
    if (state == AppLifecycleState.resumed && mounted) {
      _viewModel.checkAndSyncPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.showOpenSettingsDialog.removeListener(_onShowOpenSettingsDialog);
    _viewModel.dispose();
    _logOutViewModel.dispose();
    _userViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsView(
      viewModel: _viewModel,
      logOutViewModel: _logOutViewModel,
      userViewModel: _userViewModel,
    );
  }
}
