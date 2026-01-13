import '../../../app/app.dart';

abstract class HiveRepository {
  Future<Result<void>> initializeHive();
  Future<Result<void>> clear();
}
