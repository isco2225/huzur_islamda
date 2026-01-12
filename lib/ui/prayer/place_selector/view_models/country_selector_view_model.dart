import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

/// ViewModel for country selection and filtering
class CountrySelectorViewModel {
  CountrySelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository {
    // DEFINE COMMANDS
    getCountries = Command0<void>(_getCountries, debugLabel: 'getCountries');
    selectCountry = Command1<void, String>(
      _selectCountry,
      debugLabel: 'selectCountry',
    );

    // DEFINE LISTENERS
    countries.addListener(_filterCountries);
    _searchQuery.addListener(_filterCountries);

    // Initial filter
    _filterCountries();
  }

  // LOGGER
  final _log = Logger('CountrySelectorViewModel');

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  ValueListenable<List<Country>> get countries => _placesRepository.countries;

  /// Search query for filtering countries
  ValueNotifier<String> get searchQuery => _searchQuery;
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  /// Filtered countries based on search query
  ValueListenable<List<Country>> get filteredCountries => _filteredCountries;
  final ValueNotifier<List<Country>> _filteredCountries =
      ValueNotifier<List<Country>>([]);

  /// Selected country ID
  ValueNotifier<String?> get selectedCountryId => _selectedCountryId;
  final ValueNotifier<String?> _selectedCountryId = ValueNotifier<String?>(
    null,
  );

  // COMMANDS
  late final Command0<void> getCountries;
  late final Command1<void, String> selectCountry;

  // DISPOSE
  void dispose() {
    countries.removeListener(_filterCountries);
    _searchQuery.removeListener(_filterCountries);
    _searchQuery.dispose();
    _filteredCountries.dispose();
    _selectedCountryId.dispose();
    getCountries.dispose();
    selectCountry.dispose();
    _log.fine('CountrySelectorViewModel Disposed');
  }

  // FUNCTIONS

  /// Get countries from repository
  Future<Result<void>> _getCountries() async {
    try {
      _log.fine('Getting countries');
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
      _log.severe('Exception while getting countries: $e');
      return Result.error(Exception('Failed to get countries: $e'));
    }
  }

  /// Select a country by ID
  Future<Result<void>> _selectCountry(String countryId) async {
    _selectedCountryId.value = countryId;
    _log.fine('Country selected: $countryId');
    return Result.ok(null);
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

  /// Reset selection
  void resetSelection() {
    _selectedCountryId.value = null;
    _searchQuery.value = '';
  }
}
