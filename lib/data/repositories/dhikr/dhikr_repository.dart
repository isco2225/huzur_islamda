import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/dhikr/models/dhikr.dart';

/// Abstract repository for Dhikr operations
///
/// Provides methods for both local (Hive) and remote (Firestore) storage
abstract class DhikrRepository {
  ValueListenable<List<Dhikr>> get dhikrsLocally;
  // Local operations (Hive)
  Future<Result<Dhikr>> saveDhikrLocally({required Dhikr dhikr});
  Future<Result<Dhikr?>> getDhikrLocally({required String dhikrId});
  Future<Result<void>> getAllDhikrsLocally();
  Future<Result<void>> deleteDhikrLocally({required String dhikrId});
  Future<Result<void>> clearAllDhikrsLocally();
  Future<Result<void>> updateDhikrLocally({
    required String dhikrId,
    required Dhikr dhikr,
  });
  // Remote operations (Firestore)
  Future<Result<void>> saveDhikrToFirestore({required Dhikr dhikr});
  Future<Result<Dhikr?>> getDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  });
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore({
    required String userId,
  });
  Future<Result<void>> deleteDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  });
  Future<Result<List<Dhikr>>> getUnsyncedDhikrs();

  // Sync operations
  Future<Result<void>> syncDhikrs({required String userId});
}
