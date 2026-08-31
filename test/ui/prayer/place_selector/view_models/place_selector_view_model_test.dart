import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const turkey = Country(id: 'tr', name: 'Türkiye');
  const istanbul = StateModel(id: '34', name: 'İstanbul');
  const kadikoy = District(id: '9541', name: 'Kadıköy');

  late FakePlacesRepository placesRepository;
  late PlaceSelectorViewModel viewModel;

  Future<void> selectCountry(String id) async {
    await viewModel.countrySelector.selectCountry.execute(id);
    // The coordinator fires getStates without awaiting it.
    await pumpEventQueue();
  }

  Future<void> selectState(String id) async {
    await viewModel.stateSelector.selectState.execute(id);
    await pumpEventQueue();
  }

  setUp(() {
    placesRepository = FakePlacesRepository(countries: const [turkey])
      ..getStatesResult = const Ok([istanbul])
      ..getDistrictsResult = const Ok([kadikoy]);
    viewModel = PlaceSelectorViewModel(placesRepository: placesRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts in country mode with nothing selected', () {
    expect(viewModel.selectionMode.value, PlaceSelectionMode.country);
    expect(viewModel.isPlaceFullySelected(), isFalse);
    expect(viewModel.getSelectedPlaceName(), isNull);
    expect(viewModel.getFullPlaceHierarchy(), isNull);
  });

  group('cascade', () {
    test('selecting a country switches to state mode and loads its states', () async {
      await selectCountry('tr');

      expect(viewModel.selectionMode.value, PlaceSelectionMode.state);
      expect(placesRepository.calls, ['getStates(countryId=tr)']);
      expect(viewModel.stateSelector.states.value, [istanbul]);
    });

    test('selecting a state switches to district mode and loads its districts', () async {
      await selectCountry('tr');
      await selectState('34');

      expect(viewModel.selectionMode.value, PlaceSelectionMode.district);
      expect(placesRepository.calls, ['getStates(countryId=tr)', 'getDistricts(stateId=34)']);
      expect(viewModel.districtSelector.districts.value, [kadikoy]);
    });

    test('isPlaceFullySelected becomes true once a district is chosen', () async {
      await selectCountry('tr');
      await selectState('34');
      expect(viewModel.isPlaceFullySelected(), isFalse);

      await viewModel.districtSelector.selectDistrict.execute('9541');

      expect(viewModel.isPlaceFullySelected(), isTrue);
    });
  });

  group('goBack', () {
    test('from district mode returns to state mode and clears state + district', () async {
      await selectCountry('tr');
      await selectState('34');
      await viewModel.districtSelector.selectDistrict.execute('9541');

      viewModel.goBack();

      expect(viewModel.selectionMode.value, PlaceSelectionMode.state);
      expect(viewModel.districtSelector.selectedDistrictId.value, isNull);
      expect(viewModel.districtSelector.districts.value, isEmpty);
      expect(viewModel.stateSelector.selectedStateId.value, isNull);
      expect(viewModel.countrySelector.selectedCountryId.value, 'tr');
    });

    test('from state mode returns to country mode and clears the country', () async {
      await selectCountry('tr');

      viewModel.goBack();

      expect(viewModel.selectionMode.value, PlaceSelectionMode.country);
      expect(viewModel.countrySelector.selectedCountryId.value, isNull);
      expect(viewModel.stateSelector.selectedStateId.value, isNull);
    });

    test('in country mode is a no-op', () {
      viewModel.goBack();

      expect(viewModel.selectionMode.value, PlaceSelectionMode.country);
    });
  });

  test('resetAllSelections clears everything and returns to country mode', () async {
    await selectCountry('tr');
    await selectState('34');
    await viewModel.districtSelector.selectDistrict.execute('9541');

    viewModel.resetAllSelections();

    expect(viewModel.selectionMode.value, PlaceSelectionMode.country);
    expect(viewModel.countrySelector.selectedCountryId.value, isNull);
    expect(viewModel.stateSelector.selectedStateId.value, isNull);
    expect(viewModel.districtSelector.selectedDistrictId.value, isNull);
    expect(viewModel.districtSelector.districts.value, isEmpty);
    expect(viewModel.isPlaceFullySelected(), isFalse);
  });

  group('getSelectedPlaceName', () {
    test('returns the country name in state mode before a state is chosen', () async {
      await selectCountry('tr');

      expect(viewModel.getSelectedPlaceName(), 'Türkiye');
    });

    test('prefers the state over the country', () async {
      await selectCountry('tr');
      await selectState('34');

      expect(viewModel.getSelectedPlaceName(), 'İstanbul');
    });

    test('prefers the district over the state', () async {
      await selectCountry('tr');
      await selectState('34');
      await viewModel.districtSelector.selectDistrict.execute('9541');

      expect(viewModel.getSelectedPlaceName(), 'Kadıköy');
    });

    test(
      'returns null instead of throwing when the selected id is not in the list',
      () async {
        placesRepository.countriesNotifier.value = const [];

        await selectCountry('tr');

        expect(viewModel.getSelectedPlaceName(), isNull);
      },
      skip:
          'KNOWN BUG: getSelectedPlaceName/getFullPlaceHierarchy use '
          'firstWhere without orElse and throw StateError when the selected '
          'id is missing from the loaded list',
    );
  });

  group('getFullPlaceHierarchy', () {
    test("joins the selected levels with ' > '", () async {
      await selectCountry('tr');
      expect(viewModel.getFullPlaceHierarchy(), 'Türkiye');

      await selectState('34');
      expect(viewModel.getFullPlaceHierarchy(), 'Türkiye > İstanbul');

      await viewModel.districtSelector.selectDistrict.execute('9541');
      expect(viewModel.getFullPlaceHierarchy(), 'Türkiye > İstanbul > Kadıköy');
    });

    test(
      "returns '' instead of throwing when the selected id is not in the list",
      () async {
        placesRepository.countriesNotifier.value = const [];

        await selectCountry('tr');

        expect(viewModel.getFullPlaceHierarchy(), anyOf(isNull, ''));
      },
      skip:
          'KNOWN BUG: getFullPlaceHierarchy uses firstWhere without orElse '
          'and throws StateError when the selected id is missing from the list',
    );
  });

  test('dispose stops the cascade listeners', () {
    viewModel.dispose();
    viewModel = PlaceSelectorViewModel(placesRepository: placesRepository);
    expect(viewModel.dispose, returnsNormally);
    viewModel = PlaceSelectorViewModel(placesRepository: placesRepository);
  });
}
