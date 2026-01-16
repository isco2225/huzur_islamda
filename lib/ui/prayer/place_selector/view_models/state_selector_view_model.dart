import 'package:flutter/foundation.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import 'base_selector_view_model.dart';

/// ViewModel for state/city selection and filtering
class StateSelectorViewModel extends BaseSelectorViewModel<StateModel> {
  StateSelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository,
      super(loggerName: 'StateSelectorViewModel') {
    // DEFINE COMMANDS
    getStates = Command1<void, String>(_getStates, debugLabel: 'getStates');
    selectState = Command1<void, String>(
      _selectState,
      debugLabel: 'selectState',
    );

    // DEFINE LISTENERS
    _states.addListener(filterItems);
  }

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  @override
  ValueListenable<List<StateModel>> get items => _states;
  final ValueNotifier<List<StateModel>> _states =
      ValueNotifier<List<StateModel>>([]);

  /// States list
  ValueListenable<List<StateModel>> get states => _states;

  /// Filtered states based on search query
  ValueListenable<List<StateModel>> get filteredStates => filteredItems;

  /// Selected state ID
  ValueNotifier<String?> get selectedStateId => selectedId;

  /// Get selected state name (returns empty string if not found)
  String getSelectedStateName() {
    final stateId = selectedStateId.value;
    if (stateId == null) return '';
    try {
      final state = states.value.firstWhere(
        (s) => s.id == stateId,
        orElse: () => StateModel(id: '', name: ''),
      );
      return state.name;
    } catch (e) {
      return '';
    }
  }

  // COMMANDS
  late final Command1<void, String> getStates;
  late final Command1<void, String> selectState;

  // DISPOSE
  @override
  void dispose() {
    _states.removeListener(filterItems);
    _states.dispose();
    getStates.dispose();
    selectState.dispose();
    super.dispose();
  }

  // FUNCTIONS

  /// Get states for a specific country
  Future<Result<void>> _getStates(String countryId) async {
    try {
      log.fine('Getting states for country: $countryId');
      final result = await _placesRepository.getStates(countryId);
      switch (result) {
        case Ok():
          _states.value = result.asOk.value;
          log.fine('${result.asOk.value.length} states fetched successfully');
          return Result.ok(null);
        case Error():
          log.severe('Failed to get states: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      log.severe('Exception while getting states: $e');
      return Result.error(Exception('Failed to get states: $e'));
    }
  }

  /// Select a state by ID
  Future<Result<void>> _selectState(String stateId) async {
    return selectItem(stateId);
  }
}
