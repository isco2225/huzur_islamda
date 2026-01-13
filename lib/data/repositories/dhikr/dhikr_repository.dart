import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/dhikr/models/dhikr.dart';

/// Abstract repository for Dhikr operations
///
/// Provides methods for both local (Hive) and remote (Firestore) storage
abstract class DhikrRepository {
  ValueListenable<List<Dhikr>> get dhikrsLocally;
  // Local operations (Hive)
  Future<Result<Dhikr>> saveDhikrLocally(Dhikr dhikr);
  Future<Result<Dhikr?>> getDhikrLocally(String id);
  Future<Result<void>> getAllDhikrsLocally();
  Future<Result<void>> deleteDhikrLocally(String id);
  Future<Result<void>> clearAllDhikrsLocally();
  Future<Result<void>> updateDhikrLocally(String id, Dhikr dhikr);
  // Remote operations (Firestore)
  Future<Result<void>> saveDhikrToFirestore(Dhikr dhikr);
  Future<Result<Dhikr?>> getDhikrFromFirestore(String id);
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore(String userId);
  Future<Result<void>> deleteDhikrFromFirestore(String id);
  Future<Result<List<Dhikr>>> getUnsyncedDhikrs();

  // Sync operations
  Future<Result<void>> syncDhikrs(String userId);
}
