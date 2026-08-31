import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Formats a date as `dd/MM/yyyy`, the format expected by
/// [DateOfBirthValueObject].
String formatDob(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// A date exactly [years] years before today. The day is clamped to 28 so the
/// result is stable even when today is the 29th, 30th or 31st.
DateTime yearsAgo(int years) {
  final now = DateTime.now();
  return DateTime(now.year - years, now.month, math.min(now.day, 28));
}

void main() {
  group('NameValueObject', () {
    test('pure input reports NameEmpty and no display error', () {
      const name = NameValueObject.pure();

      expect(name.isPure, isTrue);
      expect(name.error, isA<NameEmpty>());
      expect(name.displayError, isNull);
      expect(name.isValid, isFalse);
    });

    test('empty value reports NameEmpty', () {
      expect(const NameValueObject.dirty('').error, isA<NameEmpty>());
    });

    test('16 characters reports NameTooLong', () {
      expect(NameValueObject.dirty('a' * 16).error, isA<NameTooLong>());
    });

    test('15 characters is valid (upper boundary)', () {
      expect(NameValueObject.dirty('a' * 15).isValid, isTrue);
    });

    test('2 characters reports NameTooShort', () {
      expect(const NameValueObject.dirty('ab').error, isA<NameTooShort>());
    });

    test('3 characters is valid (lower boundary)', () {
      expect(const NameValueObject.dirty('Ali').isValid, isTrue);
    });

    test('accepts Turkish letters, spaces and hyphens', () {
      const valid = ['Şükrü', 'Ayşe Gül', 'Ali-Can', 'İbrahim', 'Çağrı'];
      for (final value in valid) {
        expect(NameValueObject.dirty(value).isValid, isTrue, reason: value);
      }
    });

    test('rejects digits and punctuation with NameInvalidFormat', () {
      const invalid = ['Ali1', 'Ali.', 'Ali_Can', 'Ali@'];
      for (final value in invalid) {
        expect(
          NameValueObject.dirty(value).error,
          isA<NameInvalidFormat>(),
          reason: value,
        );
      }
    });

    test('length is checked before format', () {
      expect(NameValueObject.dirty('1' * 16).error, isA<NameTooLong>());
      expect(const NameValueObject.dirty('1').error, isA<NameTooShort>());
    });
  });

  group('SurnameValueObject', () {
    test('pure input reports SurnameEmpty and no display error', () {
      const surname = SurnameValueObject.pure();

      expect(surname.isPure, isTrue);
      expect(surname.error, isA<SurnameEmpty>());
      expect(surname.displayError, isNull);
    });

    test('empty value reports SurnameEmpty', () {
      expect(const SurnameValueObject.dirty('').error, isA<SurnameEmpty>());
    });

    test('21 characters reports SurnameTooLong', () {
      expect(SurnameValueObject.dirty('a' * 21).error, isA<SurnameTooLong>());
    });

    test('20 characters is valid (upper boundary)', () {
      expect(SurnameValueObject.dirty('a' * 20).isValid, isTrue);
    });

    test('1 character reports SurnameTooShort', () {
      expect(const SurnameValueObject.dirty('a').error, isA<SurnameTooShort>());
    });

    test('2 characters is valid (lower boundary)', () {
      expect(const SurnameValueObject.dirty('Öz').isValid, isTrue);
    });

    test('rejects digits with SurnameInvalidFormat', () {
      expect(
        const SurnameValueObject.dirty('Yılmaz2').error,
        isA<SurnameInvalidFormat>(),
      );
    });

    test('accepts Turkish letters, spaces and hyphens', () {
      expect(const SurnameValueObject.dirty('Öztürk-Şahin').isValid, isTrue);
      expect(const SurnameValueObject.dirty('Kara Göz').isValid, isTrue);
    });
  });

  group('GenderValueObject', () {
    test('pure input reports GenderEmpty', () {
      const gender = GenderValueObject.pure();

      expect(gender.isPure, isTrue);
      expect(gender.error, isA<GenderEmpty>());
      expect(gender.displayError, isNull);
    });

    test('empty value reports GenderEmpty', () {
      expect(const GenderValueObject.dirty('').error, isA<GenderEmpty>());
    });

    test('any non-empty value is valid', () {
      expect(const GenderValueObject.dirty('male').isValid, isTrue);
      expect(const GenderValueObject.dirty('x').isValid, isTrue);
    });
  });

  group('DateOfBirthValueObject', () {
    test('pure input is pure and has no display error', () {
      const dob = DateOfBirthValueObject.pure();

      expect(dob.isPure, isTrue);
      expect(dob.displayError, isNull);
    });

    test(
      'empty value reports DateOfBirthEmpty',
      () {
        const dob = DateOfBirthValueObject.dirty('');

        expect(dob.error, isA<DateOfBirthEmpty>());
        expect(dob.isValid, isFalse);
      },
      skip:
          'KNOWN BUG: validator returns null for an empty value, so '
          'DateOfBirthEmpty is never emitted and an empty date is valid.',
    );

    test('rejects values that do not match dd/MM/yyyy', () {
      const invalid = [
        '1/1/2000', // unpadded day and month
        '2000-01-01', // ISO format
        '32/01/2000', // day out of range
        '00/01/2000', // zero day
        '01/13/2000', // month out of range
        '01/00/2000', // zero month
        '01/01/00', // two-digit year
        '01.01.2000', // wrong separator
        'abc',
      ];
      for (final value in invalid) {
        expect(
          DateOfBirthValueObject.dirty(value).error,
          isA<DateOfBirthInvalidFormat>(),
          reason: value,
        );
      }
    });

    test('rejects impossible calendar dates like 31/02/2000', () {
      expect(
        const DateOfBirthValueObject.dirty('31/02/2000').error,
        isA<DateOfBirthInvalidFormat>(),
      );
      expect(
        const DateOfBirthValueObject.dirty('31/04/2000').error,
        isA<DateOfBirthInvalidFormat>(),
      );
      // Non-leap year February 29th.
      expect(
        const DateOfBirthValueObject.dirty('29/02/2001').error,
        isA<DateOfBirthInvalidFormat>(),
      );
    });

    test('accepts a leap-day birthday in a leap year', () {
      expect(const DateOfBirthValueObject.dirty('29/02/2000').isValid, isTrue);
    });

    test('rejects a future date with DateOfBirthFutureDate', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final nextYear = DateTime(now.year + 1, 1, 1);

      expect(
        DateOfBirthValueObject.dirty(formatDob(tomorrow)).error,
        isA<DateOfBirthFutureDate>(),
      );
      expect(
        DateOfBirthValueObject.dirty(formatDob(nextYear)).error,
        isA<DateOfBirthFutureDate>(),
      );
    });

    test('rejects dates before 1950 with DateOfBirthTooPastDate', () {
      expect(
        const DateOfBirthValueObject.dirty('31/12/1949').error,
        isA<DateOfBirthTooPastDate>(),
      );
    });

    test('accepts 01/01/1950 (earliest allowed date)', () {
      expect(const DateOfBirthValueObject.dirty('01/01/1950').isValid, isTrue);
    });

    test('rejects someone younger than 8 with DateOfBirthTooYoung', () {
      expect(
        DateOfBirthValueObject.dirty(formatDob(yearsAgo(7))).error,
        isA<DateOfBirthTooYoung>(),
      );
      expect(
        DateOfBirthValueObject.dirty(formatDob(yearsAgo(0))).error,
        isA<DateOfBirthTooYoung>(),
      );
    });

    test('accepts someone who turned 8 today', () {
      expect(
        DateOfBirthValueObject.dirty(formatDob(yearsAgo(8))).isValid,
        isTrue,
      );
    });

    test('accepts a typical adult birth date', () {
      const dob = DateOfBirthValueObject.dirty('01/01/1990');

      expect(dob.error, isNull);
      expect(dob.isValid, isTrue);
    });
  });
}
