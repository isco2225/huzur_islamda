import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  const json = {'_id': '42', 'name': 'Türkiye'};

  group('Country.fromJson', () {
    test('reads _id and name', () {
      final country = Country.fromJson(json);

      expect(country.id, '42');
      expect(country.name, 'Türkiye');
    });

    test('throws when _id is missing', () {
      expect(
        () => Country.fromJson({'name': 'Türkiye'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('does not accept a plain "id" key', () {
      expect(
        () => Country.fromJson({'id': '42', 'name': 'Türkiye'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('StateModel.fromJson', () {
    test('reads _id and name', () {
      final state = StateModel.fromJson(json);

      expect(state.id, '42');
      expect(state.name, 'Türkiye');
    });

    test('throws when name is missing', () {
      expect(
        () => StateModel.fromJson({'_id': '42'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('District.fromJson', () {
    test('reads _id and name', () {
      final district = District.fromJson(json);

      expect(district.id, '42');
      expect(district.name, 'Türkiye');
    });

    test('throws when _id has the wrong type', () {
      expect(
        () => District.fromJson({'_id': 42, 'name': 'x'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
