import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  group('UserAgeCalculater.calculateAge', () {
    const years = 20;

    test('counts a full year when the birthday is today', () {
      final now = DateTime.now();
      // Day clamped to 28 so the date exists in every year (leap-safe). When
      // clamping applies the birthday was earlier this month, which yields
      // the same age.
      final birth = DateTime(
        now.year - years,
        now.month,
        now.day > 28 ? 28 : now.day,
      );

      expect(UserAgeCalculater(dateOfBirth: birth).calculateAge(), years);
    });

    test('does not count the year when the birthday is tomorrow', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final birth = DateTime(tomorrow.year - years, tomorrow.month, tomorrow.day);

      // If tomorrow rolls into a new year, the birth year is one later, so the
      // raw year difference is already years - 1 and no month/day adjustment
      // applies; otherwise the month/day comparison subtracts one.
      expect(UserAgeCalculater(dateOfBirth: birth).calculateAge(), years - 1);
    });

    test('counts the year when the birthday was yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final birth = DateTime(
        yesterday.year - years,
        yesterday.month,
        yesterday.day,
      );

      expect(UserAgeCalculater(dateOfBirth: birth).calculateAge(), years);
    });

    test('returns zero for someone born earlier this year or today', () {
      final now = DateTime.now();
      final birth = DateTime(now.year, now.month, now.day);

      expect(UserAgeCalculater(dateOfBirth: birth).calculateAge(), 0);
    });

    test('handles a birth date later in the year than today', () {
      final now = DateTime.now();
      // One year and one day from now, shifted back 30 years: the birthday
      // has not yet occurred this year, so the age is 29.
      final later = DateTime(now.year - 30, now.month, now.day + 1);
      final expected = later.year == now.year - 30 ? 29 : 30;

      expect(UserAgeCalculater(dateOfBirth: later).calculateAge(), expected);
    });

    test('is negative for a future birth year (no clamping)', () {
      final now = DateTime.now();
      final birth = DateTime(now.year + 2, now.month, 1);

      expect(UserAgeCalculater(dateOfBirth: birth).calculateAge(), lessThan(0));
    });
  });
}
