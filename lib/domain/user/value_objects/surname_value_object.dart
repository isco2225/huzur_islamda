import 'package:formz/formz.dart';
import '../../../app/app.dart';

class SurnameValueObject extends FormzInput<String, ValueObjectFailure> {
  const SurnameValueObject.pure() : super.pure('');
  const SurnameValueObject.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return SurnameEmpty();
    }
    if (value.length > 20) {
      return SurnameTooLong();
    }
    if (value.length < 2) {
      return SurnameTooShort();
    }
    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\-]+$').hasMatch(value)) {
      return SurnameInvalidFormat();
    }
    return null;
  }
}

sealed class SurnameValueObjectFailure implements ValueObjectFailure {}

class SurnameEmpty extends SurnameValueObjectFailure {}

class SurnameTooLong extends SurnameValueObjectFailure {}

class SurnameTooShort extends SurnameValueObjectFailure {}

class SurnameInvalidFormat extends SurnameValueObjectFailure {}
