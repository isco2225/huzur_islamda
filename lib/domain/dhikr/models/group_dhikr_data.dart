import 'dhikr.dart';

class GroupDhikrData {
  const GroupDhikrData({
    required this.groupId,
    required this.dhikrs,
    required this.groupName,
  });
  final String groupId;
  final List<Dhikr> dhikrs;
  final String groupName;

  int get totalCount => dhikrs.length;

  int get completedCount => dhikrs
      .where((d) => d.isCompleted || d.currentCount >= d.targetCount)
      .length;

  bool get isCompleted => totalCount > 0 && completedCount == totalCount;

  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;
}
