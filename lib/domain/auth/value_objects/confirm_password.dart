import 'package:formz/formz.dart';

import '../../../app/app.dart';

class ConfirmPassword
    extends FormzInput<String, ConfirmPasswordValueObjectFailure> {
  const ConfirmPassword.pure({this.password = ''}) : super.pure('');
  const ConfirmPassword.dirty({required this.password, required String value})
      : super.dirty(value);

  final String password;

  @override
  ConfirmPasswordValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return ConfirmPasswordEmpty();
    }
    if (password != value) {
      return ConfirmPasswordDoNotMatch();
    }
    return null;
  }
}

sealed class ConfirmPasswordValueObjectFailure implements ValueObjectFailure {}

class ConfirmPasswordEmpty extends ConfirmPasswordValueObjectFailure {}

class ConfirmPasswordDoNotMatch extends ConfirmPasswordValueObjectFailure {}
