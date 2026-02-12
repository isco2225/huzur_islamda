import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/settings/widgets/navigatable_setting_tile.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.viewModel,
    required this.logOutViewModel,
    required this.userViewModel,
  });

  final SettingsViewModel viewModel;
  final LogOutViewModel logOutViewModel;
  final UserViewModel userViewModel;
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
                              subtitle:
                                  'Uygulamanın amacını ve yaklaşımını öğrenin',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) =>
                                      const SettingsInfoBottomSheet(
                                        title: 'Uygulama Hakkında',
                                        subtitle:
                                            'Huzur İslamda uygulamasının amacı ve yaklaşımı',
                                        child: Text(
                                          AppStrings
                                              .settingsAboutAppDescription,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                );
                              },
                            ),
                            SettingsDivider(),
                            // Privacy Policy
                            NavigatableSettingTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Gizlilik Politikası',
                              subtitle:
                                  'Verilerinizin nasıl korunduğunu öğrenin',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) =>
                                      const SettingsInfoBottomSheet(
                                        title: 'Gizlilik Politikası',
                                        subtitle:
                                            'Kişisel verilerinizin toplanması, saklanması ve korunması hakkında bilgiler',
                                        child: Text(
                                          AppStrings.settingsPrivacyPolicy,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                );
                              },
                            ),
                            SettingsDivider(),
                            // Terms of Service
                            NavigatableSettingTile(
                              icon: Icons.description_outlined,
                              title: 'Kullanım Koşulları',
                              subtitle:
                                  'Uygulamanın kullanım esaslarını inceleyin',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) =>
                                      const SettingsInfoBottomSheet(
                                        title: 'Kullanım Koşulları',
                                        subtitle:
                                            'Huzur İslamda uygulamasını kullanırken geçerli kurallar ve sorumluluklar',
                                        child: Text(
                                          AppStrings.settingsTermsOfService,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                );
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
                              logOutViewModel: logOutViewModel,
                            ),
                            SettingsDivider(),
                            SettingsDeleteAccountCard(
                              userViewModel: userViewModel,
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
