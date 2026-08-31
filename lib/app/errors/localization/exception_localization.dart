import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import '../../app.dart';

extension ExceptionLocalizationExtension on BuildContext {
  String exceptionToUserFriendlyMessage(Exception exception) {
    return switch (exception) {
      UserMessageException(:final message) => message,
      ConnectivityException() => switch (exception) {
        ConnectivityNoConnection() => 'İnternet bağlantısı yok',
        ConnectivityUnknown() => 'Bağlantınızı kontrol ediniz',
      },
      // App
      AppException() => switch (exception) {
        AppLoadFailed() => 'Uygulama tercihleri yüklenirken bir hata oluştu',
      },
      // Assistant
      AssistantException() => switch (exception) {
        AssistantDailyLimitExceeded() => 'Asistan günlük limiti doldu',
        AssistantUnexpectedError() => 'Beklenmeyen bir hata oluştu',
      },
      // Auth
      AuthException() => switch (exception) {
        AuthSignUpFailed() => 'Kayıt sırasında bir hata oluştu',
        AuthUserAlreadyExists() => 'Bu e-posta adresi ile zaten bir hesap mevcut',
        AuthSignInFailed() => 'Giriş sırasında bir hata oluştu',
        AuthEmailUsedWithDifferentProvider() =>
          'Bu e-posta adresi başka bir giriş yöntemi (ör. Google) ile kayıtlı. Lütfen o yöntemle giriş yapın.',
        AuthGoogleSignInFailed() =>
          'Google ile giriş sırasında bir hata oluştu',
        AuthAppleSignInFailed() =>
          'Apple ile giriş sırasında bir hata oluştu',
        AuthNoUserSignedIn() => 'Şu anda oturum açmış bir kullanıcı yok',
        AuthUserEmailNotFound() => 'Kullanıcı bulunamadı',
        AuthSendVerificationEmailFailed() =>
          'Doğrulama e-postası gönderimi sırasında bir hata oluştu',
        AuthEmailAlreadyVerified() => 'E-posta zaten doğrulanmış',
        AuthCheckEmailVerificationFailed() =>
          'Doğrulama kontrolü sırasında bir hata oluştu',
        AuthDeleteAccountFailed() => 'Hesap silinirken bir hata oluştu',
        AuthSendPasswordResetEmailFailed() =>
          'Sıfırlama e-postası gönderimi sırasında bir hata oluştu',
        AuthChangePasswordFailed() => 'Şifre değiştirilemedi',
      },
      // Dhikr
      DhikrException() => switch (exception) {
        DhikrUserIdEmpty() => 'Kullanıcı oturumu olmadan işlem yapamaz.',
        DhikrRemoteCountNotFound() => 'Zikir sayısı bulunamadı',
        DhikrGroupIdsEmpty() => 'Grup silme işlemi için grup ID listesi boş',
        DhikrReminderCancelFailed() =>
          'Bugünkü zikir hatırlatma bildirimi iptal edilemedi',
        DhikrSaveFailed() => 'Zikirler kaydedilirken hata oluştu',
        DhikrFetchFailed() => 'Zikirler getirilirken hata oluştu',
        DhikrFetchAllFailed() => 'Tüm zikirler getirilirken hata oluştu',
        DhikrDeleteFailed() => 'Zikir silinirken hata oluştu',
        DhikrGetCountFailed() => 'Zikir sayısı getirilirken hata oluştu',
      },
      // Unknown
      _ => 'Bilinmeyen bir hata oluştu',
    };
  }

  String? voFailureToUserFriendlyMessage(ValueObjectFailure? fail) {
    return switch (fail) {
      null => null,
      // Auth
      ConfirmPasswordValueObjectFailure() => switch (fail) {
        ConfirmPasswordEmpty() => 'Şifre boş olamaz',
        ConfirmPasswordDoNotMatch() => 'Şifreler eşleşmiyor',
      },
      EmailValueObjectFailure() => switch (fail) {
        EmailEmpty() => 'Email boş olamaz',
        EmailInvalid() => 'Email geçersiz',
      },
      PasswordValueObjectFailure() => switch (fail) {
        PasswordEmpty() => 'Şifre boş olamaz',
        PasswordWeak() => 'Şifre zayıf',
        PasswordTooLong() => 'Şifre çok uzun',
      },
      // User
      DateOfBirthValueObjectFailure() => switch (fail) {
        DateOfBirthEmpty() => 'Doğum tarihi boş olamaz',
        DateOfBirthInvalidFormat() => 'Tarih formatı geçersiz (GG/AA/YYYY)',
        DateOfBirthFutureDate() => 'Gelecek tarih seçilemez',
        DateOfBirthTooPastDate() => 'Tarih çok eski (1950\'den önce olamaz)',
        DateOfBirthTooYoung() => 'Minimum yaş 8 olmalıdır',
      },
      GenderValueObjectFailure() => switch (fail) {
        GenderEmpty() => 'Cinsiyet boş olamaz',
      },
      NameValueObjectFailure() => switch (fail) {
        NameEmpty() => 'Ad boş olamaz',
        NameTooLong() => 'Ad çok uzun',
        NameTooShort() => 'Ad çok kısa',
        NameInvalidFormat() => 'Ad formatı geçersiz',
      },
      SurnameValueObjectFailure() => switch (fail) {
        SurnameEmpty() => 'Soyad boş olamaz',
        SurnameTooLong() => 'Soyad çok uzun',
        SurnameTooShort() => 'Soyad çok kısa',
        SurnameInvalidFormat() => 'Soyad formatı geçersiz',
      },

      // Unknown
      _ => switch (fail) {
        _ => 'value object failure unknown',
      },
    };
  }
}
