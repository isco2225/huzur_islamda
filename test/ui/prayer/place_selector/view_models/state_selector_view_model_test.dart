import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const istanbul = StateModel(id: '34', name: 'İstanbul');
  const ankara = StateModel(id: '06', name: 'Ankara');

  late FakePlacesRepository placesRepository;
  late StateSelectorViewModel viewModel;

  setUp(() {
    placesRepository = FakePlacesRepository()
      ..getStatesResult = const Ok([istanbul, ankara]);
    viewModel = StateSelectorViewModel(placesRepository: placesRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts with no states', () {
    expect(viewModel.states.value, isEmpty);
    expect(viewModel.filteredStates.value, isEmpty);
    expect(viewModel.items, same(viewModel.states));
  });

  group('getStates', () {
    test('passes the country id through and populates the items', () async {
      await viewModel.getStates.execute('tr');

      expect(placesRepository.calls, ['getStates(countryId=tr)']);
      expect(viewModel.states.value, [istanbul, ankara]);
      expect(viewModel.filteredStates.value, [istanbul, ankara]);
      expect(viewModel.getStates.completed.value, isTrue);
    });

    test('applies the current query to the newly loaded states', () async {
      viewModel.searchQuery.value = 'an';

      await viewModel.getStates.execute('tr');

      expect(viewModel.filteredStates.value, [ankara]);
    });

    test('propagates a repository error and leaves the list untouched', () async {
      final exception = Exception('http');
      placesRepository.getStatesResult = Error<List<StateModel>>(exception);

      await viewModel.getStates.execute('tr');

      expect(viewModel.getStates.error.value, isTrue);
      expect(viewModel.getStates.result.value!.asError.error, same(exception));
      expect(viewModel.states.value, isEmpty);
    });
  });

  group('selectState / getSelectedStateName', () {
    test('selectState stores the id', () async {
      await viewModel.selectState.execute('34');

      expect(viewModel.selectedStateId.value, '34');
    });

    test('returns the selected name, or empty when unknown or unselected', () async {
      await viewModel.getStates.execute('tr');
      expect(viewModel.getSelectedStateName(), '');

      await viewModel.selectState.execute('06');
      expect(viewModel.getSelectedStateName(), 'Ankara');

      await viewModel.selectState.execute('99');
      expect(viewModel.getSelectedStateName(), '');
    });
  });
}
