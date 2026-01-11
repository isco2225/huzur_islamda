import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class CountryService {
  final _log = Logger('CountryService');

  static const String _baseUrl =
      'https://ezanvakti.imsakiyem.com/api/locations/countries';

  static const Duration _timeout = Duration(seconds: 10);

  Future<Result<List<Country>>> getCountries() async {
    try {
      _log.info('Getting countries...');

      final uri = Uri.parse(_baseUrl);
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);
      _log.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (!jsonResponse.containsKey('data')) {
          _log.severe('Response "data" field not found');
          return Result.error(Exception('Invalid API response'));
        }

        final dynamic dataField = jsonResponse['data'];

        if (dataField is! List) {
          _log.severe('data field is not a List: ${dataField.runtimeType}');
          return Result.error(Exception('Invalid data format'));
        }

        final List<Country> countries = [];
        for (var item in dataField) {
          try {
            if (item is Map<String, dynamic>) {
              countries.add(Country.fromJson(item));
            }
          } catch (e) {
            _log.warning('Country parse error: $e');
            // Continue, try to parse other countries
          }
        }

        if (countries.isEmpty) {
          _log.warning('No countries parsed');
          return Result.error(Exception('No countries parsed'));
        }

        _log.info('${countries.length} countries successfully loaded');
        return Result.ok(countries);
      } else {
        _log.warning('Countries not fetched: ${response.statusCode}');
        return Result.error(
          Exception('Countries not fetched (HTTP ${response.statusCode})'),
        );
      }
    } on http.ClientException catch (e) {
      _log.severe('Network error: $e');
      return Result.error(Exception('Network error: $e'));
    } on FormatException catch (e) {
      _log.severe('JSON parse error: $e');
      return Result.error(Exception('JSON parse error: $e'));
    } catch (e) {
      _log.severe('Unexpected error: $e');
      return Result.error(Exception('Unexpected error: $e'));
    }
  }
}
