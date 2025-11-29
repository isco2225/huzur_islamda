import 'package:formz/formz.dart';

import '../../../app/app.dart';

class MaritalStatusValueObject extends FormzInput<String, ValueObjectFailure> {
  const MaritalStatusValueObject.pure() : super.pure('');
  const MaritalStatusValueObject.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return MaritalStatusEmpty();
    }
    return null;
  }
}

sealed class MaritalStatusValueObjectFailure implements ValueObjectFailure {}

class MaritalStatusEmpty extends MaritalStatusValueObjectFailure {}
