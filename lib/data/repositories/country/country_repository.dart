import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class CountryRepository {
  ValueListenable<List<Country>> get countries;
  Future<Result<void>> getCountries();
}
