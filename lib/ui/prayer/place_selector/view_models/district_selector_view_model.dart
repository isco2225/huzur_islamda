import 'package:flutter/foundation.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import 'base_selector_view_model.dart';

/// ViewModel for district selection and filtering
class DistrictSelectorViewModel extends BaseSelectorViewModel<District> {
  DistrictSelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository,
      super(loggerName: 'DistrictSelectorViewModel') {
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
    _districts.addListener(filterItems);
  }

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  @override
  ValueListenable<List<District>> get items => _districts;
  final ValueNotifier<List<District>> _districts =
      ValueNotifier<List<District>>([]);

  /// Districts list
  ValueListenable<List<District>> get districts => _districts;

  /// Filtered districts based on search query
  ValueListenable<List<District>> get filteredDistricts => filteredItems;

  /// Selected district ID
  ValueNotifier<String?> get selectedDistrictId => selectedId;

  // COMMANDS
  late final Command1<void, String> getDistricts;
  late final Command1<void, String> selectDistrict;

  // DISPOSE
  @override
  void dispose() {
    _districts.removeListener(filterItems);
    _districts.dispose();
    getDistricts.dispose();
    selectDistrict.dispose();
    super.dispose();
  }

  // FUNCTIONS

  /// Get districts for a specific state
  Future<Result<void>> _getDistricts(String stateId) async {
    try {
      log.fine('Getting districts for state: $stateId');
      final result = await _placesRepository.getDistricts(stateId);
      switch (result) {
        case Ok():
          _districts.value = result.asOk.value;
          log.fine(
            '${result.asOk.value.length} districts fetched successfully',
          );
          return Result.ok(null);
        case Error():
          log.severe('Failed to get districts: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      log.severe('Exception while getting districts: $e');
      return Result.error(Exception('Failed to get districts: $e'));
    }
  }

  /// Select a district by ID
  Future<Result<void>> _selectDistrict(String districtId) async {
    return selectItem(districtId);
  }

  /// Reset selection and districts
  @override
  void resetSelection() {
    super.resetSelection();
    _districts.value = [];
  }
}
