/// Constants for prayer dhikr feature
///
/// Contains names, target counts, and utility functions for prayer dhikrs
class PrayerDhikrConstants {
  // Prevent instantiation
  const PrayerDhikrConstants._();

  /// Name for Subhanallah dhikr
  static const String subhanallahName = 'Subhanallah';

  /// Name for Elhamdulillah dhikr
  static const String elhamdulillahName = 'Elhamdulillah';

  /// Name for Allahu Ekber dhikr
  static const String allahuEkberName = 'Allahu Ekber';

  /// Target count for each prayer dhikr (33)
  static const int prayerDhikrTargetCount = 33;

  /// List of all prayer dhikr names in order
  static const List<String> prayerDhikrNames = [
    subhanallahName,
    elhamdulillahName,
    allahuEkberName,
  ];
}
