import 'package:hive/hive.dart';

import '../../app/app.dart';

class HiveService {
  final Box _box = Hive.box('huzur_islamda_box');

  /// put
  Future<Result<void>> put({
    required String key,
    required dynamic value,
  }) async {
    try {
      await _box.put(key, value);
      return Result.ok(null);
    } on HiveError catch (e) {
      return Result.error(Exception('Failed to put data: ${e.message}'));
    } catch (e) {
      return Result.error(Exception('Failed to put data: $e'));
    }
  }

  /// get
  Future<dynamic> read({required String key}) async {
    return await _box.get(key);
  }

  /// delete
  Future<void> delete({required String key}) async {
    await _box.delete(key);
  }

  /// clear
  Future<void> clear() async {
    await _box.clear();
  }

  /// close
  Future<void> close() async {
    await _box.close();
  }
}
