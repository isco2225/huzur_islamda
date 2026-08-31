import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  group('Email', () {
    test('pure input is pure, has no display error but is not valid', () {
      const email = Email.pure();

      expect(email.isPure, isTrue);
      expect(email.value, '');
      expect(email.isValid, isFalse);
      expect(email.error, isA<EmailEmpty>());
      expect(email.displayError, isNull);
    });

    test('dirty empty value reports EmailEmpty', () {
      const email = Email.dirty('');

      expect(email.isPure, isFalse);
      expect(email.error, isA<EmailEmpty>());
      expect(email.displayError, isA<EmailEmpty>());
      expect(email.isValid, isFalse);
    });

    test('accepts well-formed addresses', () {
      const valid = [
        'a@b.co',
        'user.name+tag@sub.domain.org',
        'UPPER_case-1%x@host-name.tr',
      ];
      for (final value in valid) {
        final email = Email.dirty(value);
        expect(email.isValid, isTrue, reason: value);
        expect(email.error, isNull, reason: value);
      }
    });

    test('rejects malformed addresses with EmailInvalid', () {
      const invalid = [
        'a@b.c', // TLD shorter than 2 chars
        'a@b', // no TLD
        'ab.com', // no @
        'a b@b.com', // whitespace in local part
        '@b.com', // empty local part
        'a@.com', // empty domain label
        'a@b.com ', // trailing whitespace
      ];
      for (final value in invalid) {
        final email = Email.dirty(value);
        expect(email.isValid, isFalse, reason: value);
        expect(email.error, isA<EmailInvalid>(), reason: value);
      }
    });
  });

  group('Password', () {
    test('pure input reports PasswordEmpty and is not valid', () {
      const password = Password.pure();

      expect(password.isPure, isTrue);
      expect(password.isValid, isFalse);
      expect(password.error, isA<PasswordEmpty>());
      expect(password.displayError, isNull);
    });

    test('dirty empty value reports PasswordEmpty', () {
      const password = Password.dirty('');

      expect(password.error, isA<PasswordEmpty>());
      expect(password.isValid, isFalse);
    });

    test('5 characters is PasswordWeak', () {
      final password = Password.dirty('a' * 5);

      expect(password.error, isA<PasswordWeak>());
      expect(password.isValid, isFalse);
    });

    test('6 characters is valid (lower boundary)', () {
      final password = Password.dirty('a' * 6);

      expect(password.error, isNull);
      expect(password.isValid, isTrue);
    });

    test('64 characters is valid (upper boundary)', () {
      final password = Password.dirty('a' * 64);

      expect(password.error, isNull);
      expect(password.isValid, isTrue);
    });

    test('65 characters is PasswordTooLong', () {
      final password = Password.dirty('a' * 65);

      expect(password.error, isA<PasswordTooLong>());
      expect(password.isValid, isFalse);
    });
  });

  group('ConfirmPassword', () {
    test('pure input has empty password and value', () {
      const confirm = ConfirmPassword.pure();

      expect(confirm.isPure, isTrue);
      expect(confirm.password, '');
      expect(confirm.value, '');
      expect(confirm.error, isA<ConfirmPasswordEmpty>());
      expect(confirm.displayError, isNull);
    });

    test('pure input keeps the given password', () {
      const confirm = ConfirmPassword.pure(password: 'secret1');

      expect(confirm.password, 'secret1');
      expect(confirm.isPure, isTrue);
    });

    test('empty value reports ConfirmPasswordEmpty before match check', () {
      const confirm = ConfirmPassword.dirty(password: 'secret1', value: '');

      expect(confirm.error, isA<ConfirmPasswordEmpty>());
      expect(confirm.isValid, isFalse);
    });

    test('mismatching value reports ConfirmPasswordDoNotMatch', () {
      const confirm = ConfirmPassword.dirty(
        password: 'secret1',
        value: 'secret2',
      );

      expect(confirm.error, isA<ConfirmPasswordDoNotMatch>());
      expect(confirm.isValid, isFalse);
    });

    test('matching value is valid', () {
      const confirm = ConfirmPassword.dirty(
        password: 'secret1',
        value: 'secret1',
      );

      expect(confirm.error, isNull);
      expect(confirm.isValid, isTrue);
    });

    test('comparison is case sensitive', () {
      const confirm = ConfirmPassword.dirty(
        password: 'Secret1',
        value: 'secret1',
      );

      expect(confirm.error, isA<ConfirmPasswordDoNotMatch>());
    });
  });
}
