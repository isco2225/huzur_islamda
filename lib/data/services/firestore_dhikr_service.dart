import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestoreDhikrService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'dhikrs';
  static const String _usersCollectionName = 'users';
  Future<Result<void>> saveDhikrs({
    required String userId,
    required List<Dhikr> dhikrs,
  }) async {
    try {
      for (final dhikr in dhikrs) {
        final docRef = _firestore
            .collection(_usersCollectionName)
            .doc(userId)
            .collection(_collectionName)
            .doc(dhikr.id);
        await docRef.set(dhikr.toJson());
      }
      return Result.ok(null);
    } on FirebaseException catch (_) {
      return Result.error(const DhikrSaveFailed());
    } catch (_) {
      return Result.error(const DhikrSaveFailed());
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
    } on FirebaseException catch (_) {
      return Result.error(const DhikrFetchFailed());
    } catch (_) {
      return Result.error(const DhikrFetchFailed());
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
    } on FirebaseException catch (_) {
      return Result.error(const DhikrFetchAllFailed());
    } catch (_) {
      return Result.error(const DhikrFetchAllFailed());
    }
  }

  Future<Result<void>> deleteDhikr({
    required String userId,
    required String dhikrId,
  }) async {
    try {
      await _firestore
          .collection(_usersCollectionName)
          .doc(userId)
          .collection(_collectionName)
          .doc(dhikrId)
          .delete();
      return Result.ok(null);
    } on FirebaseException catch (_) {
      return Result.error(const DhikrDeleteFailed());
    } catch (_) {
      return Result.error(const DhikrDeleteFailed());
    }
  }

  Future<Result<int?>> getDhikrsCount({required String userId}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollectionName)
          .doc(userId)
          .collection(_collectionName)
          .count()
          .get();
      if (snapshot.count == null) {
        return Result.ok(null);
      }
      return Result.ok(snapshot.count);
    } on FirebaseException catch (_) {
      return Result.error(const DhikrGetCountFailed());
    } catch (_) {
      return Result.error(const DhikrGetCountFailed());
    }
  }
}
