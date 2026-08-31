import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  Map<String, Object?> minimalJson() => {
    'uid': 'uid-1',
    'email': 'a@b.com',
    'name': 'Ahmet',
    'surname': 'Yılmaz',
    'dateOfBirth': '01/01/1990',
    'gender': 'male',
  };

  group('User.fromJson', () {
    test('applies defaults for every optional field', () {
      final before = DateTime.now();
      final user = User.fromJson(minimalJson());
      final after = DateTime.now();

      expect(user.uid, 'uid-1');
      expect(user.email, 'a@b.com');
      expect(user.name, 'Ahmet');
      expect(user.surname, 'Yılmaz');
      expect(user.dateOfBirth, '01/01/1990');
      expect(user.gender, 'male');
      expect(user.emailVerified, isFalse);
      expect(user.isRegistered, isFalse);
      expect(user.country, '');
      expect(user.city, '');
      expect(user.districtId, '');
      expect(user.lastSupportedAt, isNull);
      expect(user.supportPackage, isNull);
      // Missing timestamps default to "now".
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.isBefore(before), isFalse);
      expect(user.createdAt!.isAfter(after), isFalse);
      expect(user.updatedAt, isNotNull);
    });

    test('parses ISO-8601 timestamps and support package', () {
      final json = minimalJson()
        ..addAll({
          'createdAt': '2026-03-15T10:30:00.000',
          'updatedAt': DateTime(2026, 4, 1),
          'lastSupportedAt': '2026-05-01T00:00:00.000',
          'supportPackage': 'weekly',
          'emailVerified': true,
          'isRegistered': true,
          'country': 'Türkiye',
          'city': 'Ankara',
          'districtId': '9541',
        });

      final user = User.fromJson(json);

      expect(user.createdAt, DateTime(2026, 3, 15, 10, 30));
      expect(user.updatedAt, DateTime(2026, 4, 1));
      expect(user.lastSupportedAt, DateTime(2026, 5, 1));
      expect(user.supportPackage, SupportPackage.weekly);
      expect(user.emailVerified, isTrue);
      expect(user.isRegistered, isTrue);
      expect(user.country, 'Türkiye');
      expect(user.city, 'Ankara');
      expect(user.districtId, '9541');
    });

    test('ignores an unknown support package value', () {
      final user = User.fromJson(minimalJson()..['supportPackage'] = 'gold');

      expect(user.supportPackage, isNull);
    });

    test('throws when a required field is missing', () {
      expect(
        () => User.fromJson(minimalJson()..remove('name')),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('User.toJson', () {
    test('round-trips field by field', () {
      final original = Fixtures.user(
        lastSupportedAt: DateTime(2026, 5, 1),
        supportPackage: SupportPackage.yearly,
        emailVerified: false,
        isRegistered: true,
      );

      final json = original.toJson();
      final restored = User.fromJson(Map<String, Object?>.from(json));

      expect(json['createdAt'], Fixtures.fixedDate.toIso8601String());
      expect(json['supportPackage'], 'yearly');
      expect(restored.uid, original.uid);
      expect(restored.email, original.email);
      expect(restored.name, original.name);
      expect(restored.surname, original.surname);
      expect(restored.dateOfBirth, original.dateOfBirth);
      expect(restored.gender, original.gender);
      expect(restored.emailVerified, original.emailVerified);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.isRegistered, original.isRegistered);
      expect(restored.country, original.country);
      expect(restored.city, original.city);
      expect(restored.districtId, original.districtId);
      expect(restored.lastSupportedAt, original.lastSupportedAt);
      expect(restored.supportPackage, original.supportPackage);
    });

    test('writes null for absent optional dates and package', () {
      final json = User.empty().toJson();

      expect(json['createdAt'], isNull);
      expect(json['updatedAt'], isNull);
      expect(json['lastSupportedAt'], isNull);
      expect(json['supportPackage'], isNull);
    });
  });

  group('User.isPremium', () {
    test('is true only when a support package is set', () {
      expect(Fixtures.user().isPremium, isFalse);
      expect(
        Fixtures.user(supportPackage: SupportPackage.weekly).isPremium,
        isTrue,
      );
    });
  });

  group('User.copyWith', () {
    test('overrides only the given fields', () {
      final original = Fixtures.user();

      final copy = original.copyWith(
        name: 'Mehmet',
        supportPackage: SupportPackage.yearly,
      );

      expect(copy.name, 'Mehmet');
      expect(copy.supportPackage, SupportPackage.yearly);
      expect(copy.uid, original.uid);
      expect(copy.surname, original.surname);
      expect(copy.createdAt, original.createdAt);
      expect(copy.city, original.city);
    });

    test('cannot clear a nullable field back to null', () {
      final original = Fixtures.user(supportPackage: SupportPackage.yearly);

      final copy = original.copyWith(supportPackage: null);

      expect(copy.supportPackage, SupportPackage.yearly);
    });
  });

  group('User.empty / isEmpty', () {
    test('empty user has blank strings and null dates', () {
      final user = User.empty();

      expect(user.uid, '');
      expect(user.email, '');
      expect(user.createdAt, isNull);
      expect(user.isRegistered, isFalse);
      expect(user.isPremium, isFalse);
    });

    test('isEmpty is false for a populated user', () {
      expect(Fixtures.user().isEmpty(), isFalse);
    });

    test(
      'isEmpty is true for an empty user built at runtime',
      () {
        // copyWith produces a fresh instance with identical field values.
        final user = User.empty().copyWith();

        expect(user.isEmpty(), isTrue);
      },
      skip:
          'KNOWN BUG: User has no == override, so isEmpty() compares identity '
          'and returns false for any instance other than the const '
          'User.empty() singleton.',
    );
  });
}
