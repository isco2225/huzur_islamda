import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const turkey = Country(id: 'tr', name: 'Türkiye');
  const germany = Country(id: 'de', name: 'Almanya');

  late FakePlacesRepository placesRepository;
  late CountrySelectorViewModel viewModel;

  setUp(() {
    placesRepository = FakePlacesRepository(countries: const [turkey, germany]);
    viewModel = CountrySelectorViewModel(placesRepository: placesRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('items and countries are the repository listenable', () {
    expect(viewModel.items, same(placesRepository.countriesNotifier));
    expect(viewModel.countries, same(placesRepository.countriesNotifier));
    expect(viewModel.filteredCountries.value, [turkey, germany]);
  });

  test('re-filters when the repository publishes new countries', () {
    viewModel.searchQuery.value = 'al';
    expect(viewModel.filteredCountries.value, [germany]);

    placesRepository.countriesNotifier.value = const [
      turkey,
      Country(id: 'al', name: 'Alaska'),
    ];

    expect(viewModel.filteredCountries.value.map((c) => c.id), ['al']);
  });

  group('getCountries', () {
    test('delegates to the repository and completes on Ok', () async {
      await viewModel.getCountries.execute();

      expect(placesRepository.calls, ['getCountries()']);
      expect(viewModel.getCountries.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('http');
      placesRepository.getCountriesResult = Error<void>(exception);

      await viewModel.getCountries.execute();

      expect(viewModel.getCountries.error.value, isTrue);
      expect(viewModel.getCountries.result.value!.asError.error, same(exception));
    });
  });

  group('selectCountry / getSelectedCountryName', () {
    test('selectCountry stores the id', () async {
      await viewModel.selectCountry.execute('de');

      expect(viewModel.selectedCountryId.value, 'de');
      expect(viewModel.selectCountry.completed.value, isTrue);
    });

    test('returns the selected name, or empty when unknown or unselected', () async {
      expect(viewModel.getSelectedCountryName(), '');

      await viewModel.selectCountry.execute('tr');
      expect(viewModel.getSelectedCountryName(), 'Türkiye');

      await viewModel.selectCountry.execute('xx');
      expect(viewModel.getSelectedCountryName(), '');
    });
  });
}
