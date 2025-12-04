import '../enums/enums.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  // the emotions that the post is expressing with their weights (1-5)
  // it is used to recommend posts to the user based on emotion similarity
  final Map<Emotion, int> emotions;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final bool isActive;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.emotions,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.isActive = false,
  });

  factory Post.fromJson(Map<String, Object?> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    Map<Emotion, int> parseEmotions(dynamic value) {
      if (value == null) return {};
      if (value is! Map) return {};
      
      // Firestore'dan Map formatında gelir: {"sabır": 4, "rızık": 1}
      final Map<Emotion, int> result = {};
      value.forEach((key, val) {
        final emotion = EmotionExtension.fromString(key.toString());
        if (emotion != null) {
          final weight = (val as int? ?? 1).clamp(1, 5);
          result[emotion] = weight;
        }
      });
      return result;
    }

    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      emotions: parseEmotions(json['emotions']),
      createdAt: parseDateTime(json['createdAt']),
      lastUpdatedAt: parseDateTime(json['lastUpdatedAt']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'emotions': emotions.map((key, value) => MapEntry(key.value, value)),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    Map<Emotion, int>? emotions,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isActive,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      emotions: emotions ?? this.emotions,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
