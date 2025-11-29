import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import '../../app.dart';

extension ExceptionLocalizationExtension on BuildContext {
  String exceptionToUserFriendlyMessage(Exception exception) {
    return switch (exception) {
      // AuthException() => switch (exception) {
      //   AuthUnknown() => 'failure unknown',
      //   AuthAuthRequired() => 'auth required',
      //   AuthEmailNotFound() => 'email not found',
      //   AuthPasswordNotFound() => 'password not found',
      //   AuthInvalidCredential() => 'invalid credential',
      //   AuthTooManyFailedAttempts() => 'too many failed attempts',
      //   AuthInvalidVerificationCode() => 'invalid verification code',
      //   AuthUnableToCreateAccount() => 'unable to create account',
      //   AuthExpiredVerificationCode() => 'expired verification code',
      //   AuthUserNotFound() => 'user not found',
      //   AuthUserCreationDenied() => 'user creation denied',
      //   AuthInternalError() => 'internal error',
      //   AuthBlocked() => 'blocked',
      //   AuthUnableToSendMail() => 'unable to send mail',
      //   AuthNewEmailHaveAccount() => 'new email have account',
      //   AuthNoEmailUpdateRequestFound() => 'no email update request found',
      // },
      // CategoryException() => switch (exception) {
      //   CategoryUnknown() => 'failure unknown',
      //   CategoryAuthRequired() => 'auth required',
      //   CategoryNoCategoryFound() => 'no category found',
      //   CategoryNoPermission() => 'no permission',
      //   CategoryInternalError() => 'internal error',
      //   CategoryBlocked() => 'blocked',
      // },
      // ProductException() => switch (exception) {
      //   ProductUnknown() => 'failure unknown',
      //   ProductAuthRequired() => 'auth required',
      //   ProductNoProductFound() => 'no product found',
      //   ProductNoPermission() => 'no permission',
      //   ProductInternalError() => 'internal error',
      //   ProductBlocked() => 'blocked',
      // },
      // ImageException() => switch (exception) {
      //   ImageExceptionUnknown() => 'failure unknown',
      //   ImageExceptionTooMuchImageSelected() => 'too much image selected',
      //   ImageExceptionNotEnoughImages() => 'not enough images',
      //   ImagesCouldNotBeSaved() => 'images could not be saved',
      //   ImageExceptionImageCouldNotCompressed() => 'images could not be saved',
      // },
      // AdminException() => switch (exception) {
      //   AdminUnknown() => 'failure unknown',
      //   AdminAuthRequired() => 'auth required',
      //   AdminNoAdminFound() => 'no admin found',
      //   AdminNoPermission() => 'no permission',
      //   AdminInternalError() => 'internal error',
      //   AdminBlocked() => 'blocked',
      // },
      // // Unknown
      _ => 'failure unknown',
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
      MaritalStatusValueObjectFailure() => switch (fail) {
        MaritalStatusEmpty() => 'Evlilik durumu boş olamaz',
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
