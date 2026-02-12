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
                                  builder: (context) => const SettingsInfoBottomSheet(
                                    title: 'Uygulama Hakkında',
                                    subtitle:
                                        'Huzur İslamda uygulamasının amacı ve yaklaşımı',
                                    child: Text(
                                      'Huzur İslamda, modern hayatın yoğunluğu içinde Kur’an ve sünnet ışığında daha huzurlu, '
                                      'bilinçli ve dengeli bir yaşam sürmene yardımcı olmak için tasarlanmış bir uygulamadır.\n\n'
                                      'Uygulama; zikir takipleri, hatırlatmalar, namaz vakitleri, akış (flow) içerikleri ve kişisel '
                                      'manevi hedeflerini destekleyici araçlarla, ibadetlerini ve günlük rutinini düzenli ve '
                                      'sürdürülebilir hale getirmeyi hedefler.\n\n'
                                      'Sunulan içeriklerin hiçbiri bir fetva veya bağlayıcı dini hüküm niteliği taşımamakta olup, '
                                      'genel bilgilendirme ve kişisel gelişim amacıyla hazırlanmıştır. Dini konularda nihai karar ve '
                                      'sorumluluk kullanıcıya aittir.',
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
                                  builder: (context) => const SettingsInfoBottomSheet(
                                    title: 'Gizlilik Politikası',
                                    subtitle:
                                        'Kişisel verilerinizin toplanması, saklanması ve korunması hakkında bilgiler',
                                    child: Text(
                                      'Huzur İslamda olarak gizliliğinize önem veriyoruz. Uygulama, deneyimini iyileştirmek ve '
                                      'özellikleri doğru şekilde sunmak için bazı temel verileri işleyebilir.\n\n'
                                      'Toplanan veriler:\n'
                                      '- Hesap oluşturma sırasında paylaştığın temel profil bilgileri (ör. e‑posta adresi).\n'
                                      '- Uygulama içi kullanım istatistikleri ve etkileşimler (özellikleri nasıl kullandığın gibi), '
                                      'uygulamayı geliştirmek ve hataları gidermek amacıyla anonim veya yarı anonim şekilde '
                                      'değerlendirilebilir.\n\n'
                                      'Veri saklama ve güvenlik:\n'
                                      '- Verilerin makul güvenlik önlemleri ile korunmasına özen gösterilir.\n'
                                      '- Hesabını sildiğinde, yasal yükümlülükler ve teknik sınırlar haricinde, kişisel verilerin makul '
                                      'süre içinde sistemlerimizden kaldırılmaya çalışılır.\n\n'
                                      'Üçüncü taraflar:\n'
                                      '- Analitik, hata izleme veya bildirim servisleri gibi üçüncü taraf hizmet sağlayıcılar '
                                      'kullanılabilir. Bu servisler yalnızca hizmetin sağlanması için gerekli verileri alır ve kendi '
                                      'gizlilik politikalarına tabidir.\n\n'
                                      'Hakların:\n'
                                      '- Verilerine erişme, düzeltme ve uygun olduğunda silinmesini talep etme hakkına sahipsin.\n\n'
                                      'Uygulamayı kullanmaya devam ederek, bu gizlilik politikasını okuduğunu ve kabul ettiğini '
                                      'kabul etmiş olursun.',
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
                                  builder: (context) => const SettingsInfoBottomSheet(
                                    title: 'Kullanım Koşulları',
                                    subtitle:
                                        'Huzur İslamda uygulamasını kullanırken geçerli kurallar ve sorumluluklar',
                                    child: Text(
                                      'Bu uygulamayı kullanarak aşağıdaki kullanım koşullarını kabul etmiş olursun:\n\n'
                                      '1. Kişisel ve sınırlı kullanım\n'
                                      '- Uygulama, kişisel ve bireysel kullanım içindir. Ticari amaçlarla veya kötüye kullanım '
                                      'oluşturacak şekilde kullanılamaz.\n\n'
                                      '2. İçerik ve sorumluluk\n'
                                      '- Uygulamada sunulan içerikler genel bilgilendirme amaçlıdır; dini veya hukuki açıdan nihai karar '
                                      'mercii değildir.\n'
                                      '- Uygulamadaki dinî tavsiye ve hatırlatmalar, kişisel değerlendirme ve araştırmanın yerine geçmez; '
                                      'her türlü ibadet, uygulama ve tercih, kullanıcının kendi sorumluluğundadır.\n\n'
                                      '3. Yasaklı kullanım örnekleri\n'
                                      '- Uygulamayı, hukuka aykırı, hakaret içeren, tehditkâr, rahatsız edici veya başkalarının haklarını '
                                      'ihlâl edici şekilde kullanamazsın.\n'
                                      '- Uygulamanın güvenliğini ihlâl etmeye, tersine mühendislik yapmaya veya sistemlere izinsiz erişmeye '
                                      'teşebbüs edemezsin.\n\n'
                                      '4. Hesap ve erişimin sonlandırılması\n'
                                      '- Geliştirici, kullanım koşullarının ihlâli durumunda, bildirim yaparak veya gerekli hallerde '
                                      'bildirim yapmaksızın hesabını ve uygulamaya erişimini kısmen veya tamamen sonlandırma hakkını saklı '
                                      'tutar.\n\n'
                                      '5. Değişiklikler\n'
                                      '- Uygulama özellikleri, gizlilik politikası ve kullanım koşulları zaman içinde güncellenebilir. '
                                      'Uygulamayı kullanmaya devam etmen, güncellenmiş şartları da kabul ettiğin anlamına gelir.\n\n'
                                      '6. Sorumluluk sınırlaması\n'
                                      '- Uygulamanın kesintisiz, hatasız veya tüm beklentilerini eksiksiz karşılayacağı garanti edilmez. '
                                      'Doğrudan veya dolaylı zararlardan geliştirici, kanunen zorunlu olmadığı sürece sorumlu tutulamaz.',
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
