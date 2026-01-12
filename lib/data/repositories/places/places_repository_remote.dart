import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../data.dart';

class PlacesRepositoryRemote extends PlacesRepository {
  PlacesRepositoryRemote({required PlaceSelectorService placeSelectorService})
    : _placeSelectorService = placeSelectorService;

  final PlaceSelectorService _placeSelectorService;

  @override
  ValueListenable<List<Country>> get countries => _countries;
  final ValueNotifier<List<Country>> _countries = ValueNotifier<List<Country>>(
    [],
  );

  @override
  Future<Result<void>> getCountries() async {
    try {
      if (_countries.value.isNotEmpty) {
        print('Countries fetched from cache');
        return Result.ok(null);
      }
      final result = await _placeSelectorService.getCountries();
      switch (result) {
        case Ok():
          _countries.value = result.asOk.value;
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get countries: $e'));
    }
  }

  @override
  Future<Result<List<StateModel>>> getStates(String countryId) async {
    try {
      final result = await _placeSelectorService.getStates(countryId);
      switch (result) {
        case Ok():
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get states: $e'));
    }
  }

  @override
  Future<Result<List<District>>> getDistricts(String stateId) async {
    try {
      final result = await _placeSelectorService.getDistricts(stateId);
      switch (result) {
        case Ok():
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get districts: $e'));
    }
  }
}
