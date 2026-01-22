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
      userRepository: context.read<UserRepository>(),
      schedulePrayerNotificationsUseCase: context
          .read<SchedulePrayerNotificationsUseCase>(),
      notificationService: context.read<NotificationService>(),
    );
    _logOutViewModel = LogOutViewModel(
      authRepository: context.read<AuthRepository>(),
    );
    _viewModel.toggleNotifications.handleError(context, showSnackBar: true);
    _viewModel.toggleNotifications.handleCompleted(
      context,
      successMessage: 'Bildirim ayarı güncellendi',
    );
    _viewModel.scheduleTestNotifications.handleError(context, showSnackBar: true);
    _viewModel.scheduleTestNotifications.handleCompleted(
      context,
      successMessage: 'Test bildirimleri planlandı (her 10 dakikada bir)',
    );
    _viewModel.cancelTestNotifications.handleError(context, showSnackBar: true);
    _viewModel.cancelTestNotifications.handleCompleted(
      context,
      successMessage: 'Test bildirimleri iptal edildi',
    );
    _logOutViewModel.logOut.handleError(context, showSnackBar: true);
    _logOutViewModel.logOut.handleCompleted(
      context,
      successMessage: 'Çıkış yapıldı!',
    );

    // Dialog göstermek için listener ekle
    _viewModel.showOpenSettingsDialog.addListener(_onShowOpenSettingsDialog);
  }

  void _onShowOpenSettingsDialog() {
    if (_viewModel.showOpenSettingsDialog.value && mounted) {
      // Dialog'u göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const OpenSettingsDialog(),
          ).then((_) {
            // Dialog kapandığında state'i sıfırla
            _viewModel.showOpenSettingsDialog.value = false;
          });
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Uygulama geri geldiğinde (resumed) izin durumunu kontrol et
    // Kullanıcı ayarlardan izin verdikten sonra uygulama geri geldiğinde
    // izin durumunu senkronize et
    if (state == AppLifecycleState.resumed) {
      _viewModel.checkAndSyncPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
