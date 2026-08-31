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
      final decoded = jsonDecode(jsonEncoded);
      if (decoded is! Map<String, dynamic>) {
        _log.warning('Stored value for "$key" is not a JSON object');
        return Result.error(
          FormatException('Stored value for "$key" is not a JSON object'),
        );
      }
      return Result.ok(decoded);
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
    } on JsonUnsupportedObjectError catch (e) {
      // jsonEncode reports unsupported values as an Error, not an Exception.
      _log.warning('Failed to encode JSON for "$key"', e);
      return Result.error(Exception('Value for "$key" is not JSON encodable'));
    } on Exception catch (e) {
      _log.warning('Failed to save', e);
      return Result.error(e);
    }
  }
}
