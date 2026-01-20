import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app.dart';

class SharedPreferencesService {
  final _log = Logger('SharedPreferencesService');

  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get _prefs async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<Result<Map<String, Object?>?>> fetchJson({required String key}) async {
    try {
      final sharedPreferences = await _prefs;
      final jsonEncoded = sharedPreferences.getString(key);
      if (jsonEncoded == null) {
        _log.fine('No value in SharedPreferences');
        return Result.ok(null);
      }
      final json = jsonDecode(jsonEncoded) as Map<String, dynamic>;
      return Result.ok(json);
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Result.error(e);
    }
  }

  Future<Result<dynamic>> saveJson({
    required String key,
    required Map<String, Object?> json,
  }) async {
    try {
      final sharedPreferences = await _prefs;
      final jsonEncoded = jsonEncode(json);
      final isSaved = await sharedPreferences.setString(key, jsonEncoded);
      if (!isSaved) {
        _log.warning('Failed to save');
        return Result.error(Exception());
      }
      _log.info('Saved JSON to SharedPreferences: $key');
      return Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to save', e);
      return Result.error(e);
    }
  }
}
