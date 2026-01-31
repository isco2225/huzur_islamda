/// Ruh haline göre zikir JSON'undaki tek bir zikir önerisi.
class MoodSuggestion {
  const MoodSuggestion({
    required this.id,
    required this.arabic,
    required this.pronunciation,
    required this.meaning,
    required this.benefit,
    required this.defaultTarget,
  });

  final String id;
  final String arabic;
  final String pronunciation;
  final String meaning;
  final String benefit;
  final int defaultTarget;

  factory MoodSuggestion.fromJson(Map<String, Object?> json) {
    return MoodSuggestion(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      pronunciation: json['pronunciation'] as String,
      meaning: json['meaning'] as String,
      benefit: json['benefit'] as String,
      defaultTarget: json['default_target'] as int,
    );
  }
}
