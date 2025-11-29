import 'package:formz/formz.dart';

import '../../../app/app.dart';

class Password extends FormzInput<String, ValueObjectFailure> {
  const Password.pure() : super.pure('');
  const Password.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return PasswordEmpty();
    } else if (value.length < 6) {
      return PasswordWeak();
    } else if (value.length > 64) {
      return PasswordTooLong();
    }
    return null;
  }
}

sealed class PasswordValueObjectFailure implements ValueObjectFailure {}


class PasswordEmpty extends PasswordValueObjectFailure {}

class PasswordWeak extends PasswordValueObjectFailure {}

class PasswordTooLong extends PasswordValueObjectFailure {}
