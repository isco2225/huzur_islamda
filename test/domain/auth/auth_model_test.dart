import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Auth.fromJson', () {
    test('maps every field from json', () {
      final auth = Auth.fromJson({
        'uid': 'uid-9',
        'email': 'a@b.com',
        'isEmailVerified': true,
      });

      expect(auth.uid, 'uid-9');
      expect(auth.email, 'a@b.com');
      expect(auth.isEmailVerified, isTrue);
    });

    test('throws when a required field is missing', () {
      expect(
        () => Auth.fromJson({'uid': 'uid-9', 'email': 'a@b.com'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when a field has the wrong type', () {
      expect(
        () => Auth.fromJson({
          'uid': 1,
          'email': 'a@b.com',
          'isEmailVerified': true,
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Auth.empty', () {
    test('has blank identifiers and an unverified email', () {
      final auth = Auth.empty();

      expect(auth.uid, isEmpty);
      expect(auth.email, isEmpty);
      expect(auth.isEmailVerified, isFalse);
    });
  });

  group('Auth.toJson', () {
    test('serializes every field under its camelCase key', () {
      final json = Fixtures.auth(
        uid: 'u',
        email: 'e@x.io',
        isEmailVerified: false,
      ).toJson();

      expect(json, {'uid': 'u', 'email': 'e@x.io', 'isEmailVerified': false});
    });

    test('round-trips through fromJson', () {
      final original = Fixtures.auth();

      final restored = Auth.fromJson(original.toJson());

      expect(restored.uid, original.uid);
      expect(restored.email, original.email);
      expect(restored.isEmailVerified, original.isEmailVerified);
    });
  });

  group('Auth.copyWith', () {
    test('overrides only the given fields', () {
      final original = Fixtures.auth();

      final copy = original.copyWith(email: 'new@x.io');

      expect(copy.email, 'new@x.io');
      expect(copy.uid, original.uid);
      expect(copy.isEmailVerified, original.isEmailVerified);
    });

    test('returns an equivalent copy when nothing is given', () {
      final original = Fixtures.auth();

      final copy = original.copyWith();

      expect(copy.uid, original.uid);
      expect(copy.email, original.email);
      expect(copy.isEmailVerified, original.isEmailVerified);
    });
  });

  group('Auth.isSignedIn', () {
    test('returns true for an auth with a uid', () {
      expect(Fixtures.auth().isSignedIn(), isTrue);
    });

    test(
      'returns false for an empty auth built at runtime',
      () {
        // A runtime-built empty auth (e.g. parsed from json) is not identical
        // to the canonical const `Auth.empty()` instance.
        final auth = Auth.fromJson({
          'uid': '',
          'email': '',
          'isEmailVerified': false,
        });

        expect(auth.isSignedIn(), isFalse);
      },
    );

    test('returns false for the canonical empty auth', () {
      expect(Auth.empty().isSignedIn(), isFalse);
    });
  });
}
