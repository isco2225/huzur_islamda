import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class PlacesRepository {
  ValueListenable<List<Country>> get countries;
  Future<Result<void>> getCountries();
  Future<Result<List<StateModel>>> getStates(String countryId);
  Future<Result<List<District>>> getDistricts(String stateId);
}
