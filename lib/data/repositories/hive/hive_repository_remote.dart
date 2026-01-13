import 'package:huzur_islamda/app/utils/result.dart';

import '../../data.dart';

class HiveRepositoryRemote implements HiveRepository {
  HiveRepositoryRemote({required HiveService hiveService})
    : _hiveService = hiveService;

  final HiveService _hiveService;

  @override
  Future<Result<void>> initializeHive() async {
    final result = await _hiveService.initializeHive();
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
