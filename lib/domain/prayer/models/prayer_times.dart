import 'package:hive/hive.dart';

part 'prayer_times.g.dart';

/// Her günün namaz vakitlerini tutan model
@HiveType(typeId: 2)
class PrayerTimes {
  @HiveField(0)
  final DateTime fajr;

  @HiveField(1)
  final DateTime dhuhr;

  @HiveField(2)
  final DateTime asr;

  @HiveField(3)
  final DateTime maghrib;

  @HiveField(4)
  final DateTime isha;

  const PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// API'den gelen JSON formatını parse eder
  /// API formatı: { "imsak": "06:15", "ogle": "12:30", ... }
  /// date parametresi ile saat bilgisi DateTime'a çevrilir
  factory PrayerTimes.fromApiJson(Map<String, Object?> json, DateTime date) {
    DateTime parseTime(String? timeString) {
      if (timeString == null || timeString.isEmpty) {
        return date;
      }

      // "06:15" formatındaki string'i parse et
      final parts = timeString.split(':');
      if (parts.length != 2) {
        return date;
      }

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    return PrayerTimes(
      // API'deki isimler: imsak=fajr, ogle=dhuhr, ikindi=asr, aksam=maghrib, yatsi=isha
      fajr: parseTime(json['imsak'] as String?),
      dhuhr: parseTime(json['ogle'] as String?),
      asr: parseTime(json['ikindi'] as String?),
      maghrib: parseTime(json['aksam'] as String?),
      isha: parseTime(json['yatsi'] as String?),
    );
  }

  /// Standart JSON formatını parse eder (DateTime string formatında)
  factory PrayerTimes.fromJson(Map<String, Object?> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return PrayerTimes(
      fajr: parseDateTime(json['fajr'] ?? json['Fajr']),
      dhuhr: parseDateTime(json['dhuhr'] ?? json['Dhuhr']),
      asr: parseDateTime(json['asr'] ?? json['Asr']),
      maghrib: parseDateTime(json['maghrib'] ?? json['Maghrib']),
      isha: parseDateTime(json['isha'] ?? json['Isha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
    };
  }

  PrayerTimes copyWith({
    DateTime? fajr,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
  }) {
    return PrayerTimes(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}
