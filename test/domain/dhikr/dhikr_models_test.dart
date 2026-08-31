import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  Map<String, Object?> minimalJson() => {
    'id': 'd-1',
    'userId': 'u-1',
    'name': 'Subhanallah',
    'targetCount': 33,
    'currentCount': 3,
  };

  group('Dhikr.fromJson', () {
    test('applies defaults for optional fields', () {
      final before = DateTime.now();
      final dhikr = Dhikr.fromJson(minimalJson());
      final after = DateTime.now();

      expect(dhikr.id, 'd-1');
      expect(dhikr.userId, 'u-1');
      expect(dhikr.name, 'Subhanallah');
      expect(dhikr.targetCount, 33);
      expect(dhikr.currentCount, 3);
      expect(dhikr.isCompleted, isFalse);
      expect(dhikr.isSynced, isFalse);
      expect(dhikr.isDeleted, isFalse);
      expect(dhikr.groupDisplayName, isNull);
      expect(dhikr.arabic, isNull);
      expect(dhikr.meaning, isNull);
      expect(dhikr.benefit, isNull);
      for (final date in [dhikr.day, dhikr.createdAt, dhikr.lastUpdatedAt]) {
        expect(date.isBefore(before), isFalse);
        expect(date.isAfter(after), isFalse);
      }
    });

    test('defaults a missing groupId to an empty string, not null', () {
      final dhikr = Dhikr.fromJson(minimalJson());

      // Quirk: the constructor default is null but fromJson coerces to ''.
      expect(dhikr.groupId, '');
    });

    test('parses ISO strings and DateTime instances', () {
      final dhikr = Dhikr.fromJson(
        minimalJson()
          ..addAll({
            'day': '2026-03-15T00:00:00.000',
            'createdAt': DateTime(2026, 3, 14, 9),
            'lastUpdatedAt': '2026-03-15T10:30:00.000',
            'isCompleted': true,
            'isSynced': true,
            'isDeleted': true,
            'groupId': 'g-1',
            'groupDisplayName': 'Namaz Tesbihatı',
            'arabic': 'سبحان الله',
            'meaning': 'meaning',
            'benefit': 'benefit',
          }),
      );

      expect(dhikr.day, DateTime(2026, 3, 15));
      expect(dhikr.createdAt, DateTime(2026, 3, 14, 9));
      expect(dhikr.lastUpdatedAt, DateTime(2026, 3, 15, 10, 30));
      expect(dhikr.isCompleted, isTrue);
      expect(dhikr.isSynced, isTrue);
      expect(dhikr.isDeleted, isTrue);
      expect(dhikr.groupId, 'g-1');
      expect(dhikr.groupDisplayName, 'Namaz Tesbihatı');
      expect(dhikr.arabic, 'سبحان الله');
    });

    test('throws when a required field is missing', () {
      expect(
        () => Dhikr.fromJson(minimalJson()..remove('targetCount')),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Dhikr.toJson', () {
    test('round-trips field by field', () {
      final original = Fixtures.dhikr(
        currentCount: 10,
        isCompleted: true,
        isSynced: true,
        groupId: 'g-1',
        groupDisplayName: 'Group',
        arabic: 'ar',
        meaning: 'me',
        benefit: 'be',
      );

      final json = original.toJson();
      final restored = Dhikr.fromJson(Map<String, Object?>.from(json));

      expect(json['day'], Fixtures.fixedDate.toIso8601String());
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.targetCount, original.targetCount);
      expect(restored.currentCount, original.currentCount);
      expect(restored.day, original.day);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.createdAt, original.createdAt);
      expect(restored.lastUpdatedAt, original.lastUpdatedAt);
      expect(restored.isSynced, original.isSynced);
      expect(restored.isDeleted, original.isDeleted);
      expect(restored.groupId, original.groupId);
      expect(restored.groupDisplayName, original.groupDisplayName);
      expect(restored.arabic, original.arabic);
      expect(restored.meaning, original.meaning);
      expect(restored.benefit, original.benefit);
    });

    test('writes null groupId which reads back as empty string', () {
      final json = Fixtures.dhikr().toJson();

      expect(json['groupId'], isNull);
      expect(Dhikr.fromJson(Map<String, Object?>.from(json)).groupId, '');
    });
  });

  group('Dhikr.isExpired', () {
    test('is true for a dhikr dated yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 23, 59);

      expect(Fixtures.dhikr(day: yesterday).isExpired, isTrue);
    });

    test('is false for a dhikr dated today regardless of time', () {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      expect(Fixtures.dhikr(day: startOfToday).isExpired, isFalse);
      expect(Fixtures.dhikr(day: now).isExpired, isFalse);
    });

    test('is false for a dhikr dated tomorrow', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      expect(Fixtures.dhikr(day: tomorrow).isExpired, isFalse);
    });
  });

  group('Dhikr.copyWith', () {
    test('overrides only the given fields', () {
      final original = Fixtures.dhikr(groupId: 'g-1');

      final copy = original.copyWith(currentCount: 33, isCompleted: true);

      expect(copy.currentCount, 33);
      expect(copy.isCompleted, isTrue);
      expect(copy.id, original.id);
      expect(copy.groupId, 'g-1');
      expect(copy.day, original.day);
      expect(copy.isSynced, original.isSynced);
    });

    test('cannot reset a nullable field to null', () {
      final copy = Fixtures.dhikr(groupId: 'g-1').copyWith(groupId: null);

      expect(copy.groupId, 'g-1');
    });
  });

  group('GroupDhikrData', () {
    GroupDhikrData build(List<Dhikr> dhikrs) =>
        GroupDhikrData(groupId: 'g', dhikrs: dhikrs, groupName: 'Group');

    test('empty group is not completed and has zero progress', () {
      final data = build([]);

      expect(data.totalCount, 0);
      expect(data.completedCount, 0);
      expect(data.isCompleted, isFalse);
      expect(data.progress, 0.0);
    });

    test('partially completed group reports fractional progress', () {
      final data = build([
        Fixtures.dhikr(id: 'a', isCompleted: true),
        Fixtures.dhikr(id: 'b', currentCount: 10, targetCount: 33),
        Fixtures.dhikr(id: 'c'),
        Fixtures.dhikr(id: 'd'),
      ]);

      expect(data.totalCount, 4);
      expect(data.completedCount, 1);
      expect(data.isCompleted, isFalse);
      expect(data.progress, 0.25);
    });

    test('counts a dhikr complete via the isCompleted flag', () {
      final data = build([Fixtures.dhikr(currentCount: 0, isCompleted: true)]);

      expect(data.completedCount, 1);
      expect(data.isCompleted, isTrue);
      expect(data.progress, 1.0);
    });

    test('counts a dhikr complete when count reaches or exceeds target', () {
      final data = build([
        Fixtures.dhikr(id: 'a', currentCount: 33, targetCount: 33),
        Fixtures.dhikr(id: 'b', currentCount: 40, targetCount: 33),
      ]);

      expect(data.completedCount, 2);
      expect(data.isCompleted, isTrue);
    });

    test('one count short of target is not complete', () {
      final data = build([Fixtures.dhikr(currentCount: 32, targetCount: 33)]);

      expect(data.completedCount, 0);
      expect(data.isCompleted, isFalse);
    });
  });

  group('MoodSuggestion.fromJson', () {
    const json = {
      'id': 's-1',
      'arabic': 'ar',
      'pronunciation': 'pr',
      'meaning': 'me',
      'benefit': 'be',
      'default_target': 99,
    };

    test('reads snake_case keys', () {
      final suggestion = MoodSuggestion.fromJson(json);

      expect(suggestion.id, 's-1');
      expect(suggestion.arabic, 'ar');
      expect(suggestion.pronunciation, 'pr');
      expect(suggestion.meaning, 'me');
      expect(suggestion.benefit, 'be');
      expect(suggestion.defaultTarget, 99);
    });

    test('throws when default_target is missing', () {
      final incomplete = Map<String, Object?>.from(json)
        ..remove('default_target');

      expect(
        () => MoodSuggestion.fromJson(incomplete),
        throwsA(isA<TypeError>()),
      );
    });

    test('does not accept a camelCase defaultTarget key', () {
      final camel = Map<String, Object?>.from(json)
        ..remove('default_target')
        ..['defaultTarget'] = 99;

      expect(() => MoodSuggestion.fromJson(camel), throwsA(isA<TypeError>()));
    });
  });

  group('Mood.fromJson', () {
    test('reads snake_case color_hex and nested suggestions', () {
      final mood = Mood.fromJson({
        'id': 'm-1',
        'title': 'Huzur',
        'color_hex': '#AABBCC',
        'suggestions': [
          {
            'id': 's-1',
            'arabic': 'ar',
            'pronunciation': 'pr',
            'meaning': 'me',
            'benefit': 'be',
            'default_target': 33,
          },
        ],
      });

      expect(mood.id, 'm-1');
      expect(mood.title, 'Huzur');
      expect(mood.colorHex, '#AABBCC');
      expect(mood.suggestions, hasLength(1));
      expect(mood.suggestions.single.defaultTarget, 33);
    });

    test('defaults to no suggestions when the key is absent', () {
      final mood = Mood.fromJson({
        'id': 'm-1',
        'title': 'Huzur',
        'color_hex': '#AABBCC',
      });

      expect(mood.suggestions, isEmpty);
    });

    test('throws when color_hex is missing', () {
      expect(
        () => Mood.fromJson({'id': 'm-1', 'title': 'Huzur'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('PrayerDhikrConstants', () {
    test('lists the three prayer dhikrs in order with target 33', () {
      expect(PrayerDhikrConstants.prayerDhikrNames, [
        'Subhanallah',
        'Elhamdulillah',
        'Allahu Ekber',
      ]);
      expect(PrayerDhikrConstants.prayerDhikrNames, [
        PrayerDhikrConstants.subhanallahName,
        PrayerDhikrConstants.elhamdulillahName,
        PrayerDhikrConstants.allahuEkberName,
      ]);
      expect(PrayerDhikrConstants.prayerDhikrTargetCount, 33);
    });
  });
}
