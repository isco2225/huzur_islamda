import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/dhikr/models/dhikr.dart';

/// Abstract repository for Dhikr operations
///
/// Provides methods for both local (Hive) and remote (Firestore) storage
abstract class DhikrRepository {
  ValueListenable<List<Dhikr>> get dhikrsLocally;
  // Local operations (Hive)
  Future<Result<void>> loadAllDhikrsLocally();
  Future<Result<void>> saveDhikrLocally({required Dhikr dhikr});
  Future<Result<Dhikr?>> getDhikrLocally({required String dhikrId});
  Future<Result<List<Dhikr>?>> getAllDhikrsByDateLocally({
    required DateTime date,
  });
  Future<Result<void>> deleteDhikrLocally({required String dhikrId});
  Future<Result<int>> getDhikrsCountLocally();
  Future<Result<void>> clearAllDhikrsLocally();
  Future<Result<void>> updateDhikrLocally({
    required String dhikrId,
    required Dhikr dhikr,
  });
  Future<Result<void>> createDhikrsForPrayer({required List<Dhikr> dhikrs});

  Future<Result<List<Dhikr>>> getDhikrsByGroupId({required String groupId});

  Future<Result<void>> syncDhikrsToLocally({required String userId});
  // Remote operations (Firestore)
  Future<Result<void>> syncDhikrsToFirestore({required String userId});
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore({
    required String userId,
  });
  Future<Result<void>> deleteDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  });

  Future<Result<int?>> getFirestoreDhikrsCount({required String userId});

  Future<Result<List<Dhikr>?>> getUnsyncedDhikrs();
}
