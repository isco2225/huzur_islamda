import 'package:hive/hive.dart';

import 'prayer_times.dart';

part 'prayer.g.dart';

/// Kullanıcının yaşadığı bölge için senelik namaz vakitlerini tutan model
@HiveType(typeId: 1)
class Prayer {
  static const String boxName = 'prayers';

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final String districtId;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final String country;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  /// Tarih bazlı namaz vakitleri (key: "YYYY-MM-DD" formatında tarih string)
  @HiveField(8)
  final Map<String, PrayerTimes> prayerTimes;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime lastUpdatedAt;

  const Prayer({
    required this.id,
    required this.userId,
    required this.year,
    required this.districtId,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    required this.prayerTimes,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory Prayer.fromJson(Map<String, Object?> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    // PrayerTimes map'ini parse et
    Map<String, PrayerTimes> parsePrayerTimes(dynamic value) {
      if (value == null) return {};
      if (value is! Map) return {};

      final Map<String, PrayerTimes> result = {};
      value.forEach((key, val) {
        if (val is Map<String, Object?>) {
          result[key.toString()] = PrayerTimes.fromJson(val);
        }
      });
      return result;
    }

    return Prayer(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      year: json['year'] as int? ?? DateTime.now().year,
      districtId:
          json['districtId'] as String? ?? json['district_id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      prayerTimes: parsePrayerTimes(
        json['prayerTimes'] ?? json['prayer_times'],
      ),
      createdAt: parseDateTime(json['createdAt'] ?? json['created_at']),
      lastUpdatedAt: parseDateTime(
        json['lastUpdatedAt'] ?? json['last_updated_at'],
      ),
    );
  }

  /// API'den gelen yıllık namaz vakitleri JSON'unu parse eder
  /// API formatı: { "meta": {...}, "data": [{ "district_id": "...", "date": "...", "times": {...} }] }
  factory Prayer.fromApiJson(
    Map<String, Object?> apiResponse,
    String userId,
    String districtId,
    String city,
    String country, {
    double? latitude,
    double? longitude,
  }) {
    final meta = apiResponse['meta'] as Map<String, Object?>?;
    final data = apiResponse['data'] as List<dynamic>? ?? [];

    final year = (meta?['year'] as num?)?.toInt() ?? DateTime.now().year;
    final generatedAt = meta?['generated_at'] as String?;

    // API'den gelen verileri tarih bazlı map'e çevir
    final Map<String, PrayerTimes> prayerTimesMap = {};

    for (final item in data) {
      if (item is! Map<String, Object?>) continue;

      final dateString = item['date'] as String?;
      final times = item['times'] as Map<String, Object?>?;

      if (dateString == null || times == null) continue;

      // Tarihi parse et
      final date = DateTime.parse(dateString);
      final dateKey = formatDate(date);

      // PrayerTimes'ı oluştur
      prayerTimesMap[dateKey] = PrayerTimes.fromApiJson(times, date);
    }

    final now = DateTime.now();
    final createdAt = generatedAt != null
        ? DateTime.tryParse(generatedAt) ?? now
        : now;

    return Prayer(
      id: 'prayer_${year}_$districtId',
      userId: userId,
      year: year,
      districtId: districtId,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      prayerTimes: prayerTimesMap,
      createdAt: createdAt,
      lastUpdatedAt: createdAt,
    );
  }

  /// Belirli bir tarih için namaz vakitlerini getirir
  /// Tarih formatı: "YYYY-MM-DD" (örn: "2024-01-15")
  PrayerTimes? getPrayerTimesForDate(String date) {
    return prayerTimes[date];
  }

  /// Belirli bir tarih için namaz vakitlerini getirir (DateTime ile)
  PrayerTimes? getPrayerTimesForDateTime(DateTime date) {
    final dateString = formatDate(date);
    return prayerTimes[dateString];
  }

  /// Bugünün namaz vakitlerini getirir
  PrayerTimes? getTodayPrayerTimes() {
    return getPrayerTimesForDateTime(DateTime.now());
  }

  /// Tarihi "YYYY-MM-DD" formatına çevirir
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> prayerTimesJson = {};
    prayerTimes.forEach((key, value) {
      prayerTimesJson[key] = value.toJson();
    });

    return {
      'id': id,
      'userId': userId,
      'year': year,
      'districtId': districtId,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'prayerTimes': prayerTimesJson,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  Prayer copyWith({
    String? id,
    String? userId,
    int? year,
    String? districtId,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    Map<String, PrayerTimes>? prayerTimes,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return Prayer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      districtId: districtId ?? this.districtId,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
