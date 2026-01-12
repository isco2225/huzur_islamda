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
    // TODO: Firestore service eklendiğinde buraya ekle
  }) : _hiveService = hiveService,
       _log = Logger('DhikrRepositoryRemote');

  final HiveService<Dhikr> _hiveService;
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

    return switch (result) {
      Ok(:final value) => () {
        final unsynced = value.where((d) => !d.isSynced).toList();
        _log.info('Found ${unsynced.length} unsynced dhikrs');
        return Result.ok(unsynced);
      }(),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> syncDhikrs(String userId) async {
    _log.info('Syncing dhikrs for user: $userId');

    // 1. Get unsynced dhikrs from local
    final unsyncedResult = await getUnsyncedDhikrs();

    return switch (unsyncedResult) {
      Ok(:final value) => await () async {
        if (value.isEmpty) {
          _log.info('No dhikrs to sync');
          return Result.ok(null);
        }

        // 2. Upload each unsynced dhikr to Firestore
        for (final dhikr in value) {
          if (dhikr.isDeleted) {
            // Delete from Firestore
            await deleteDhikrFromFirestore(dhikr.id);
            // Delete from local
            await deleteDhikrLocally(dhikr.id);
          } else {
            // Upload to Firestore
            final uploadResult = await saveDhikrToFirestore(dhikr);

            switch (uploadResult) {
              case Ok():
                // Mark as synced in local storage
                final syncedDhikr = dhikr.copyWith(isSynced: true);
                await saveDhikrLocally(syncedDhikr);
              case Error(:final error):
                _log.severe('Failed to sync dhikr ${dhikr.id}: $error');
            }
          }
        }

        _log.info('Sync completed');
        return Result.ok(null);
      }(),
      Error(:final error) => Result.error(error),
    };
  }
}
