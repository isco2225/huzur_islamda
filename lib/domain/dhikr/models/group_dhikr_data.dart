import 'dhikr.dart';

/// View-layer odaklı grup zikir verisi.
///
/// Aynı `groupId`'ye sahip zikirleri bir arada temsil eder ve
/// grup bazlı hesaplamaları (ilerleme, tamamlanma vb.) sağlar.
class GroupDhikrData {
  const GroupDhikrData({
    required this.groupId,
    required this.dhikrs,
    required this.groupName,
  });

  /// Grup kimliği (ör: `prayer_dhikr_123456`).
  final String groupId;

  /// Bu gruba ait tüm zikirler.
  final List<Dhikr> dhikrs;

  /// UI'da gösterilecek grup adı.
  ///
  /// Şimdilik tek tip (ör: "Namaz Tesbihatı") kullanılabilir,
  /// ileride farklı grup tipleri için özelleştirilebilir.
  final String groupName;

  /// Gruptaki toplam zikir sayısı.
  int get totalCount => dhikrs.length;

  /// Tamamlanan zikir sayısı.
  int get completedCount => dhikrs
      .where((d) => d.isCompleted || d.currentCount >= d.targetCount)
      .length;

  /// Gruptaki tüm zikirler tamamlandı mı?
  bool get isCompleted => totalCount > 0 && completedCount == totalCount;

  /// Grup ilerlemesi (0.0 - 1.0).
  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;
}

