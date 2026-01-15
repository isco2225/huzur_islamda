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

  /// Tüm namaz vakitlerini sıralı liste olarak döndürür
  List<({String name, DateTime time})> get allPrayerTimes {
    return [
      (name: 'İmsak', time: fajr),
      (
        name: 'Güneş',
        time: dhuhr,
      ), // Not: Güneş vakti için ayrı field yok, dhuhr kullanılıyor
      (name: 'Öğle', time: dhuhr),
      (name: 'İkindi', time: asr),
      (name: 'Akşam', time: maghrib),
      (name: 'Yatsı', time: isha),
    ];
  }

  /// Şu anki zamandan sonraki ilk namaz vaktini ve ismini döndürür
  /// Eğer bugünün tüm vakitleri geçmişse, yarının ilk vaktini (İmsak) döndürür
  ({String name, DateTime time})? getNextPrayerTime() {
    final now = DateTime.now();

    // Bugünün tüm vakitlerini al
    final todayPrayers = allPrayerTimes;

    // Şu anki zamandan sonraki ilk vakti bul
    for (final prayer in todayPrayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    // Eğer bugünün tüm vakitleri geçmişse, yarının İmsak vaktini döndür
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return (
      name: 'İmsak',
      time: DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        fajr.hour,
        fajr.minute,
      ),
    );
  }

  /// Şu anki zamandan sonraki vakte kalan süreyi Duration olarak döndürür
  Duration? getRemainingTimeToNextPrayer() {
    final nextPrayer = getNextPrayerTime();
    if (nextPrayer == null) return null;

    final now = DateTime.now();
    return nextPrayer.time.difference(now);
  }

  /// Şu anki zamanda hangi namaz vakti içinde olduğumuzu döndürür
  /// Örneğin: Öğle vakti geçmiş ama İkindi vakti gelmemişse "Öğle" döndürür
  /// Eğer hiçbir vakit içinde değilsek (tüm vakitler geçmişse) "Yatsı" döndürür
  String? getCurrentPrayerTime() {
    final now = DateTime.now();

    // Vakitleri sırayla kontrol et
    // İmsak (fajr) -> Öğle (dhuhr) -> İkindi (asr) -> Akşam (maghrib) -> Yatsı (isha)

    // İmsak ile Öğle arası -> İmsak
    if (now.isAfter(fajr) && now.isBefore(dhuhr)) {
      return 'İmsak';
    }

    // Öğle ile İkindi arası -> Öğle
    if (now.isAfter(dhuhr) && now.isBefore(asr)) {
      return 'Öğle';
    }

    // İkindi ile Akşam arası -> İkindi
    if (now.isAfter(asr) && now.isBefore(maghrib)) {
      return 'İkindi';
    }

    // Akşam ile Yatsı arası -> Akşam
    if (now.isAfter(maghrib) && now.isBefore(isha)) {
      return 'Akşam';
    }

    // Yatsı'dan sonra (yarının İmsak'ına kadar) -> Yatsı
    if (now.isAfter(isha)) {
      return 'Yatsı';
    }

    // İmsak'tan önce (dünün Yatsı'sından sonra) -> Yatsı
    if (now.isBefore(fajr)) {
      return 'Yatsı';
    }

    // Tam vakit anında (eşitse) -> O vakit
    if (now.hour == fajr.hour && now.minute == fajr.minute) {
      return 'İmsak';
    }
    if (now.hour == dhuhr.hour && now.minute == dhuhr.minute) {
      return 'Öğle';
    }
    if (now.hour == asr.hour && now.minute == asr.minute) {
      return 'İkindi';
    }
    if (now.hour == maghrib.hour && now.minute == maghrib.minute) {
      return 'Akşam';
    }
    if (now.hour == isha.hour && now.minute == isha.minute) {
      return 'Yatsı';
    }

    return null;
  }
}
