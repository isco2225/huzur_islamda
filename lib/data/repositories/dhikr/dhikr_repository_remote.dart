import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/dhikr/models/dhikr.dart';
import '../../data.dart';

/// Remote implementation of DhikrRepository
///
/// Handles both local (Hive) and remote (Firestore) operations
class DhikrRepositoryRemote implements DhikrRepository {
  DhikrRepositoryRemote({
    required HiveService<Dhikr> hiveService,
    required FirestoreDhikrService firestoreDhikrService,
  }) : _hiveService = hiveService,
       _firestoreDhikrService = firestoreDhikrService,
       _log = Logger('DhikrRepositoryRemote');

  final HiveService<Dhikr> _hiveService;
  final FirestoreDhikrService _firestoreDhikrService;
  final Logger _log;
  @override
  ValueListenable<List<Dhikr>> get dhikrsLocally => _dhikrsLocally;
  final ValueNotifier<List<Dhikr>> _dhikrsLocally = ValueNotifier<List<Dhikr>>(
    [],
  );

  @override
  Future<Result<Dhikr>> saveDhikrLocally(Dhikr dhikr) async {
    _log.info('Saving dhikr locally: ${dhikr.id}');
    final result = await _hiveService.save(dhikr.id, dhikr);
    switch (result) {
      case Ok():
        _dhikrsLocally.value = [result.asOk.value, ..._dhikrsLocally.value];
        return Result.ok(result.asOk.value);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<Dhikr?>> getDhikrLocally(String id) async {
    _log.info('Getting dhikr locally: $id');
    final result = await _hiveService.getById(id);
    if (result is Error<Dhikr?>) {
      return Result.error(result.asError.error);
    }

    // Sadece dhikr'ı döndür, listeye dokunma
    // Liste güncellemeleri diğer fonksiyonlar tarafından yapılır
    return Result.ok(result.asOk.value);
  }

  @override
  Future<Result<void>> getAllDhikrsLocally() async {
    _log.info('Getting all dhikrs locally');
    final result = await _hiveService.getAll();
    switch (result) {
      case Ok():
        _dhikrsLocally.value = result.asOk.value;
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> deleteDhikrLocally(String id) async {
    _log.info('Deleting dhikr locally: $id');
    final result = await _hiveService.delete(id);
    switch (result) {
      case Ok():
        _dhikrsLocally.value = _dhikrsLocally.value
            .where((d) => d.id != id)
            .toList();
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> clearAllDhikrsLocally() async {
    _log.info('Clearing all dhikrs locally');
    final result = await _hiveService.clear();
    switch (result) {
      case Ok():
        _dhikrsLocally.value = [];
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> updateDhikrLocally(String id, Dhikr dhikr) async {
    _log.info('Updating dhikr locally: $id');

    final result = await _hiveService.update(id, dhikr);

    switch (result) {
      case Ok():
        _dhikrsLocally.value = _dhikrsLocally.value
            .map((d) => d.id == id ? result.asOk.value : d)
            .toList();
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  // ========== REMOTE OPERATIONS (FIRESTORE) ==========

  @override
  Future<Result<void>> saveDhikrToFirestore(Dhikr dhikr) async {
    _log.info('Saving dhikr to Firestore: ${dhikr.id}');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  @override
  Future<Result<Dhikr?>> getDhikrFromFirestore(String id) async {
    _log.info('Getting dhikr from Firestore: $id');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  @override
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore(String userId) async {
    _log.info('Getting all dhikrs from Firestore for user: $userId');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  @override
  Future<Result<void>> deleteDhikrFromFirestore(String id) async {
    _log.info('Deleting dhikr from Firestore: $id');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  // ========== SYNC OPERATIONS ==========

  @override
  Future<Result<List<Dhikr>>> getUnsyncedDhikrs() async {
    _log.info('Getting unsynced dhikrs');
    final result = await _hiveService.getAll();
    switch (result) {
      case Ok():
        final unsynced = result.asOk.value.where((d) => !d.isSynced).toList();
        _log.info('Found ${unsynced.length} unsynced dhikrs');
        return Result.ok(unsynced);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  // sync to firestore
  Future<Result<void>> syncDhikrs(String userId) async {
    // get unsynced dhikrs
    final result = await getUnsyncedDhikrs();
    switch (result) {
      case Ok():
        final unsyncedDhikrs = result.asOk.value;
        if (unsyncedDhikrs.isEmpty) {
          _log.info('No unsynced dhikrs found');
          return Result.ok(null);
        }
        // save to firestore
        final firestoreResult = await _firestoreDhikrService.saveDhikrs(
          userId: userId,
          dhikrs: unsyncedDhikrs,
        );
        switch (firestoreResult) {
          case Ok():
            // mark as synced in local storage
            for (final dhikr in unsyncedDhikrs) {
              await updateDhikrLocally(
                dhikr.id,
                dhikr.copyWith(isSynced: true),
              );
            }
            return Result.ok(null);
          case Error():
            return Result.error(
              firestoreResult.asError.error,
            ); // TODO(Omran): Check it after
        }

      case Error<List<Dhikr>>():
        return Result.error(result.asError.error);
    }
  }
}
