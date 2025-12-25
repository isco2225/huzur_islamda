import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class DhikrRepository {
  ValueListenable<List<Dhikr>> get dhikrs;

  Future<Result<Dhikr>> createDhikr({
    required String userId,
    required String name,
    required int targetCount,
  });

  Future<Result<Dhikr>> updateDhikr({
    required String dhikrId,
    required String name,
    required int targetCount,
  });

  Future<Result<List<Dhikr>>> fetchDhikrs({required String userId});

  Future<Result<List<Dhikr>>> fetchDhikrsByDay({
    required String userId,
    required DateTime day,
  });

  Future<Result<void>> deleteDhikr({required String dhikrId});
}
