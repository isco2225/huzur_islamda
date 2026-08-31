import '../enums/enums.dart';

class Post {
  final String id;
  //final String userId;
  final String title;
  final ContentType contentType;
  final String? arabicContent;
  final String content;
  // the emotions that the post is expressing with their weights (1-5)
  // it is used to recommend posts to the user based on emotion similarity
  //final Map<Emotion, int> emotions;
  final String source;
  final DateTime createdAt;
  //final DateTime lastUpdatedAt;
  final bool isActive;

  const Post({
    required this.id,
    //required this.userId,
    required this.title,
    required this.contentType,
    this.arabicContent,
    required this.content,
    //required this.emotions,
    required this.source,
    required this.createdAt,
    //required this.lastUpdatedAt,
    this.isActive = false,
  });

  // Private static helper methods for parsing
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static ContentType _parseContentType(dynamic value) {
    if (value == null) return ContentType.dua;
    if (value is String) {
      try {
        if (value == 'kuran') {
          return ContentType.kuran;
        }
        return ContentType.values.byName(value);
      } catch (_) {
        return ContentType.dua;
      }
    }
    if (value is ContentType) return value;
    return ContentType.dua;
  }

  factory Post.fromJson(Map<String, Object?> json) {
    return Post(
      id: json['id'] as String? ?? '',
      //userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contentType: _parseContentType(json['contentType']),
      arabicContent: json['arabicContent'] as String?,
      content: json['content'] as String? ?? '',
      //emotions: _parseEmotions(json['emotions']),
      source: json['source'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      //lastUpdatedAt: _parseDateTime(json['lastUpdatedAt']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      //'userId': userId,
      'title': title,
      'contentType': contentType.name,
      'arabicContent': arabicContent ?? '',
      'content': content,
      //'emotions': emotions.map((key, value) => MapEntry(key.value, value)),
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      //'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Post copyWith({
    String? id,
    //String? userId,
    String? title,
    ContentType? contentType,
    String? arabicContent,
    String? content,
    //Map<Emotion, int>? emotions,
    String? source,
    DateTime? createdAt,
    //DateTime? lastUpdatedAt,
    bool? isActive,
  }) {
    return Post(
      id: id ?? this.id,
      //userId: userId ?? this.userId,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      arabicContent: arabicContent ?? this.arabicContent,
      content: content ?? this.content,
      //emotions: emotions ?? this.emotions,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      //lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
