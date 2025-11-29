import 'package:formz/formz.dart';

import '../../../app/app.dart';

class Email extends FormzInput<String, ValueObjectFailure> {
  const Email.pure() : super.pure('');
  const Email.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (value.isEmpty) {
      return EmailEmpty();
    } else if (!emailRegExp.hasMatch(value)) {
      return EmailInvalid();
    }
    return null;
  }
}

sealed class EmailValueObjectFailure implements ValueObjectFailure {}

class EmailEmpty extends EmailValueObjectFailure {}

class EmailInvalid extends EmailValueObjectFailure {}
