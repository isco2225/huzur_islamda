import 'package:huzur_islamda/domain/domain.dart';

/// Builders for domain models with sensible defaults, so tests only spell
/// out the fields they care about.
class Fixtures {
  Fixtures._();

  static final DateTime fixedDate = DateTime(2026, 3, 15, 10, 30);

  static Auth auth({
    String uid = 'uid-1',
    String email = 'test@example.com',
    bool isEmailVerified = true,
  }) {
    return Auth(uid: uid, email: email, isEmailVerified: isEmailVerified);
  }

  static User user({
    String uid = 'uid-1',
    String email = 'test@example.com',
    String name = 'Ahmet',
    String surname = 'Yılmaz',
    String dateOfBirth = '01/01/1990',
    String gender = 'male',
    bool emailVerified = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isRegistered = true,
    String? country = 'Türkiye',
    String? city = 'İstanbul',
    String? districtId = '9541',
    DateTime? lastSupportedAt,
    SupportPackage? supportPackage,
  }) {
    return User(
      uid: uid,
      email: email,
      name: name,
      surname: surname,
      dateOfBirth: dateOfBirth,
      gender: gender,
      emailVerified: emailVerified,
      createdAt: createdAt ?? fixedDate,
      updatedAt: updatedAt ?? fixedDate,
      isRegistered: isRegistered,
      country: country,
      city: city,
      districtId: districtId,
      lastSupportedAt: lastSupportedAt,
      supportPackage: supportPackage,
    );
  }

  static Dhikr dhikr({
    String id = 'dhikr-1',
    String userId = 'uid-1',
    String name = 'Subhanallah',
    int targetCount = 33,
    int currentCount = 0,
    DateTime? day,
    bool isCompleted = false,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool isSynced = false,
    bool isDeleted = false,
    String? groupId,
    String? groupDisplayName,
    String? arabic,
    String? meaning,
    String? benefit,
  }) {
    return Dhikr(
      id: id,
      userId: userId,
      name: name,
      targetCount: targetCount,
      currentCount: currentCount,
      day: day ?? fixedDate,
      isCompleted: isCompleted,
      createdAt: createdAt ?? fixedDate,
      lastUpdatedAt: lastUpdatedAt ?? fixedDate,
      isSynced: isSynced,
      isDeleted: isDeleted,
      groupId: groupId,
      groupDisplayName: groupDisplayName,
      arabic: arabic,
      meaning: meaning,
      benefit: benefit,
    );
  }

  static PrayerTimes prayerTimes({
    DateTime? date,
    int fajrHour = 5,
    int sunriseHour = 6,
    int dhuhrHour = 13,
    int asrHour = 16,
    int maghribHour = 19,
    int ishaHour = 21,
  }) {
    final d = date ?? fixedDate;
    DateTime at(int hour) => DateTime(d.year, d.month, d.day, hour);
    return PrayerTimes(
      fajr: at(fajrHour),
      sunrise: at(sunriseHour),
      dhuhr: at(dhuhrHour),
      asr: at(asrHour),
      maghrib: at(maghribHour),
      isha: at(ishaHour),
    );
  }

  /// Builds a [Prayer] whose [Prayer.prayerTimes] covers [days] consecutive
  /// days starting from [from] (defaults to today), so `getTodayPrayerTimes`
  /// resolves in tests that depend on `DateTime.now()`.
  static Prayer prayer({
    String userId = 'uid-1',
    String districtId = '9541',
    String city = 'İstanbul',
    String country = 'Türkiye',
    int? year,
    DateTime? from,
    int days = 1,
    Map<String, PrayerTimes>? prayerTimes,
  }) {
    final start = from ?? DateTime.now();
    final resolvedYear = year ?? start.year;
    final times =
        prayerTimes ??
        {
          for (var i = 0; i < days; i++)
            Prayer.formatDate(
              DateTime(start.year, start.month, start.day + i),
            ): Fixtures.prayerTimes(
              date: DateTime(start.year, start.month, start.day + i),
            ),
        };
    return Prayer(
      id: 'prayer_${resolvedYear}_$districtId',
      userId: userId,
      year: resolvedYear,
      districtId: districtId,
      city: city,
      country: country,
      prayerTimes: times,
    );
  }

  static Post post({
    String id = 'post-1',
    String title = 'Başlık',
    ContentType contentType = ContentType.dua,
    String? arabicContent,
    String content = 'İçerik',
    String source = 'Kaynak',
    DateTime? createdAt,
    bool isActive = true,
  }) {
    return Post(
      id: id,
      title: title,
      contentType: contentType,
      arabicContent: arabicContent,
      content: content,
      source: source,
      createdAt: createdAt ?? fixedDate,
      isActive: isActive,
    );
  }

  static AppPreferences appPreferences({
    bool isVibrationEnabled = true,
    bool isNotificationsEnabled = false,
    bool isOnboardingCompleted = false,
    int assistantDailyLimit = 5,
    String lastLimitResetDate = '2026-03-15',
  }) {
    return AppPreferences(
      isVibrationEnabled: isVibrationEnabled,
      isNotificationsEnabled: isNotificationsEnabled,
      isOnboardingCompleted: isOnboardingCompleted,
      assistantDailyLimit: assistantDailyLimit,
      lastLimitResetDate: lastLimitResetDate,
    );
  }
}
