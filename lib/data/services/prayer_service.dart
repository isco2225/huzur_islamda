import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../app/app.dart';

class PrayerService {
  PrayerService() : _log = Logger('PrayerService');

  final Logger _log;
  static const String _baseUrl = 'https://api.ezanvakti.imsakiyem.com';

  /// API'den yıllık namaz vakitlerini getirir
  ///
  /// [districtId]: İlçe ID'si
  /// [year]: Yıl (örn: 2024)
  ///
  /// Returns: API response JSON'u (Prayer.fromApiJson ile parse edilebilir)
  Future<Result<Map<String, dynamic>>> getPrayerTimes({
    required String districtId,
    required int year,
  }) async {
    try {
      _log.info('Fetching prayer times for district: $districtId, year: $year');

      final uri = Uri.parse(
        '$_baseUrl/prayer-times?district_id=$districtId&year=$year',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        _log.info('Successfully fetched prayer times');
        return Result.ok(jsonData);
      } else {
        _log.severe(
          'Failed to fetch prayer times: ${response.statusCode} - ${response.body}',
        );
        return Result.error(
          Exception('Failed to fetch prayer times: ${response.statusCode}'),
        );
      }
    } on http.ClientException catch (e) {
      _log.severe('Network error while fetching prayer times: $e');
      return Result.error(Exception('Network error: ${e.message}'));
    } catch (e) {
      _log.severe('Unexpected error while fetching prayer times: $e');
      return Result.error(Exception('Failed to fetch prayer times: $e'));
    }
  }
}
