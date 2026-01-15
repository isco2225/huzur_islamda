import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class HiveInitializerService {
  HiveInitializerService() : _log = Logger('HiveInitializer');

  final Logger _log;
  bool _isInitialized = false;

  /// Initialize Hive and register all adapters.
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      _log.info('Hive already initialized, skipping...');
      return Result.ok(null);
    }
    try {
      _log.info('Initializing Hive...');
      await Hive.initFlutter();
      _registerAdapters();
      _isInitialized = true;
      _log.info('Hive initialized successfully');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Failed to initialize Hive: $e');
      return Result.error(Exception('Failed to initialize Hive: $e'));
    }
  }

  void _registerAdapters() {
    // Dhikr
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DhikrAdapter());
      _log.info('Registered DhikrAdapter');
    }

    // Prayer
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PrayerAdapter());
      _log.info('Registered PrayerAdapter');
    }

    // PrayerTimes
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PrayerTimesAdapter());
      _log.info('Registered PrayerTimesAdapter');
    }

    // TODO(omran): Register other model adapters here (User, Post, etc.)
  }
}
