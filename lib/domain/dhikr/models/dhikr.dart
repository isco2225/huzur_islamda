import 'package:hive/hive.dart';

part 'dhikr.g.dart';

@HiveType(typeId: 0)
class Dhikr {
  static const String boxName = 'dhikrs';

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int targetCount;

  @HiveField(4)
  final int currentCount;

  @HiveField(5)
  final DateTime day;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime lastUpdatedAt;

  // Lokal/offline senkronizasyon durumu – Firestore'a yazılması şart değil
  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  final bool isDeleted;

  @HiveField(11)
  final String? groupId;

  const Dhikr({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetCount,
    required this.currentCount,
    required this.day,
    required this.isCompleted,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.isSynced = false,
    this.isDeleted = false,
    this.groupId,
  });

  factory Dhikr.fromJson(Map<String, Object?> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Dhikr(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int,
      day: parseDateTime(json['day']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: parseDateTime(json['createdAt']),
      lastUpdatedAt: parseDateTime(json['lastUpdatedAt']),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      groupId: json['groupId'] as String? ?? '',
    );
  }

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dhikrDate = DateTime(day.year, day.month, day.day);
    return dhikrDate.isBefore(today);
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
      'groupId': groupId,
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
    String? groupId,
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
      groupId: groupId ?? this.groupId,
    );
  }
}
