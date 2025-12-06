class Dhikr {
  final String id;
  final String userId;
  final String name;
  final int? targetCount;
  final int currentCount;
  final DateTime day;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  // Lokal/offline senkronizasyon durumu – Firestore'a yazılması şart değil
  final bool isSynced;
  final bool isDeleted;

  const Dhikr({
    required this.id,
    required this.userId,
    required this.name,
    this.targetCount,
    required this.currentCount,
    required this.day,
    required this.isCompleted,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  factory Dhikr.fromJson(Map<String, Object?> json) {
    DateTime _parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Dhikr(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetCount: json['targetCount'] as int?,
      currentCount: json['currentCount'] as int,
      day: _parseDateTime(json['day']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      lastUpdatedAt: _parseDateTime(json['lastUpdatedAt']),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'day': day.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  Dhikr copyWith({
    String? id,
    String? userId,
    String? name,
    int? targetCount,
    int? currentCount,
    DateTime? day,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Dhikr(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      day: day ?? this.day,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
