import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/settings/widgets/navigatable_setting_tile.dart';

import '../../../../app/app.dart';
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
    return ValueListenableBuilder(
      valueListenable: logOutViewModel.logOut.running,
      builder: (context, isLoggingOut, _) {
        return Stack(
          children: [
            BaseScaffold(
              appBar: const SettingsAppBar(),
              safeArea: true,
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: context.verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.maxContentWidth,
                    ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoggingOut)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
