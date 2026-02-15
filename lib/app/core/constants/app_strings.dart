class AppStrings {
  AppStrings._();

  static const String appName = 'Huzur İslamda';
  static const String ok = 'Tamam';
  static const String cancel = 'İptal';
  static const String confirm = 'Onayla';
  static const String retry = 'Tekrar Dene';
  static const String loading = 'Yükleniyor...';
  static const String start = 'Başla';

  // Errors
  static const String errorGeneric = 'Bir hata oluştu';
  static const String errorNetwork = 'İnternet bağlantısı yok';
  static const String errorTimeout = 'İstek zaman aşımına uğradı';

  // Onboarding — Sade: uygulamanın amacı (1. sayfa), kısa davet (2. sayfa). Tek animasyon ilk sayfada.
  static const String onboardingNext = 'İleri';
  static const String signUp = 'kayıt Ol';
  static const String onboardingTitle1 = 'Hoş Geldiniz';
  static const String onboardingText1 =
      'İslamın ışığında daha huzurlu, dengeli bir yaşam sürmene ve ibadet ile günlük rutinini '
      'düzenli tutmana yardımcı olmak için buradayız.';
  static const String onboardingTitle2 = 'Namaz vakitleri';
  static const String onboardingText2 =
      'Günlük namaz vakitlerini görüntüle, hatırlatmalarla vakitleri kaçırma. Konumuna göre vakitler hesaplanır.';
  static const String onboardingTitle4 = 'Başlamaya hazır mısın?';
  static const String onboardingText4 = 'Beraber bu yolculukta ilerleyelim!';
  static const String onboardingTitle3 = 'Akıllı Zikirmatik';
  static const String onboardingText3 =
      'Günlük zikirlerini oluştur, say ve takip et. Geçmiş zikirlerini görüntüle; ruh haline göre zikir seti oluşturabilirsin.';

  // Settings - Legal texts
  static const String settingsAboutAppDescription =
      'Huzur İslamda, modern hayatın yoğunluğu içinde Kur’an ve sünnet ışığında daha huzurlu, '
      'bilinçli ve dengeli bir yaşam sürmene yardımcı olmak için tasarlanmış bir uygulamadır.\n\n'
      'Uygulama; zikir takipleri, hatırlatmalar, namaz vakitleri, akış (flow) içerikleri ve kişisel '
      'manevi hedeflerini destekleyici araçlarla, ibadetlerini ve günlük rutinini düzenli ve '
      'sürdürülebilir hale getirmeyi hedefler.\n\n'
      'Sunulan içeriklerin hiçbiri bir fetva veya bağlayıcı dini hüküm niteliği taşımamakta olup, '
      'genel bilgilendirme ve kişisel gelişim amacıyla hazırlanmıştır. Dini konularda nihai karar ve '
      'sorumluluk kullanıcıya aittir.';

  static const String settingsPrivacyPolicy =
      'Huzur İslamda olarak gizliliğine önem veriyoruz. Uygulama, deneyimini iyileştirmek ve '
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
      'kabul etmiş olursun.';

  static const String settingsTermsOfService =
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
      'Doğrudan veya dolaylı zararlardan geliştirici, kanunen zorunlu olmadığı sürece sorumlu tutulamaz.';
}
