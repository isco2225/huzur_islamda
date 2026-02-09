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
                          title: 'Etkileşimler',
                          description:
                              'Seçenekleri Tercihinize Göre Özelleştirin.',
                          children: [
                            SwitchableSettingTile(
                              icon: Icons.notifications_none_rounded,
                              title: 'Bildirimler',
                              subtitle: 'Bildirim Ayarlarını Yönet',
                              valueListenable: viewModel.isNotificationsEnabled,
                              onChanged: (value) =>
                                  viewModel.toggleNotifications.execute(value),
                            ),
                            SettingsDivider(),
                            SwitchableSettingTile(
                              icon: Icons.vibration_rounded,
                              title: 'Titreşim',
                              subtitle: 'Titreşimi Kullan',
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
                          title: 'Hakkında',
                          description: 'Uygulama hakkında bilgi alın',
                          children: [
                            NavigatableSettingTile(
                              icon: Icons.info_outline_rounded,
                              title: 'Uygulama Hakkında',
                              subtitle: 'Uygulamanın Açıklamasını Öğrenin',
                              onTap: () {
                                // TODO: open about bottom sheet
                              },
                            ),
                            SettingsDivider(),
                            // Privacy Policy
                            NavigatableSettingTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Gizlilik Politikası',
                              subtitle: 'Gizlilik Politikasını Öğrenin',
                              onTap: () {
                                // TODO: open privacy policy bottom sheet
                              },
                            ),
                            SettingsDivider(),
                            // Terms of Service
                            NavigatableSettingTile(
                              icon: Icons.description_outlined,
                              title: 'Kullanım Koşulları',
                              subtitle: 'Kullanım Koşullarını Öğrenin',
                              onTap: () {
                                // TODO: open terms of service bottom sheet
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacingMedium),
                        SettingsDisplayerCard(
                          title: 'Hesap',
                          description: 'Hesap ayarlarını yönetin',
                          children: [
                            // Edit Profile
                            NavigatableSettingTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Profili Düzenle',
                              subtitle: 'Profil Bilgilerini Düzenleyin',
                              onTap: () {
                                context.pushEditProfile();
                              },
                            ),
                            SettingsDivider(),
                            NavigatableSettingTile(
                              icon: Icons.lock_reset_rounded,
                              title: 'Şifreyi Değiştir',
                              subtitle: 'Hesap Şifresini Güncelleyin',
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
                            SettingsDivider(),
                            SettingsDeleteAccountCard(
                              onTap: () {
                                // TODO: Navigate to delete account
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacingMedium),
                        Center(child: VersionDisplayer()),
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
