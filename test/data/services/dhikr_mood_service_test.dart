import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Loads the real `assets/data/dhikrs/dhikrs_for_emotions.json` through
/// `rootBundle`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DhikrMoodService.getDhikrMoods', () {
    late List<Mood> moods;

    setUpAll(() async {
      final result = await DhikrMoodService().getDhikrMoods();
      expect(result, isA<Ok<List<Mood>>>());
      moods = result.asOk.value;
    });

    test('loads a non-empty mood list', () {
      expect(moods, isNotEmpty);
      expect(moods.map((m) => m.id), contains('distressed'));
    });

    test('every mood has an id, a title and a #-prefixed colour', () {
      for (final mood in moods) {
        expect(mood.id, isNotEmpty);
        expect(mood.title, isNotEmpty);
        expect(mood.colorHex, startsWith('#'));
        expect(mood.colorHex.length, 7, reason: mood.colorHex);
      }
    });

    test('every mood has suggestions with a positive default target', () {
      for (final mood in moods) {
        expect(mood.suggestions, isNotEmpty, reason: mood.id);
        for (final suggestion in mood.suggestions) {
          expect(suggestion.id, isNotEmpty);
          expect(suggestion.arabic, isNotEmpty);
          expect(suggestion.pronunciation, isNotEmpty);
          expect(suggestion.meaning, isNotEmpty);
          expect(suggestion.benefit, isNotEmpty);
          expect(
            suggestion.defaultTarget,
            greaterThan(0),
            reason: '${mood.id}/${suggestion.id}',
          );
        }
      }
    });

    test('mood ids are unique', () {
      final ids = moods.map((m) => m.id).toList();

      expect(ids.toSet().length, ids.length);
    });
  });
}
