import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../data.dart';

class DhikrRepositoryRemote extends DhikrRepository {
  DhikrRepositoryRemote({
    required FirestoreDhikirService firestoreDhikirService,
    required HiveService hiveDhikirService,
  }) : _firestoreDhikirService = firestoreDhikirService,
       _hiveDhikirService = hiveDhikirService;
  final FirestoreDhikirService _firestoreDhikirService;
  final HiveService _hiveDhikirService;

  @override
  ValueListenable<List<Dhikr>> get dhikrs => _dhikrs;
  final ValueNotifier<List<Dhikr>> _dhikrs = ValueNotifier<List<Dhikr>>([]);

  @override
  Future<Result<Dhikr>> createDhikr({
    required String userId,
    required String name,
    required int targetCount,
  }) {
    // TODO: implement createDhikr
    throw UnimplementedError();
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
  Future<Result<List<Dhikr>>> fetchTodayDhikrs({required String userId}) {
    // TODO: implement fetchTodayDhikrs
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Dhikr>>> fetchDhikrsByDay({
    required String userId,
    required DateTime day,
  }) {
    // TODO: implement fetchDhikrsByDay
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteDhikr({required String dhikrId}) {
    // TODO: implement deleteDhikr
    throw UnimplementedError();
  }
}
