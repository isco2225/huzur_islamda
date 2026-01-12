import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/data.dart';
import 'country_selector_view_model.dart';
import 'district_selector_view_model.dart';
import 'state_selector_view_model.dart';

/// Main coordinator ViewModel for place selection
/// Manages CountrySelectorViewModel, StateSelectorViewModel, and DistrictSelectorViewModel
/// This ViewModel will be used for filtering and future API requests
class PlaceSelectorViewModel {
  PlaceSelectorViewModel({required PlacesRepository placesRepository}) {
    // Initialize sub-ViewModels
    _countrySelector = CountrySelectorViewModel(
      placesRepository: placesRepository,
    );
    _stateSelector = StateSelectorViewModel(placesRepository: placesRepository);
    _districtSelector = DistrictSelectorViewModel(
      placesRepository: placesRepository,
    );

    // Listen to country selection to load states
    _countrySelector.selectedCountryId.addListener(_onCountrySelectionChanged);
    // Listen to state selection to load districts
    _stateSelector.selectedStateId.addListener(_onStateSelectionChanged);
  }

  // LOGGER
  final _log = Logger('PlaceSelectorViewModel');

  // SUB-VIEWMODELS
  late final CountrySelectorViewModel _countrySelector;
  late final StateSelectorViewModel _stateSelector;
  late final DistrictSelectorViewModel _districtSelector;

  // GETTERS for sub-ViewModels
  CountrySelectorViewModel get countrySelector => _countrySelector;
  StateSelectorViewModel get stateSelector => _stateSelector;
  DistrictSelectorViewModel get districtSelector => _districtSelector;

  /// Current selection mode (viewing countries or states)
  ValueNotifier<PlaceSelectionMode> get selectionMode => _selectionMode;
  final ValueNotifier<PlaceSelectionMode> _selectionMode =
      ValueNotifier<PlaceSelectionMode>(PlaceSelectionMode.country);

  // DISPOSE
  void dispose() {
    _countrySelector.selectedCountryId.removeListener(
      _onCountrySelectionChanged,
    );
    _stateSelector.selectedStateId.removeListener(_onStateSelectionChanged);
    _countrySelector.dispose();
    _stateSelector.dispose();
    _districtSelector.dispose();
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

  /// Called when state selection changes
  void _onStateSelectionChanged() {
    final selectedStateId = _stateSelector.selectedStateId.value;
    if (selectedStateId != null) {
      // Switch to district selection mode
      _selectionMode.value = PlaceSelectionMode.district;
      // Load districts for selected state
      _districtSelector.getDistricts.execute(selectedStateId);
      _log.fine(
        'Switched to district selection mode for state: $selectedStateId',
      );
    }
  }

  /// Go back one step (district -> state -> country)
  void goBack() {
    switch (_selectionMode.value) {
      case PlaceSelectionMode.district:
        // Go back to state selection
        _selectionMode.value = PlaceSelectionMode.state;
        _districtSelector.resetSelection();
        _stateSelector.resetSelection();
        _log.fine('Back to state selection mode');
        break;
      case PlaceSelectionMode.state:
        // Go back to country selection
        _selectionMode.value = PlaceSelectionMode.country;
        _stateSelector.resetSelection();
        _countrySelector.resetSelection();
        _log.fine('Back to country selection mode');
        break;
      case PlaceSelectionMode.country:
        // Already at first step, do nothing
        _log.fine('Already at country selection mode');
        break;
    }
  }

  /// Reset all selections and go back to country selection
  void resetAllSelections() {
    _countrySelector.resetSelection();
    _stateSelector.resetSelection();
    _districtSelector.resetSelection();
    _selectionMode.value = PlaceSelectionMode.country;
    _log.fine('All selections reset');
  }

  /// Get currently selected place name (district, state, or country)
  String? getSelectedPlaceName() {
    // Priority: district > state > country
    if (_selectionMode.value == PlaceSelectionMode.district) {
      final districtId = _districtSelector.selectedDistrictId.value;
      if (districtId != null) {
        final district = _districtSelector.districts.value.firstWhere(
          (d) => d.id == districtId,
        );
        return district.name;
      }
    }

    if (_selectionMode.value == PlaceSelectionMode.state ||
        _selectionMode.value == PlaceSelectionMode.district) {
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

  /// Check if a place is fully selected (district selected)
  bool isPlaceFullySelected() {
    return _districtSelector.selectedDistrictId.value != null;
  }

  /// Get full place hierarchy (Country > State > District)
  String? getFullPlaceHierarchy() {
    final parts = <String>[];

    final countryId = _countrySelector.selectedCountryId.value;
    if (countryId != null) {
      final country = _countrySelector.countries.value.firstWhere(
        (c) => c.id == countryId,
      );
      parts.add(country.name);
    }

    final stateId = _stateSelector.selectedStateId.value;
    if (stateId != null) {
      final state = _stateSelector.states.value.firstWhere(
        (s) => s.id == stateId,
      );
      parts.add(state.name);
    }

    final districtId = _districtSelector.selectedDistrictId.value;
    if (districtId != null) {
      final district = _districtSelector.districts.value.firstWhere(
        (d) => d.id == districtId,
      );
      parts.add(district.name);
    }

    return parts.isEmpty ? null : parts.join(' > ');
  }
}

/// Selection mode enum
enum PlaceSelectionMode { country, state, district }
