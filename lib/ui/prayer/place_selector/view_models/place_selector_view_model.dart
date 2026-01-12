import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PlaceSelectorViewModel {
  PlaceSelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository {
    // DEFINE COMMANDS

    //country commands
    getCountries = Command0<void>(_getCountries, debugLabel: 'getCountries');
    selectCountry = Command1<void, String>(
      _selectCountry,
      debugLabel: 'selectCountry',
    );
    //state commands
    getStates = Command1<void, String>(_getStates, debugLabel: 'getStates');
    selectState = Command1<void, String>(
      _selectState,
      debugLabel: 'selectState',
    );
    // DEFINE LISTENERS
    countries.addListener(_filterCountries);
    _states.addListener(_filterStates);
    _searchQuery.addListener(_onSearchQueryChanged);

    // Initial filter
    _filterCountries();
  }
  // LOGGER
  final _log = Logger('PlaceSelectorViewModel');

  // REPOSITORIES & USE CASES
  final PlacesRepository _placesRepository;

  // DOMAIN
  ValueListenable<List<Country>> get countries => _placesRepository.countries;
  ValueListenable<List<StateModel>> get states => _states;
  final ValueNotifier<List<StateModel>> _states =
      ValueNotifier<List<StateModel>>([]);

  /// Filtered countries based on search query
  ValueListenable<List<Country>> get filteredCountries => _filteredCountries;
  final ValueNotifier<List<Country>> _filteredCountries =
      ValueNotifier<List<Country>>([]);

  /// Filtered states based on search query
  ValueListenable<List<StateModel>> get filteredStates => _filteredStates;
  final ValueNotifier<List<StateModel>> _filteredStates =
      ValueNotifier<List<StateModel>>([]);

  ValueNotifier<String> get searchQuery => _searchQuery;
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  ValueNotifier<String?> get selectedCountryId => _selectedCountryId;
  final ValueNotifier<String?> _selectedCountryId = ValueNotifier<String?>(
    null,
  );
  ValueNotifier<String?> get selectedStateId => _selectedStateId;
  final ValueNotifier<String?> _selectedStateId = ValueNotifier<String?>(null);
  // COMMANDS
  late final Command0<void> getCountries;
  late final Command1<void, String> selectCountry;
  late final Command1<void, String> getStates;
  late final Command1<void, String> selectState;
  // DISPOSE
  void dispose() {
    countries.removeListener(_filterCountries);
    _states.removeListener(_filterStates);
    _searchQuery.removeListener(_onSearchQueryChanged);
    _searchQuery.dispose();
    _filteredCountries.dispose();
    _filteredStates.dispose();
    _states.dispose();
    selectedCountryId.dispose();
    selectedStateId.dispose();
    getCountries.dispose();
    selectCountry.dispose();
    getStates.dispose();
    selectState.dispose();
    _log.fine('PlaceSelectorViewModel Disposed');
  }

  // FUNCTIONS

  /// Get countries
  Future<Result<void>> _getCountries() async {
    try {
      _log.fine('Getting countries fonksiyoınu çalıştı');
      final result = await _placesRepository.getCountries();
      switch (result) {
        case Ok():
          _log.fine('Countries fetched successfully');
          return Result.ok(null);
        case Error():
          _log.severe('Failed to get countries: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get countries: $e'));
    }
  }

  /// Select country
  Future<Result<void>> _selectCountry(String selectedCountryId) async {
    _selectedCountryId.value = selectedCountryId;
    _log.fine('Country selected: $selectedCountryId');
    return Result.ok(null);
  }

  /// Select state
  Future<Result<void>> _selectState(String selectedStateId) async {
    _selectedStateId.value = selectedStateId;
    _log.fine('State selected: $selectedStateId');
    return Result.ok(null);
  }

  /// Get states
  Future<Result<void>> _getStates(String selectedCountryId) async {
    final result = await _placesRepository.getStates(selectedCountryId);
    switch (result) {
      case Ok():
        _states.value = result.asOk.value;
        _log.fine('${result.asOk.value.length} states fetched successfully');
        return Result.ok(null);
      case Error():
        _log.severe('Failed to get states: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }

  /// Called when search query changes - filter based on selected view
  void _onSearchQueryChanged() {
    if (_selectedCountryId.value == null) {
      _filterCountries();
    } else {
      _filterStates();
    }
  }

  /// Filter countries based on search query
  void _filterCountries() {
    final query = _searchQuery.value.toLowerCase().trim();
    final allCountries = countries.value;

    if (query.isEmpty) {
      _filteredCountries.value = allCountries;
    } else {
      _filteredCountries.value = allCountries
          .where((country) => country.name.toLowerCase().startsWith(query))
          .toList();
    }

    _log.fine(
      'Filtered ${_filteredCountries.value.length} countries with query: "$query"',
    );
  }

  /// Filter states based on search query
  void _filterStates() {
    final query = _searchQuery.value.toLowerCase().trim();
    final allStates = _states.value;

    if (query.isEmpty) {
      _filteredStates.value = allStates;
    } else {
      _filteredStates.value = allStates
          .where((state) => state.name.toLowerCase().startsWith(query))
          .toList();
    }

    _log.fine(
      'Filtered ${_filteredStates.value.length} states with query: "$query"',
    );
  }
}
