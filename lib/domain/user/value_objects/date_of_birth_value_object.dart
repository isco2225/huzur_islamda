import 'package:formz/formz.dart';

import '../../../app/app.dart';
import '../../domain.dart';

class DateOfBirthValueObject extends FormzInput<String, ValueObjectFailure> {
  const DateOfBirthValueObject.pure() : super.pure('');
  const DateOfBirthValueObject.dirty(super.value) : super.dirty();

  static const int _minimumAge = 8;

  static final DateTime _earliestDate = DateTime(1950, 1, 1);

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return DateOfBirthEmpty();
    }
    // Format control: GG/AA/YYYY
    if (!RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$',
    ).hasMatch(value)) {
      return DateOfBirthInvalidFormat();
    }

    // Parse GG/AA/YYYY format
    final date = _parseDate(value);
    if (date == null) {
      return DateOfBirthInvalidFormat();
    }

    // Future date control
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return DateOfBirthFutureDate();
    }
    // Too past date control
    if (date.isBefore(_earliestDate)) {
      return DateOfBirthTooPastDate();
    }
    // Too young control
    if (UserAgeCalculater(dateOfBirth: date).calculateAge() < _minimumAge) {
      return DateOfBirthTooYoung();
    }
    return null;
  }

  /// Convert GG/AA/YYYY format to DateTime
  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Valid date control
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return null;
      }

      return date;
    } catch (e) {
      return null;
    }
  }
}

sealed class DateOfBirthValueObjectFailure implements ValueObjectFailure {}

class DateOfBirthEmpty extends DateOfBirthValueObjectFailure {}

class DateOfBirthInvalidFormat extends DateOfBirthValueObjectFailure {}

class DateOfBirthFutureDate extends DateOfBirthValueObjectFailure {}

class DateOfBirthTooPastDate extends DateOfBirthValueObjectFailure {}

class DateOfBirthTooYoung extends DateOfBirthValueObjectFailure {}
