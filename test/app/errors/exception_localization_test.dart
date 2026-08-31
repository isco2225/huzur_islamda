import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/errors/localization/exception_localization.dart';
import 'package:huzur_islamda/app/errors/models/value_object_failure.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// A failure type that the localization switch does not know about.
class _UnknownValueObjectFailure implements ValueObjectFailure {}

/// Pumps a bare [Placeholder] and returns its [BuildContext].
Future<BuildContext> pumpContext(WidgetTester tester) async {
  await tester.pumpWidget(const Placeholder());
  return tester.element(find.byType(Placeholder));
}

void main() {
  group('exceptionToUserFriendlyMessage', () {
    const expectedMessages = <(Exception, String)>[
      // Connectivity
      (ConnectivityNoConnection(), 'İnternet bağlantısı yok'),
      (ConnectivityUnknown(), 'Bağlantınızı kontrol ediniz'),
      // App
      (AppLoadFailed(), 'Uygulama tercihleri yüklenirken bir hata oluştu'),
      // Assistant
      (AssistantDailyLimitExceeded(), 'Asistan günlük limiti doldu'),
      (AssistantUnexpectedError(), 'Beklenmeyen bir hata oluştu'),
      // Auth
      (AuthSignUpFailed(), 'Kayıt sırasında bir hata oluştu'),
      (
        AuthUserAlreadyExists(),
        'Bu e-posta adresi ile zaten bir hesap mevcut',
      ),
      (AuthSignInFailed(), 'Giriş sırasında bir hata oluştu'),
      (
        AuthEmailUsedWithDifferentProvider(),
        'Bu e-posta adresi başka bir giriş yöntemi (ör. Google) ile kayıtlı. '
            'Lütfen o yöntemle giriş yapın.',
      ),
      (AuthGoogleSignInFailed(), 'Google ile giriş sırasında bir hata oluştu'),
      (AuthAppleSignInFailed(), 'Apple ile giriş sırasında bir hata oluştu'),
      (AuthNoUserSignedIn(), 'Şu anda oturum açmış bir kullanıcı yok'),
      (AuthUserEmailNotFound(), 'Kullanıcı bulunamadı'),
      (
        AuthSendVerificationEmailFailed(),
        'Doğrulama e-postası gönderimi sırasında bir hata oluştu',
      ),
      (AuthEmailAlreadyVerified(), 'E-posta zaten doğrulanmış'),
      (
        AuthCheckEmailVerificationFailed(),
        'Doğrulama kontrolü sırasında bir hata oluştu',
      ),
      (AuthDeleteAccountFailed(), 'Hesap silinirken bir hata oluştu'),
      (
        AuthSendPasswordResetEmailFailed(),
        'Sıfırlama e-postası gönderimi sırasında bir hata oluştu',
      ),
      (AuthChangePasswordFailed(), 'Şifre değiştirilemedi'),
      // Dhikr
      (DhikrUserIdEmpty(), 'Kullanıcı oturumu olmadan işlem yapamaz.'),
      (DhikrRemoteCountNotFound(), 'Zikir sayısı bulunamadı'),
      (DhikrGroupIdsEmpty(), 'Grup silme işlemi için grup ID listesi boş'),
      (
        DhikrReminderCancelFailed(),
        'Bugünkü zikir hatırlatma bildirimi iptal edilemedi',
      ),
      (DhikrSaveFailed(), 'Zikirler kaydedilirken hata oluştu'),
      (DhikrFetchFailed(), 'Zikirler getirilirken hata oluştu'),
      (DhikrFetchAllFailed(), 'Tüm zikirler getirilirken hata oluştu'),
      (DhikrDeleteFailed(), 'Zikir silinirken hata oluştu'),
      (DhikrGetCountFailed(), 'Zikir sayısı getirilirken hata oluştu'),
    ];

    for (final (exception, message) in expectedMessages) {
      testWidgets('${exception.runtimeType} -> "$message"', (tester) async {
        final context = await pumpContext(tester);

        expect(context.exceptionToUserFriendlyMessage(exception), message);
      });
    }

    testWidgets('falls back to a generic message for unknown exceptions', (
      tester,
    ) async {
      final context = await pumpContext(tester);

      expect(
        context.exceptionToUserFriendlyMessage(Exception('x')),
        'Bilinmeyen bir hata oluştu',
      );
      expect(
        context.exceptionToUserFriendlyMessage(const FormatException('bad')),
        'Bilinmeyen bir hata oluştu',
      );
    });

    testWidgets('never returns an empty message', (tester) async {
      final context = await pumpContext(tester);

      for (final (exception, _) in expectedMessages) {
        expect(
          context.exceptionToUserFriendlyMessage(exception),
          isNotEmpty,
          reason: '${exception.runtimeType}',
        );
      }
    });
  });

  group('voFailureToUserFriendlyMessage', () {
    final expectedMessages = <(ValueObjectFailure, String)>[
      // Auth: ConfirmPassword
      (ConfirmPasswordEmpty(), 'Şifre boş olamaz'),
      (ConfirmPasswordDoNotMatch(), 'Şifreler eşleşmiyor'),
      // Auth: Email
      (EmailEmpty(), 'Email boş olamaz'),
      (EmailInvalid(), 'Email geçersiz'),
      // Auth: Password
      (PasswordEmpty(), 'Şifre boş olamaz'),
      (PasswordWeak(), 'Şifre zayıf'),
      (PasswordTooLong(), 'Şifre çok uzun'),
      // User: DateOfBirth
      (DateOfBirthEmpty(), 'Doğum tarihi boş olamaz'),
      (DateOfBirthInvalidFormat(), 'Tarih formatı geçersiz (GG/AA/YYYY)'),
      (DateOfBirthFutureDate(), 'Gelecek tarih seçilemez'),
      (DateOfBirthTooPastDate(), 'Tarih çok eski (1950\'den önce olamaz)'),
      (DateOfBirthTooYoung(), 'Minimum yaş 8 olmalıdır'),
      // User: Gender
      (GenderEmpty(), 'Cinsiyet boş olamaz'),
      // User: Name
      (NameEmpty(), 'Ad boş olamaz'),
      (NameTooLong(), 'Ad çok uzun'),
      (NameTooShort(), 'Ad çok kısa'),
      (NameInvalidFormat(), 'Ad formatı geçersiz'),
      // User: Surname
      (SurnameEmpty(), 'Soyad boş olamaz'),
      (SurnameTooLong(), 'Soyad çok uzun'),
      (SurnameTooShort(), 'Soyad çok kısa'),
      (SurnameInvalidFormat(), 'Soyad formatı geçersiz'),
    ];

    for (final (failure, message) in expectedMessages) {
      testWidgets('${failure.runtimeType} -> "$message"', (tester) async {
        final context = await pumpContext(tester);

        expect(context.voFailureToUserFriendlyMessage(failure), message);
      });
    }

    testWidgets('null failure maps to null', (tester) async {
      final context = await pumpContext(tester);

      expect(context.voFailureToUserFriendlyMessage(null), isNull);
    });

    testWidgets('unknown failure type falls back to a generic message', (
      tester,
    ) async {
      final context = await pumpContext(tester);

      expect(
        context.voFailureToUserFriendlyMessage(_UnknownValueObjectFailure()),
        'value object failure unknown',
      );
    });

    testWidgets('validators produce failures that localize', (tester) async {
      final context = await pumpContext(tester);

      expect(
        context.voFailureToUserFriendlyMessage(
          const Email.dirty('not-an-email').error,
        ),
        'Email geçersiz',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const Password.dirty('123').error,
        ),
        'Şifre zayıf',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const ConfirmPassword.dirty(password: 'abc123', value: 'xyz').error,
        ),
        'Şifreler eşleşmiyor',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const NameValueObject.dirty('A').error,
        ),
        'Ad çok kısa',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const SurnameValueObject.dirty('').error,
        ),
        'Soyad boş olamaz',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const GenderValueObject.dirty('').error,
        ),
        'Cinsiyet boş olamaz',
      );
      expect(
        context.voFailureToUserFriendlyMessage(
          const DateOfBirthValueObject.dirty('31/02/2000').error,
        ),
        'Tarih formatı geçersiz (GG/AA/YYYY)',
      );
    });
  });
}
