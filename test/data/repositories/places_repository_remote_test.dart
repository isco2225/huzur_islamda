import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';

void main() {
  late FakePlaceSelectorService service;
  late PlacesRepositoryRemote repository;

  const countries = [
    Country(id: '1', name: 'KUZEY KIBRIS'),
    Country(id: '2', name: 'TÜRKİYE'),
  ];

  setUp(() {
    service = FakePlaceSelectorService();
    repository = PlacesRepositoryRemote(placeSelectorService: service);
  });

  group('getCountries', () {
    test('starts with an empty notifier', () {
      expect(repository.countries.value, isEmpty);
    });

    test('loads the countries into the notifier', () async {
      service.countriesResult = const Ok(countries);

      final result = await repository.getCountries();

      expect(result, isA<Ok<void>>());
      expect(repository.countries.value, same(countries));
      expect(service.getCountriesCount, 1);
    });

    test('is memoized: a second call does not hit the service', () async {
      service.countriesResult = const Ok(countries);
      await repository.getCountries();
      service.countriesResult = const Ok([Country(id: '9', name: 'OTHER')]);

      final result = await repository.getCountries();

      expect(result, isA<Ok<void>>());
      expect(service.getCountriesCount, 1);
      expect(repository.countries.value.map((c) => c.name), [
        'KUZEY KIBRIS',
        'TÜRKİYE',
      ]);
    });

    test('propagates a service error and keeps the notifier empty', () async {
      final failure = Exception('Failed to get countries: missing asset');
      service.countriesResult = Result.error(failure);

      final result = await repository.getCountries();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
      expect(repository.countries.value, isEmpty);
    });

    test('retries the service after a failure (nothing was memoized)', () async {
      service.countriesResult = Result.error(Exception('x'));
      await repository.getCountries();
      service.countriesResult = const Ok(countries);

      await repository.getCountries();

      expect(service.getCountriesCount, 2);
      expect(repository.countries.value, same(countries));
    });

    test('an empty successful result is not memoized', () async {
      service.countriesResult = const Ok(<Country>[]);
      await repository.getCountries();
      await repository.getCountries();

      expect(service.getCountriesCount, 2);
    });
  });

  group('getStates', () {
    test('passes the country id and the result through', () async {
      const states = [StateModel(id: '500', name: 'ADANA')];
      service.statesResult = const Ok(states);

      final result = await repository.getStates('2');

      expect(result, isA<Ok<List<StateModel>>>());
      expect(result.asOk.value, same(states));
      expect(service.requestedCountryIds, ['2']);
    });

    test('propagates a service error', () async {
      final failure = Exception('x');
      service.statesResult = Result.error(failure);

      final result = await repository.getStates('2');

      expect(result, isA<Error<List<StateModel>>>());
      expect(result.asError.error, same(failure));
    });
  });

  group('getDistricts', () {
    test('passes the state id and the result through', () async {
      const districts = [District(id: '17914', name: 'BAF')];
      service.districtsResult = const Ok(districts);

      final result = await repository.getDistricts('751');

      expect(result, isA<Ok<List<District>>>());
      expect(result.asOk.value, same(districts));
      expect(service.requestedStateIds, ['751']);
    });

    test('propagates a service error', () async {
      final failure = Exception('x');
      service.districtsResult = Result.error(failure);

      final result = await repository.getDistricts('751');

      expect(result, isA<Error<List<District>>>());
      expect(result.asError.error, same(failure));
    });
  });
}
