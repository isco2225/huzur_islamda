import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/settings/widgets/navigatable_setting_tile.dart';

import '../../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.viewModel,
    required this.logOutViewModel,
  });

  final SettingsViewModel viewModel;
  final LogOutViewModel logOutViewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const SettingsAppBar(),
      safeArea: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsDisplayerCard(
                  title: 'Bildirimler',
                  description:
                      'Bildirim seçeneklerini tercihinize göre özelleştirin.',
                  children: [
                    SwitchableSettingTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Bildirimler',
                      subtitle: 'Bildirim ayarlarını yönet',
                      valueListenable: viewModel.isNotificationsEnabled,
                      onChanged: (value) =>
                          viewModel.toggleNotifications.execute(value),
                    ),
                    SettingsDivider(),
                    SwitchableSettingTile(
                      icon: Icons.vibration_rounded,
                      title: 'Titreşim',
                      subtitle: 'Bildirimlerde titreşimi kullan',
                      valueListenable: viewModel.isVibrationEnabled,
                      onChanged: (value) {
                        if (value) {
                          VibrationUseCase.vibrateLight(context);
                          viewModel.toggleVibration.execute(value);
                        }
                        viewModel.toggleVibration.execute(value);
                      },
                    ),
                  ],
                ),
                SizedBox(height: context.spacingMedium),
                SettingsDisplayerCard(
                  title: 'Hesap',
                  children: [
                    NavigatableSettingTile(
                      icon: Icons.lock_reset_rounded,
                      title: 'Şifreyi Değiştir',
                      subtitle: 'Güvenliğinizi güncel tutun',
                      onTap: () {
                        // TODO: Navigate to change password
                      },
                    ),
                    SettingsDivider(),
                    SettingsLogOutCard(
                      onTap: () {
                        logOutViewModel.logOut.execute();
                      },
                    ),
                  ],
                ),
                // Debug mode'da test butonları göster
                if (kDebugMode) ...[
                  SizedBox(height: context.spacingMedium),
                  SettingsDisplayerCard(
                    title: 'Test Bildirimleri',
                    description: 'Bildirimleri test etmek için kullanın',
                    children: [
                      NavigatableSettingTile(
                        icon: Icons.notification_add_rounded,
                        title: 'Test Bildirimlerini Planla',
                        subtitle: 'Her 10 dakikada bir 5 bildirim planla',
                        onTap: () {
                          viewModel.scheduleTestNotifications.execute();
                        },
                      ),
                      SettingsDivider(),
                      NavigatableSettingTile(
                        icon: Icons.notifications_off_rounded,
                        title: 'Test Bildirimlerini İptal Et',
                        subtitle: 'Planlanmış test bildirimlerini iptal et',
                        onTap: () {
                          viewModel.cancelTestNotifications.execute();
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
