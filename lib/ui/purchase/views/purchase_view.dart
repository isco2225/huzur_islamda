import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../view_models/purchase_view_model.dart';
import '../../settings/widgets/settings_info_bottom_sheet.dart';

class PurchaseView extends StatelessWidget {
  const PurchaseView({super.key, required this.viewModel});

  final PurchaseViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Tasarımdaki renk paleti
    const Color kCreamBackground = Color(0xFFFDF8F2); // Krem Arkaplan
    const Color kGoldColor = Color(0xFFC69C6D); // Altın Sarısı
    const Color kGreenButton = Color(0xFF1B5E20); // Koyu Yeşil Buton

    final responsive = context.responsive;

    return BaseScaffold(
      safeArea: true,
      backgroundColor: kCreamBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Arka plandaki hafif desen
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: 400,
                  color: kGoldColor,
                ),
              ),
            ),
            Column(
              children: [
                // Kapatma butonu (sağ üst)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: ValueListenableBuilder<SupportPackage>(
                      valueListenable: viewModel.selectedPackage,
                      builder: (context, selectedPackage, _) {
                        final selectedIndex =
                            selectedPackage == SupportPackage.weekly ? 0 : 1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/icons/moon_mosque.png',
                              width: context.screenWidth * 0.3,
                              height: context.screenHeight * 0.15,
                              fit: BoxFit.contain,
                            ),
                            const Text(
                              "Premium'a Geç",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Ayrıcalıkların Tadını Çıkarın",
                              style: TextStyle(
                                fontSize: 16,
                                color: kGoldColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const _FeatureItem(
                              icon: Icons.shield_outlined,
                              title: "Reklamsız Deneyim",
                              subtitle:
                                  "Reklamsız deneyimin, farkını gönülden hissedin.",
                              color: kGoldColor,
                            ),
                            const SizedBox(height: 20),
                            const _FeatureItem(
                              icon: Icons.auto_stories,
                              title: "Sınırsız İslami Asistan Erişimi",
                              subtitle:
                                  "Sınırsız İslami Asistan Erişimi ile limitlere takılma. Bir tıkla sorularına cevap bul.",
                              color: kGoldColor,
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                // Haftalık kart
                                Expanded(
                                  child: _PriceCard(
                                    title: "Haftalık Plan",
                                    price: "₺49 / Hafta",
                                    subtitle: "İptal edilebilir",
                                    isSelected: selectedIndex == 0,
                                    activeColor: kGoldColor,
                                    isPopular: false,
                                    onTap: () =>
                                        viewModel.selectedPackage.value =
                                            SupportPackage.weekly,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Yıllık kart (popüler)
                                Expanded(
                                  child: _PriceCard(
                                    title: "Yıllık Plan",
                                    price: "₺1999 / Yıl",
                                    subtitle: "550TL daha az öde",
                                    isSelected: selectedIndex == 1,
                                    activeColor: kGoldColor,
                                    isPopular: true,
                                    onTap: () =>
                                        viewModel.selectedPackage.value =
                                            SupportPackage.yearly,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: AppButton(
                                onPressed: viewModel.purchaseSelected.execute,
                                text: 'Abone Ol',
                                running: viewModel.purchaseSelected.running,
                                backgroundColor: kGreenButton,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // _FooterLink(
                                  //   text: "Satın Almayı Geri Yükle",
                                  //   onTap: viewModel.restorePurchases.execute,
                                  // ),
                                  _FooterLink(
                                    text: "Kullanım Koşulları",
                                    onTap: () => _showTermsOfService(context),
                                  ),
                                  _FooterLink(
                                    text: "Gizlilik Politikası",
                                    onTap: () => _showPrivacyPolicy(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SettingsInfoBottomSheet(
        title: 'Kullanım Koşulları',
        subtitle:
            'Huzur İslamda uygulamasını kullanırken geçerli kurallar ve sorumluluklar',
        child: Text(
          AppStrings.settingsTermsOfService,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SettingsInfoBottomSheet(
        title: 'Gizlilik Politikası',
        subtitle:
            'Kişisel verilerinizin toplanması, saklanması ve korunması hakkında bilgiler',
        child: Text(
          AppStrings.settingsPrivacyPolicy,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    this.isPopular = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? activeColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: Colors.grey.shade200,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "En Popüler",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
