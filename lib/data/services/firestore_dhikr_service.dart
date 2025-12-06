import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestoreDhikrService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'dhikrs';
  Future<Result<Dhikr>> createDhikr({
    required String userId,
    required String name,
    int? targetCount,
  }) async {
    try {
      final currentDate = DateTime.now();
      final docRef = _firestore.collection(_collectionName).doc();
      final dhikr = Dhikr(
        id: docRef.id,
        userId: userId,
        name: name,
        targetCount: targetCount,
        currentCount: 0,
        day: DateTime(currentDate.year, currentDate.month, currentDate.day),
        isCompleted: false,
        createdAt: currentDate,
        lastUpdatedAt: currentDate,
      );
      await docRef.set(dhikr.toJson());

      return Result.ok(dhikr);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to create dhikir: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to create dhikir: $e'));
    }
  }
}
