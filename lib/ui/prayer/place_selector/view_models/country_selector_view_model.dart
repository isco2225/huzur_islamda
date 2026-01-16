import 'package:flutter/foundation.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import 'base_selector_view_model.dart';

/// ViewModel for country selection and filtering
class CountrySelectorViewModel extends BaseSelectorViewModel<Country> {
  CountrySelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository,
      super(loggerName: 'CountrySelectorViewModel') {
    // DEFINE COMMANDS
    getCountries = Command0<void>(_getCountries, debugLabel: 'getCountries');
    selectCountry = Command1<void, String>(
      _selectCountry,
      debugLabel: 'selectCountry',
    );

    // DEFINE LISTENERS
    countries.addListener(filterItems);
  }

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  @override
  ValueListenable<List<Country>> get items => _placesRepository.countries;

  /// Countries from repository
  ValueListenable<List<Country>> get countries => _placesRepository.countries;

  /// Filtered countries based on search query
  ValueListenable<List<Country>> get filteredCountries => filteredItems;

  /// Selected country ID
  ValueNotifier<String?> get selectedCountryId => selectedId;

  /// Get selected country name (returns empty string if not found)
  String getSelectedCountryName() {
    final countryId = selectedCountryId.value;
    if (countryId == null) return '';
    try {
      final country = countries.value.firstWhere(
        (c) => c.id == countryId,
        orElse: () => Country(id: '', name: ''),
      );
      return country.name;
    } catch (e) {
      return '';
    }
  }

  // COMMANDS
  late final Command0<void> getCountries;
  late final Command1<void, String> selectCountry;

  // DISPOSE
  @override
  void dispose() {
    countries.removeListener(filterItems);
    getCountries.dispose();
    selectCountry.dispose();
    super.dispose();
  }

  // FUNCTIONS

  /// Get countries from repository
  Future<Result<void>> _getCountries() async {
    try {
      log.fine('Getting countries');
      final result = await _placesRepository.getCountries();
      switch (result) {
        case Ok():
          log.fine('Countries fetched successfully');
          return Result.ok(null);
        case Error():
          log.severe('Failed to get countries: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      log.severe('Exception while getting countries: $e');
      return Result.error(Exception('Failed to get countries: $e'));
    }
  }

  /// Select a country by ID
  Future<Result<void>> _selectCountry(String countryId) async {
    return selectItem(countryId);
  }
}
