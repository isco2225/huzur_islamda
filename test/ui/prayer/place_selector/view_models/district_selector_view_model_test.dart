import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const kadikoy = District(id: '9541', name: 'Kadıköy');
  const besiktas = District(id: '9530', name: 'Beşiktaş');

  late FakePlacesRepository placesRepository;
  late DistrictSelectorViewModel viewModel;

  setUp(() {
    placesRepository = FakePlacesRepository()
      ..getDistrictsResult = const Ok([kadikoy, besiktas]);
    viewModel = DistrictSelectorViewModel(placesRepository: placesRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts with no districts', () {
    expect(viewModel.districts.value, isEmpty);
    expect(viewModel.filteredDistricts.value, isEmpty);
    expect(viewModel.items, same(viewModel.districts));
  });

  group('getDistricts', () {
    test('passes the state id through and populates the items', () async {
      await viewModel.getDistricts.execute('34');

      expect(placesRepository.calls, ['getDistricts(stateId=34)']);
      expect(viewModel.districts.value, [kadikoy, besiktas]);
      expect(viewModel.filteredDistricts.value, [kadikoy, besiktas]);
      expect(viewModel.getDistricts.completed.value, isTrue);
    });

    test('propagates a repository error and leaves the list untouched', () async {
      final exception = Exception('http');
      placesRepository.getDistrictsResult = Error<List<District>>(exception);

      await viewModel.getDistricts.execute('34');

      expect(viewModel.getDistricts.error.value, isTrue);
      expect(viewModel.getDistricts.result.value!.asError.error, same(exception));
      expect(viewModel.districts.value, isEmpty);
    });
  });

  test('selectDistrict stores the id', () async {
    await viewModel.selectDistrict.execute('9541');

    expect(viewModel.selectedDistrictId.value, '9541');
  });

  test('resetSelection clears the selection, the query and the district list', () async {
    await viewModel.getDistricts.execute('34');
    await viewModel.selectDistrict.execute('9541');
    viewModel.searchQuery.value = 'ka';

    viewModel.resetSelection();

    expect(viewModel.selectedDistrictId.value, isNull);
    expect(viewModel.searchQuery.value, '');
    expect(viewModel.districts.value, isEmpty);
    expect(viewModel.filteredDistricts.value, isEmpty);
  });
}
