import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../data.dart';

class DhikrRepositoryRemote extends DhikrRepository {
  DhikrRepositoryRemote({required FirestoreDhikrService firestoreDhikirService})
    : _firestoreDhikirService = firestoreDhikirService;
  final FirestoreDhikrService _firestoreDhikirService;

  @override
  ValueListenable<List<Dhikr>> get dhikrs => _dhikrs;
  final ValueNotifier<List<Dhikr>> _dhikrs = ValueNotifier<List<Dhikr>>([]);

  @override
  Future<Result<Dhikr>> createDhikr({
    required String userId,
    required String name,
    required int targetCount,
  }) async {
    try {
      final result = await _firestoreDhikirService.createDhikr(
        userId: userId,
        name: name,
        targetCount: targetCount,
      );
      switch (result) {
        case Ok():
          _dhikrs.value = [..._dhikrs.value, result.asOk.value];
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to create dhikr: $e'));
    }
  }

  @override
  Future<Result<Dhikr>> updateDhikr({
    required String dhikrId,
    required String name,
    required int targetCount,
  }) {
    // TODO: implement updateDhikr
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Dhikr>>> fetchDhikrs({required String userId}) async {
    try {
      final result = await _firestoreDhikirService.fetchAllDhikrs(
        userId: userId,
      );
      switch (result) {
        case Ok():
          _dhikrs.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch dhikrs: $e'));
    }
  }

  @override
  Future<Result<List<Dhikr>>> fetchDhikrsByDay({
    required String userId,
    required DateTime day,
  }) async {
    try {
      final result = await _firestoreDhikirService.fetchDhikrs(
        userId: userId,
        day: day,
      );
      switch (result) {
        case Ok():
          _dhikrs.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch dhikrs by day: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDhikr({required String dhikrId}) {
    // TODO: implement deleteDhikr
    throw UnimplementedError();
  }
}
