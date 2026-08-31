import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Loads the real `assets/data/places/*.json` files through `rootBundle`
/// (`flutter test` serves the assets declared in pubspec.yaml).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlaceSelectorService service;

  setUp(() {
    service = PlaceSelectorService();
  });

  group('PlaceSelectorService.getCountries', () {
    test('loads a non-empty country list that contains TÜRKİYE', () async {
      final result = await service.getCountries();

      expect(result, isA<Ok<List<Country>>>());
      final countries = result.asOk.value;
      expect(countries, isNotEmpty);
      final turkey = countries.firstWhere((c) => c.name == 'TÜRKİYE');
      expect(turkey.id, '2');
    });

    test('every country has a non-empty id and name', () async {
      final countries = (await service.getCountries()).asOk.value;

      for (final country in countries) {
        expect(country.id, isNotEmpty);
        expect(country.name, isNotEmpty);
      }
    });
  });

  group('PlaceSelectorService.getStates', () {
    test('returns the states of TÜRKİYE', () async {
      final result = await service.getStates('2');

      expect(result, isA<Ok<List<StateModel>>>());
      final states = result.asOk.value;
      expect(states, isNotEmpty);
      expect(states.map((s) => s.name), contains('ADANA'));
      expect(states.map((s) => s.name), contains('İSTANBUL'));
    });

    test('returns Ok([]) for an unknown country id', () async {
      final result = await service.getStates('does-not-exist');

      expect(result, isA<Ok<List<StateModel>>>());
      expect(result.asOk.value, isEmpty);
    });
  });

  group('PlaceSelectorService.getDistricts', () {
    test('returns the districts of a known state', () async {
      // State 751 is KUZEY KIBRIS (first entry in states.json).
      final result = await service.getDistricts('751');

      expect(result, isA<Ok<List<District>>>());
      final districts = result.asOk.value;
      expect(districts, isNotEmpty);
      expect(districts.map((d) => d.name), contains('BAF'));
    });

    test('districts of a state resolved from the state list are non-empty', () async {
      final states = (await service.getStates('2')).asOk.value;
      final istanbul = states.firstWhere((s) => s.name == 'İSTANBUL');

      final districts = (await service.getDistricts(istanbul.id)).asOk.value;

      expect(districts, isNotEmpty);
      for (final district in districts) {
        expect(district.id, isNotEmpty);
        expect(district.name, isNotEmpty);
      }
    });

    test('returns Ok([]) for an unknown state id', () async {
      final result = await service.getDistricts('does-not-exist');

      expect(result, isA<Ok<List<District>>>());
      expect(result.asOk.value, isEmpty);
    });
  });
}
