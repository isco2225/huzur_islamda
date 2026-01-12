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

  @override
  Future<Result<void>> delete(String key) async {
    final result = await _hiveService.delete(key);
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<dynamic>> get(String key) async {
    final result = await _hiveService.getById(key);
    switch (result) {
      case Ok():
        return Result.ok(result.asOk.value);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> save(String key, value) async {
    final result = await _hiveService.save(key, value);
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> update(String key, dynamic value) async {
    final result = await _hiveService.update(key, value);
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }
}
