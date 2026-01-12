import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';

/// Generic Hive service for CRUD operations on local storage.
///
/// This service provides type-safe CRUD operations for any Hive model.
/// Simply create an instance with a box name and model type.
class HiveService<T> {
  HiveService(this.boxName) : _log = Logger('HiveService<$T>');

  final String boxName;
  final Logger _log;
  Box<T>? _box;

  /// Get the box instance (lazy initialization)
  Future<Box<T>> get _getBox async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<T>(boxName);
    _log.info('Opened Hive box: $boxName');
    return _box!;
  }

  /// Save a single item to the box
  Future<Result<void>> save(String key, T value) async {
    try {
      final box = await _getBox;
      await box.put(key, value);
      _log.info('Saved item with key: $key');
      return Result.ok(null);
    } on HiveError catch (e) {
      _log.severe('Hive error saving item: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to save item: $e');
      return Result.error(Exception('Failed to save item: $e'));
    }
  }

  /// Save multiple items to the box
  Future<Result<void>> saveAll(Map<String, T> entries) async {
    try {
      final box = await _getBox;
      await box.putAll(entries);
      _log.info('Saved ${entries.length} items');
      return Result.ok(null);
    } on HiveError catch (e) {
      _log.severe('Hive error saving items: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to save items: $e');
      return Result.error(Exception('Failed to save items: $e'));
    }
  }

  /// Get a single item from the box by key
  Future<Result<T?>> getById(String key) async {
    try {
      final box = await _getBox;
      final value = box.get(key);
      _log.info('Retrieved item with key: $key');
      return Result.ok(value);
    } on HiveError catch (e) {
      _log.severe('Hive error getting item: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to get item: $e');
      return Result.error(Exception('Failed to get item: $e'));
    }
  }

  /// Get all items from the box as a list
  Future<Result<List<T>>> getAll() async {
    try {
      final box = await _getBox;
      final values = box.values.toList();
      _log.info('Retrieved ${values.length} items');
      return Result.ok(values);
    } on HiveError catch (e) {
      _log.severe('Hive error getting all items: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to get all items: $e');
      return Result.error(Exception('Failed to get items: $e'));
    }
  }

  /// Get all items as a map (key -> value)
  Future<Result<Map<String, T>>> getAllAsMap() async {
    try {
      final box = await _getBox;
      final map = <String, T>{};
      for (var key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          map[key.toString()] = value;
        }
      }
      _log.info('Retrieved ${map.length} items as map');
      return Result.ok(map);
    } on HiveError catch (e) {
      _log.severe('Hive error getting map: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to get map: $e');
      return Result.error(Exception('Failed to get map: $e'));
    }
  }

  /// Get all keys in the box
  Future<Result<List<String>>> getAllKeys() async {
    try {
      final box = await _getBox;
      final keys = box.keys.map((k) => k.toString()).toList();
      _log.info('Retrieved ${keys.length} keys');
      return Result.ok(keys);
    } on HiveError catch (e) {
      _log.severe('Hive error getting keys: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to get keys: $e');
      return Result.error(Exception('Failed to get keys: $e'));
    }
  }

  /// Check if a key exists
  Future<Result<bool>> exists(String key) async {
    try {
      final box = await _getBox;
      final exists = box.containsKey(key);
      return Result.ok(exists);
    } on HiveError catch (e) {
      _log.severe('Hive error checking key: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to check key: $e');
      return Result.error(Exception('Failed to check key: $e'));
    }
  }

  /// Get the number of items in the box
  Future<Result<int>> count() async {
    try {
      final box = await _getBox;
      final length = box.length;
      return Result.ok(length);
    } on HiveError catch (e) {
      _log.severe('Hive error getting count: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to get count: $e');
      return Result.error(Exception('Failed to get count: $e'));
    }
  }

  /// Delete a single item by key
  Future<Result<void>> delete(String key) async {
    try {
      final box = await _getBox;
      await box.delete(key);
      _log.info('Deleted item with key: $key');
      return Result.ok(null);
    } on HiveError catch (e) {
      _log.severe('Hive error deleting item: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to delete item: $e');
      return Result.error(Exception('Failed to delete item: $e'));
    }
  }

  /// Delete multiple items by keys
  Future<Result<void>> deleteMany(List<String> keys) async {
    try {
      final box = await _getBox;
      await box.deleteAll(keys);
      _log.info('Deleted ${keys.length} items');
      return Result.ok(null);
    } on HiveError catch (e) {
      _log.severe('Hive error deleting items: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to delete items: $e');
      return Result.error(Exception('Failed to delete items: $e'));
    }
  }

  /// Clear all items in the box
  Future<Result<void>> clear() async {
    try {
      final box = await _getBox;
      await box.clear();
      _log.info('Cleared all items from box: $boxName');
      return Result.ok(null);
    } on HiveError catch (e) {
      _log.severe('Hive error clearing box: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to clear box: $e');
      return Result.error(Exception('Failed to clear box: $e'));
    }
  }

  /// Check if the box is empty
  Future<Result<bool>> isEmpty() async {
    try {
      final box = await _getBox;
      return Result.ok(box.isEmpty);
    } on HiveError catch (e) {
      _log.severe('Hive error checking if empty: ${e.message}');
      return Result.error(Exception('Hive error: ${e.message}'));
    } catch (e) {
      _log.severe('Failed to check if empty: $e');
      return Result.error(Exception('Failed to check if empty: $e'));
    }
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
    _log.info('Closed Hive box: $boxName');
  }
}
