import 'package:formz/formz.dart';

import '../../../app/app.dart';

class GenderValueObject extends FormzInput<String, ValueObjectFailure> {
  const GenderValueObject.pure() : super.pure('');
  const GenderValueObject.dirty(super.value) : super.dirty();

  @override
  ValueObjectFailure? validator(String value) {
    if (value.isEmpty) {
      return GenderEmpty();
    }

    return null;
  }
}

sealed class GenderValueObjectFailure implements ValueObjectFailure {}

class GenderEmpty extends GenderValueObjectFailure {}
