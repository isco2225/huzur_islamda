import 'package:huzur_islamda/app/utils/result.dart';

import '../../data.dart';

class HiveRepositoryRemote implements HiveRepository {
  HiveRepositoryRemote({
    required HiveInitializerService hiveInitializer,
    required HiveService hiveService,
  }) : _hiveInitializer = hiveInitializer,
       _hiveService = hiveService;

  final HiveInitializerService _hiveInitializer;
  final HiveService _hiveService;

  @override
  Future<Result<void>> initializeHive() async {
    final result = await _hiveInitializer.initialize();
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> clear() async {
    final result = await _hiveService.clear();
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }
}
