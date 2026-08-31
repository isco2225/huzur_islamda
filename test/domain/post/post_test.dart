import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Post.fromJson', () {
    test('applies defaults when every field is missing', () {
      final before = DateTime.now();
      final post = Post.fromJson({});
      final after = DateTime.now();

      expect(post.id, '');
      expect(post.title, '');
      expect(post.contentType, ContentType.dua);
      expect(post.arabicContent, isNull);
      expect(post.content, '');
      expect(post.source, '');
      expect(post.isActive, isFalse);
      expect(post.createdAt.isBefore(before), isFalse);
      expect(post.createdAt.isAfter(after), isFalse);
    });

    test('parses "kuran" and "hadis" content types', () {
      expect(
        Post.fromJson({'contentType': 'kuran'}).contentType,
        ContentType.kuran,
      );
      expect(
        Post.fromJson({'contentType': 'hadis'}).contentType,
        ContentType.hadis,
      );
      expect(
        Post.fromJson({'contentType': 'dua'}).contentType,
        ContentType.dua,
      );
    });

    test('falls back to dua for unknown, null or non-string content types', () {
      expect(
        Post.fromJson({'contentType': 'unknown'}).contentType,
        ContentType.dua,
      );
      expect(Post.fromJson({'contentType': null}).contentType, ContentType.dua);
      expect(Post.fromJson({'contentType': 42}).contentType, ContentType.dua);
    });

    test('accepts a ContentType instance directly', () {
      expect(
        Post.fromJson({'contentType': ContentType.hadis}).contentType,
        ContentType.hadis,
      );
    });

    test('parses ISO strings and DateTime instances for createdAt', () {
      expect(
        Post.fromJson({'createdAt': '2026-03-15T10:30:00.000'}).createdAt,
        DateTime(2026, 3, 15, 10, 30),
      );
      expect(
        Post.fromJson({'createdAt': DateTime(2026, 1, 1)}).createdAt,
        DateTime(2026, 1, 1),
      );
    });

    test('keeps a null arabicContent as null', () {
      expect(Post.fromJson({'arabicContent': null}).arabicContent, isNull);
    });

    test('reads all provided fields', () {
      final post = Post.fromJson({
        'id': 'p-1',
        'title': 'T',
        'contentType': 'hadis',
        'arabicContent': 'ar',
        'content': 'c',
        'source': 's',
        'isActive': true,
      });

      expect(post.id, 'p-1');
      expect(post.title, 'T');
      expect(post.arabicContent, 'ar');
      expect(post.content, 'c');
      expect(post.source, 's');
      expect(post.isActive, isTrue);
    });
  });

  group('Post.toJson', () {
    test('writes the content type by enum name', () {
      final json = Fixtures.post(contentType: ContentType.kuran).toJson();

      expect(json['contentType'], 'kuran');
    });

    test('writes an empty string for a null arabicContent (asymmetric)', () {
      final json = Fixtures.post(arabicContent: null).toJson();

      expect(json['arabicContent'], '');
      // Round-trip loses the null: '' comes back, not null.
      expect(Post.fromJson(Map<String, Object?>.from(json)).arabicContent, '');
    });

    test('round-trips every other field', () {
      final original = Fixtures.post(
        contentType: ContentType.hadis,
        arabicContent: 'ar',
        isActive: false,
      );

      final restored = Post.fromJson(
        Map<String, Object?>.from(original.toJson()),
      );

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.contentType, original.contentType);
      expect(restored.arabicContent, original.arabicContent);
      expect(restored.content, original.content);
      expect(restored.source, original.source);
      expect(restored.createdAt, original.createdAt);
      expect(restored.isActive, original.isActive);
    });
  });

  group('Post constructor', () {
    test('isActive defaults to false', () {
      final post = Post(
        id: 'p',
        title: 't',
        contentType: ContentType.dua,
        content: 'c',
        source: 's',
        createdAt: DateTime(2026),
      );

      expect(post.isActive, isFalse);
      expect(post.arabicContent, isNull);
    });
  });

  group('Post.copyWith', () {
    test('overrides only the given fields', () {
      final original = Fixtures.post(arabicContent: 'ar');

      final copy = original.copyWith(
        title: 'New',
        contentType: ContentType.kuran,
        isActive: false,
      );

      expect(copy.title, 'New');
      expect(copy.contentType, ContentType.kuran);
      expect(copy.isActive, isFalse);
      expect(copy.id, original.id);
      expect(copy.arabicContent, 'ar');
      expect(copy.createdAt, original.createdAt);
    });
  });

  group('ContentType', () {
    test('has exactly hadis, kuran and dua', () {
      expect(ContentType.values, [
        ContentType.hadis,
        ContentType.kuran,
        ContentType.dua,
      ]);
    });
  });

  group('EmotionExtension.value', () {
    test('uses Turkish diacritics for the accented emotions', () {
      expect(Emotion.rizik.value, 'rızık');
      expect(Emotion.sabir.value, 'sabır');
      expect(Emotion.sukur.value, 'şükür');
      expect(Emotion.egitim.value, 'eğitim');
      expect(Emotion.saglik.value, 'sağlık');
      expect(Emotion.olum.value, 'ölüm');
    });

    test('equals the enum name for the non-accented emotions', () {
      const plain = [
        Emotion.tevbe,
        Emotion.korku,
        Emotion.umut,
        Emotion.huzur,
        Emotion.sevgi,
        Emotion.merhamet,
        Emotion.iman,
        Emotion.dua,
        Emotion.zikir,
        Emotion.ibadet,
        Emotion.ahlak,
        Emotion.aile,
        Emotion.evlilik,
        Emotion.fitne,
        Emotion.cihad,
        Emotion.kader,
        Emotion.ihlas,
      ];
      for (final emotion in plain) {
        expect(emotion.value, emotion.name, reason: emotion.name);
      }
    });

    test('values are unique across all emotions', () {
      final values = Emotion.values.map((e) => e.value).toSet();

      expect(values, hasLength(Emotion.values.length));
    });
  });

  group('EmotionExtension.fromString', () {
    test('resolves by display value', () {
      expect(EmotionExtension.fromString('rızık'), Emotion.rizik);
      expect(EmotionExtension.fromString('şükür'), Emotion.sukur);
    });

    test('resolves by enum name', () {
      expect(EmotionExtension.fromString('rizik'), Emotion.rizik);
      expect(EmotionExtension.fromString('sukur'), Emotion.sukur);
      expect(EmotionExtension.fromString('huzur'), Emotion.huzur);
    });

    test('returns null for an unknown string', () {
      expect(EmotionExtension.fromString('unknown'), isNull);
      expect(EmotionExtension.fromString(''), isNull);
      expect(EmotionExtension.fromString('RIZIK'), isNull);
    });

    test('round-trips every emotion through its value', () {
      for (final emotion in Emotion.values) {
        expect(EmotionExtension.fromString(emotion.value), emotion);
      }
    });
  });
}
