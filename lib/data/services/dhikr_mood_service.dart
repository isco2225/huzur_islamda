import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class DhikrMoodService {
  DhikrMoodService() : _log = Logger('DhikrMoodService');

  final Logger _log;

  static const String _moodsJsonPath =
      'assets/data/dhikrs/dhikrs_for_emotions.json';

  Future<Result<List<Mood>>> getDhikrMoods() async {
    try {
      _log.info('Loading dhikr moods from $_moodsJsonPath');

      final jsonString = await rootBundle.loadString(_moodsJsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final moodsJson = json['moods'] as List<dynamic>? ?? [];

      final moods = moodsJson
          .map((e) => Mood.fromJson(e as Map<String, Object?>))
          .toList();

      _log.info('Loaded ${moods.length} moods');
      return Result.ok(moods);
    } catch (e) {
      _log.severe('Failed to load moods: $e');
      return Result.error(UserMessageException('Ruh halleri yüklenemedi', cause: e));
    }
  }
}
