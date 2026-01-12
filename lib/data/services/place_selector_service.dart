import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../../app/app.dart';
import '../../domain/domain.dart';

class PlaceSelectorService {
  final _log = Logger('PlaceSelectorService');

  static const String _countriesJsonPath = 'assets/data/places/countries.json';
  static const String _statesJsonPath = 'assets/data/places/states.json';
  static const String _districtsJsonPath = 'assets/data/places/districts.json';

  Future<Result<List<Country>>> getCountries() async {
    try {
      _log.info('Getting countries...');

      final countriesJson = await rootBundle.loadString(_countriesJsonPath);
      final jsonCountries = jsonDecode(countriesJson) as List<dynamic>;
      final List<Country> countries = jsonCountries
          .map((e) => Country.fromJson(e))
          .toList();
      _log.info('${countries.length} countries successfully loaded');
      return Result.ok(countries);
    } catch (e) {
      return Result.error(Exception('Failed to get countries: $e'));
    }
  }

  Future<Result<List<StateModel>>> getStates(String countryId) async {
    try {
      _log.info('Getting states for country: $countryId');
      final statesJson = await rootBundle.loadString(_statesJsonPath);
      final jsonStates = jsonDecode(statesJson) as List<dynamic>;
      final filteredStates = jsonStates
          .map((e) => e as Map<String, dynamic>)
          .where((e) => e['country_id'] == countryId)
          .map((e) => StateModel.fromJson(e))
          .toList();
      _log.info('${filteredStates.length} states successfully loaded');
      return Result.ok(filteredStates);
    } catch (e) {
      return Result.error(Exception('Failed to get states: $e'));
    }
  }

  Future<Result<List<District>>> getDistricts(String stateId) async {
    try {
      _log.info('Getting districts for state: $stateId');
      final districtsJson = await rootBundle.loadString(_districtsJsonPath);
      final jsonDistricts = jsonDecode(districtsJson) as List<dynamic>;
      final filteredDistricts = jsonDistricts
          .map((e) => e as Map<String, dynamic>)
          .where((e) => e['state_id'] == stateId)
          .map((e) => District.fromJson(e))
          .toList();
      _log.info('${filteredDistricts.length} districts successfully loaded');
      return Result.ok(filteredDistricts);
    } catch (e) {
      return Result.error(Exception('Failed to get districts: $e'));
    }
  }
}
