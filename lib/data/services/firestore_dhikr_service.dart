import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestoreDhikrService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'dhikrs';
  static const String _usersCollectionName = 'users';
  Future<Result<Dhikr>> createDhikr({
    required String userId,
    required String name,
    required int targetCount,
  }) async {
    try {
      final currentDate = DateTime.now();
      final docRef = _firestore
          .collection(_usersCollectionName)
          .doc(userId)
          .collection(_collectionName)
          .doc();
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

  Future<Result<List<Dhikr>>> fetchDhikrs({
    required String userId,
    required DateTime day,
  }) async {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final docs = await _firestore
          .collection(_usersCollectionName)
          .doc(userId)
          .collection(_collectionName)
          .where('day', isEqualTo: normalizedDay)
          .get();
      final dhikrs = docs.docs
          .map((doc) => Dhikr.fromJson(doc.data()))
          .toList();
      return Result.ok(dhikrs);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch dhikrs: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch dhikrs: $e'));
    }
  }

  Future<Result<List<Dhikr>>> fetchAllDhikrs({required String userId}) async {
    try {
      final docs = await _firestore
          .collection(_usersCollectionName)
          .doc(userId)
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      final dhikrs = docs.docs
          .map((doc) => Dhikr.fromJson(doc.data()))
          .toList();
      return Result.ok(dhikrs);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch all dhikrs: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch all dhikrs: $e'));
    }
  }
}
