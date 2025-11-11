/// Application string constants.
///
/// Contains all hardcoded strings used in the application.
/// Complexity: O(1) for all operations.
class AppStrings {
  AppStrings._();

  // Common
  static const String appName = 'Huzur İslamda';
  static const String ok = 'Tamam';
  static const String cancel = 'İptal';
  static const String confirm = 'Onayla';
  static const String retry = 'Tekrar Dene';
  static const String loading = 'Yükleniyor...';

  // Errors
  static const String errorGeneric = 'Bir hata oluştu';
  static const String errorNetwork = 'İnternet bağlantısı yok';
  static const String errorTimeout = 'İstek zaman aşımına uğradı';

  // Onboarding
  static const String onboardingNext = 'ileri';
  static const String onboardingSignUp = 'kayıt Ol';
}
