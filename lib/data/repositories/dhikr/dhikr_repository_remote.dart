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
  Future<Result<Dhikr>> saveDhikrLocally({required Dhikr dhikr}) async {
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
  Future<Result<Dhikr?>> getDhikrLocally({required String dhikrId}) async {
    _log.info('Getting dhikr locally: $dhikrId');
    final result = await _hiveService.getById(dhikrId);
    if (result is Error<Dhikr?>) {
      return Result.error(result.asError.error);
    }

    // Sadece dhikr'ı döndür, listeye dokunma
    // Liste güncellemeleri diğer fonksiyonlar tarafından yapılır
    return Result.ok(result.asOk.value);
  }

  @override
  Future<Result<List<Dhikr>?>> getAllDhikrsByDateLocally({
    required DateTime date,
  }) async {
    _log.info('Getting all dhikrs locally for date: $date');
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final result = await _hiveService.getWithFilter((dhikr) {
      final dhikrDate = DateTime(
        dhikr.day.year,
        dhikr.day.month,
        dhikr.day.day,
      );
      return dhikrDate.year == normalizedDate.year &&
          dhikrDate.month == normalizedDate.month &&
          dhikrDate.day == normalizedDate.day;
    });
    switch (result) {
      case Ok():
        final dhikrs = result.asOk.value;
        return Result.ok(dhikrs);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> deleteDhikrLocally({required String dhikrId}) async {
    _log.info('Deleting dhikr locally: $dhikrId');
    final result = await _hiveService.delete(dhikrId);
    switch (result) {
      case Ok():
        _dhikrsLocally.value = _dhikrsLocally.value
            .where((d) => d.id != dhikrId)
            .toList();
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<int>> getDhikrsCountLocally() async {
    _log.info('Getting dhikrs count locally');
    final result = await _hiveService.count();
    switch (result) {
      case Ok():
        return Result.ok(result.asOk.value);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<int?>> getFirestoreDhikrsCount({required String userId}) async {
    _log.info('Getting firebase dhikrs count for user: $userId');
    final result = await _firestoreDhikrService.getDhikrsCount(userId: userId);
    switch (result) {
      case Ok():
        return Result.ok(result.asOk.value);
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
  Future<Result<void>> updateDhikrLocally({
    required String dhikrId,
    required Dhikr dhikr,
  }) async {
    _log.info('Updating dhikr locally: $dhikrId');

    final result = await _hiveService.update(dhikrId, dhikr);

    switch (result) {
      case Ok():
        _dhikrsLocally.value = _dhikrsLocally.value
            .map((d) => d.id == dhikrId ? result.asOk.value : d)
            .toList();
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  // ========== REMOTE OPERATIONS (FIRESTORE) ==========

  @override
  Future<Result<void>> saveDhikrToFirestore({required Dhikr dhikr}) async {
    _log.info('Saving dhikr to Firestore: ${dhikr.id}');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  @override
  Future<Result<Dhikr?>> getDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  }) async {
    _log.info('Getting dhikr from Firestore: $dhikrId');
    // TODO: Firestore implementation
    return Result.error(Exception('Not implemented yet'));
  }

  @override
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore({
    required String userId,
  }) async {
    _log.info('Getting all dhikrs from Firestore for user: $userId');
    final result = await _firestoreDhikrService.fetchAllDhikrs(userId: userId);
    switch (result) {
      case Ok():
        return Result.ok(result.asOk.value);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> deleteDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  }) async {
    _log.info('Deleting dhikr from Firestore: $dhikrId');
    final result = await _firestoreDhikrService.deleteDhikr(
      userId: userId,
      dhikrId: dhikrId,
    );
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  // ========== SYNC OPERATIONS ==========

  @override
  Future<Result<List<Dhikr>?>> getUnsyncedDhikrs() async {
    _log.info('Getting unsynced dhikrs');
    final result = await _hiveService.getWithFilter((dhikr) => !dhikr.isSynced);
    switch (result) {
      case Ok():
        final unsyncedDhikrs = result.asOk.value;
        if (unsyncedDhikrs == null) {
          _log.info('No unsynced dhikrs found');
          return Result.ok(null);
        }
        _log.info('Found ${unsyncedDhikrs.length} unsynced dhikrs');
        return Result.ok(unsyncedDhikrs);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  // sync to firestore (upload unsynced local dhikrs)
  Future<Result<void>> syncDhikrs({required String userId}) async {
    _log.info('Uploading unsynced dhikrs to Firestore');
    final unsyncedResult = await getUnsyncedDhikrs();
    switch (unsyncedResult) {
      case Ok():
        final unsyncedDhikrs = unsyncedResult.asOk.value;
        if (unsyncedDhikrs == null || unsyncedDhikrs.isEmpty) {
          _log.info('No unsynced dhikrs found');
          return Result.ok(null);
        }
        _log.info('Found ${unsyncedDhikrs.length} unsynced dhikrs to upload');
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
                dhikrId: dhikr.id,
                dhikr: dhikr.copyWith(isSynced: true),
              );
            }
            _log.info('Successfully synced ${unsyncedDhikrs.length} dhikrs');
            return Result.ok(null);
          case Error():
            return Result.error(firestoreResult.asError.error);
        }
      case Error():
        return Result.error(unsyncedResult.asError.error);
    }
  }
}
