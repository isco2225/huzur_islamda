import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

/// ViewModel for district selection and filtering
class DistrictSelectorViewModel {
  DistrictSelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository {
    // DEFINE COMMANDS
    getDistricts = Command1<void, String>(
      _getDistricts,
      debugLabel: 'getDistricts',
    );
    selectDistrict = Command1<void, String>(
      _selectDistrict,
      debugLabel: 'selectDistrict',
    );

    // DEFINE LISTENERS
    _districts.addListener(_filterDistricts);
    _searchQuery.addListener(_filterDistricts);

    // Initial filter
    _filterDistricts();
  }

  // LOGGER
  final _log = Logger('DistrictSelectorViewModel');

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  ValueListenable<List<District>> get districts => _districts;
  final ValueNotifier<List<District>> _districts =
      ValueNotifier<List<District>>([]);

  /// Search query for filtering districts
  ValueNotifier<String> get searchQuery => _searchQuery;
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  /// Filtered districts based on search query
  ValueListenable<List<District>> get filteredDistricts => _filteredDistricts;
  final ValueNotifier<List<District>> _filteredDistricts =
      ValueNotifier<List<District>>([]);

  /// Selected district ID
  ValueNotifier<String?> get selectedDistrictId => _selectedDistrictId;
  final ValueNotifier<String?> _selectedDistrictId = ValueNotifier<String?>(
    null,
  );

  // COMMANDS
  late final Command1<void, String> getDistricts;
  late final Command1<void, String> selectDistrict;

  // DISPOSE
  void dispose() {
    _districts.removeListener(_filterDistricts);
    _searchQuery.removeListener(_filterDistricts);
    _searchQuery.dispose();
    _filteredDistricts.dispose();
    _districts.dispose();
    _selectedDistrictId.dispose();
    getDistricts.dispose();
    selectDistrict.dispose();
    _log.fine('DistrictSelectorViewModel Disposed');
  }

  // FUNCTIONS

  /// Get districts for a specific state
  Future<Result<void>> _getDistricts(String stateId) async {
    try {
      _log.fine('Getting districts for state: $stateId');
      final result = await _placesRepository.getDistricts(stateId);
      switch (result) {
        case Ok():
          _districts.value = result.asOk.value;
          _log.fine(
            '${result.asOk.value.length} districts fetched successfully',
          );
          return Result.ok(null);
        case Error():
          _log.severe('Failed to get districts: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Exception while getting districts: $e');
      return Result.error(Exception('Failed to get districts: $e'));
    }
  }

  /// Select a district by ID
  Future<Result<void>> _selectDistrict(String districtId) async {
    _selectedDistrictId.value = districtId;
    _log.fine('District selected: $districtId');
    return Result.ok(null);
  }

  /// Filter districts based on search query
  void _filterDistricts() {
    final query = _searchQuery.value.toLowerCase().trim();
    final allDistricts = _districts.value;

    if (query.isEmpty) {
      _filteredDistricts.value = allDistricts;
    } else {
      _filteredDistricts.value = allDistricts
          .where((district) => district.name.toLowerCase().startsWith(query))
          .toList();
    }

    _log.fine(
      'Filtered ${_filteredDistricts.value.length} districts with query: "$query"',
    );
  }

  /// Reset selection and districts
  void resetSelection() {
    _selectedDistrictId.value = null;
    _districts.value = [];
    _searchQuery.value = '';
  }
}
