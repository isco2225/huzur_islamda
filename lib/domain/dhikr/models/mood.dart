import 'mood_suggestion.dart';

class Mood {
  const Mood({
    required this.id,
    required this.title,
    required this.colorHex,
    required this.suggestions,
  });

  final String id;
  final String title;
  final String colorHex;
  final List<MoodSuggestion> suggestions;

  factory Mood.fromJson(Map<String, Object?> json) {
    final suggestionsJson = json['suggestions'] as List<dynamic>? ?? [];
    final suggestions = suggestionsJson
        .map((e) => MoodSuggestion.fromJson(e as Map<String, Object?>))
        .toList();

    return Mood(
      id: json['id'] as String,
      title: json['title'] as String,
      colorHex: json['color_hex'] as String,
      suggestions: suggestions,
    );
  }
}
