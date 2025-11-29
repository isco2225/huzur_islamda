import 'package:formz/formz.dart';

import '../../../app/app.dart';

class NameValueObject extends FormzInput<String, ValueObjectFailure> {
  const NameValueObject.pure() : super.pure('');
  const NameValueObject.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return NameEmpty();
    }
    if (value.length > 15) {
      return NameTooLong();
    }
    if (value.length < 3) {
      return NameTooShort();
    }
    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\-]+$').hasMatch(value)) {
      return NameInvalidFormat();
    }
    return null;
  }
}

sealed class NameValueObjectFailure implements ValueObjectFailure {}

class NameEmpty extends NameValueObjectFailure {}

class NameTooLong extends NameValueObjectFailure {}

class NameTooShort extends NameValueObjectFailure {}

class NameInvalidFormat extends NameValueObjectFailure {}
