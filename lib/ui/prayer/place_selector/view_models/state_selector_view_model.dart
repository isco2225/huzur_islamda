import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

/// ViewModel for state/city selection and filtering
class StateSelectorViewModel {
  StateSelectorViewModel({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository {
    // DEFINE COMMANDS
    getStates = Command1<void, String>(_getStates, debugLabel: 'getStates');
    selectState = Command1<void, String>(
      _selectState,
      debugLabel: 'selectState',
    );

    // DEFINE LISTENERS
    _states.addListener(_filterStates);
    _searchQuery.addListener(_filterStates);

    // Initial filter
    _filterStates();
  }

  // LOGGER
  final _log = Logger('StateSelectorViewModel');

  // REPOSITORIES
  final PlacesRepository _placesRepository;

  // DOMAIN
  ValueListenable<List<StateModel>> get states => _states;
  final ValueNotifier<List<StateModel>> _states =
      ValueNotifier<List<StateModel>>([]);

  /// Search query for filtering states
  ValueNotifier<String> get searchQuery => _searchQuery;
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  /// Filtered states based on search query
  ValueListenable<List<StateModel>> get filteredStates => _filteredStates;
  final ValueNotifier<List<StateModel>> _filteredStates =
      ValueNotifier<List<StateModel>>([]);

  /// Selected state ID
  ValueNotifier<String?> get selectedStateId => _selectedStateId;
  final ValueNotifier<String?> _selectedStateId = ValueNotifier<String?>(null);

  // COMMANDS
  late final Command1<void, String> getStates;
  late final Command1<void, String> selectState;

  // DISPOSE
  void dispose() {
    _states.removeListener(_filterStates);
    _searchQuery.removeListener(_filterStates);
    _searchQuery.dispose();
    _filteredStates.dispose();
    _states.dispose();
    _selectedStateId.dispose();
    getStates.dispose();
    selectState.dispose();
    _log.fine('StateSelectorViewModel Disposed');
  }

  // FUNCTIONS

  /// Get states for a specific country
  Future<Result<void>> _getStates(String countryId) async {
    try {
      _log.fine('Getting states for country: $countryId');
      final result = await _placesRepository.getStates(countryId);
      switch (result) {
        case Ok():
          _states.value = result.asOk.value;
          _log.fine('${result.asOk.value.length} states fetched successfully');
          return Result.ok(null);
        case Error():
          _log.severe('Failed to get states: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Exception while getting states: $e');
      return Result.error(Exception('Failed to get states: $e'));
    }
  }

  /// Select a state by ID
  Future<Result<void>> _selectState(String stateId) async {
    _selectedStateId.value = stateId;
    _log.fine('State selected: $stateId');
    return Result.ok(null);
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

  /// Reset selection and states
  void resetSelection() {
    _selectedStateId.value = null;
    _searchQuery.value = '';
  }
}
