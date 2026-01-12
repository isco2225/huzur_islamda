import '../../../app/app.dart';

abstract class HiveRepository {
  Future<Result<void>> initializeHive();
  Future<Result<void>> save(String key, dynamic value);
  Future<Result<dynamic>> get(String key);
  Future<Result<void>> delete(String key);
  Future<Result<void>> clear();
  Future<Result<void>> update(String key, dynamic value);
}
