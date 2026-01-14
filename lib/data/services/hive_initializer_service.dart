import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../domain/dhikr/models/dhikr.dart';

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

    // TODO(omran): Register other model adapters here (User, Post, etc.)
  }
}
