import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/data.dart';
import 'country_selector_view_model.dart';
import 'state_selector_view_model.dart';

/// Main coordinator ViewModel for place selection
/// Manages CountrySelectorViewModel and StateSelectorViewModel
/// This ViewModel will be used for filtering and future API requests
class PlaceSelectorViewModel {
  PlaceSelectorViewModel({required PlacesRepository placesRepository}) {
    // Initialize sub-ViewModels
    _countrySelector = CountrySelectorViewModel(
      placesRepository: placesRepository,
    );
    _stateSelector = StateSelectorViewModel(placesRepository: placesRepository);

    // Listen to country selection to load states
    _countrySelector.selectedCountryId.addListener(_onCountrySelectionChanged);
  }

  // LOGGER
  final _log = Logger('PlaceSelectorViewModel');

  // SUB-VIEWMODELS
  late final CountrySelectorViewModel _countrySelector;
  late final StateSelectorViewModel _stateSelector;

  // GETTERS for sub-ViewModels
  CountrySelectorViewModel get countrySelector => _countrySelector;
  StateSelectorViewModel get stateSelector => _stateSelector;

  /// Current selection mode (viewing countries or states)
  ValueNotifier<PlaceSelectionMode> get selectionMode => _selectionMode;
  final ValueNotifier<PlaceSelectionMode> _selectionMode =
      ValueNotifier<PlaceSelectionMode>(PlaceSelectionMode.country);

  // DISPOSE
  void dispose() {
    _countrySelector.selectedCountryId.removeListener(
      _onCountrySelectionChanged,
    );
    _countrySelector.dispose();
    _stateSelector.dispose();
    _selectionMode.dispose();
    _log.fine('PlaceSelectorViewModel Disposed');
  }

  // FUNCTIONS

  /// Called when country selection changes
  void _onCountrySelectionChanged() {
    final selectedCountryId = _countrySelector.selectedCountryId.value;
    if (selectedCountryId != null) {
      // Switch to state selection mode
      _selectionMode.value = PlaceSelectionMode.state;
      // Load states for selected country
      _stateSelector.getStates.execute(selectedCountryId);
      _log.fine(
        'Switched to state selection mode for country: $selectedCountryId',
      );
    }
  }

  /// Go back to country selection
  void backToCountrySelection() {
    _countrySelector.resetSelection();
    _selectionMode.value = PlaceSelectionMode.country;
    _stateSelector.resetSelection();
    _log.fine('Back to country selection mode');
  }

  /// Reset all selections and go back to country selection
  void resetAllSelections() {
    _countrySelector.resetSelection();
    _stateSelector.resetSelection();
    _selectionMode.value = PlaceSelectionMode.country;
    _log.fine('All selections reset');
  }

  /// Get currently selected place name (country or state)
  String? getSelectedPlaceName() {
    if (_selectionMode.value == PlaceSelectionMode.state) {
      final stateId = _stateSelector.selectedStateId.value;
      if (stateId != null) {
        final state = _stateSelector.states.value.firstWhere(
          (s) => s.id == stateId,
        );
        return state.name;
      }
    }

    final countryId = _countrySelector.selectedCountryId.value;
    if (countryId != null) {
      final country = _countrySelector.countries.value.firstWhere(
        (c) => c.id == countryId,
      );
      return country.name;
    }

    return null;
  }

  /// Check if a place is fully selected (state selected or country without states)
  bool isPlaceFullySelected() {
    if (_selectionMode.value == PlaceSelectionMode.state) {
      return _stateSelector.selectedStateId.value != null;
    }
    return _countrySelector.selectedCountryId.value != null;
  }
}

/// Selection mode enum
enum PlaceSelectionMode { country, state, district }
