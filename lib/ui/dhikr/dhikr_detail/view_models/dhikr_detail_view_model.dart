import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class DhikrDetailViewModel {
  DhikrDetailViewModel({
    required DhikrRepository dhikrRepository,
    required String dhikrId,
  }) : _dhikrRepository = dhikrRepository,
       _dhikrId = dhikrId,
       _log = Logger('DhikrDetailViewModel') {
    // Commands
    loadDhikr = Command0<void>(_loadDhikr, debugLabel: 'loadDhikr');
    incrementCount = Command0<void>(
      _incrementCount,
      debugLabel: 'incrementCount',
    );
    decrementCount = Command0<void>(
      _decrementCount,
      debugLabel: 'decrementCount',
    );
    deleteDhikr = Command0<void>(_deleteDhikr, debugLabel: 'deleteDhikr');
    resetCount = Command0<void>(_resetCount, debugLabel: 'resetCount');

    // Load dhikr on initialization
    loadDhikr.execute();
  }

  final DhikrRepository _dhikrRepository;
  final String _dhikrId;
  final Logger _log;

  // State
  final ValueNotifier<Dhikr?> _currentDhikr = ValueNotifier<Dhikr?>(null);
  ValueListenable<Dhikr?> get currentDhikr => _currentDhikr;

  // Commands
  late final Command0<void> loadDhikr;
  late final Command0<void> incrementCount;
  late final Command0<void> decrementCount;
  late final Command0<void> deleteDhikr;
  late final Command0<void> resetCount;

  // Computed values
  double get progress {
    final dhikr = _currentDhikr.value;
    if (dhikr == null || dhikr.targetCount == 0) return 0.0;
    return (dhikr.currentCount / dhikr.targetCount).clamp(0.0, 1.0);
  }

  int get remainingCount {
    final dhikr = _currentDhikr.value;
    if (dhikr == null) return 0;
    final remaining = dhikr.targetCount - dhikr.currentCount;
    return remaining > 0 ? remaining : 0;
  }

  // Functions
  Future<Result<void>> _loadDhikr() async {
    _log.info('Loading dhikr: $_dhikrId');

    final result = await _dhikrRepository.getDhikrLocally(_dhikrId);
    switch (result) {
      case Ok():
        _currentDhikr.value = result.asOk.value;
        _log.info('Dhikr loaded successfully: $_dhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _incrementCount() async {
    final dhikr = _currentDhikr.value;
    if (dhikr == null) {
      return Result.error(Exception('Zikir yüklenmedi'));
    }

    _log.info('Incrementing count for dhikr: $_dhikrId');

    final updatedDhikr = dhikr.copyWith(
      currentCount: dhikr.currentCount + 1,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: (dhikr.currentCount + 1) >= dhikr.targetCount,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      _dhikrId,
      updatedDhikr,
    );
    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_dhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _decrementCount() async {
    final dhikr = _currentDhikr.value;
    if (dhikr == null) {
      return Result.error(Exception('Zikir yüklenmedi'));
    }

    if (dhikr.currentCount == 0) {
      return Result.error(Exception('Sayı 0\'dan küçük olamaz'));
    }

    _log.info('Decrementing count for dhikr: $_dhikrId');

    final newCount = dhikr.currentCount - 1;
    final updatedDhikr = dhikr.copyWith(
      currentCount: newCount,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: newCount >= dhikr.targetCount,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      _dhikrId,
      updatedDhikr,
    );

    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_dhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _resetCount() async {
    final dhikr = _currentDhikr.value;
    if (dhikr == null) {
      return Result.error(Exception('Zikir yüklenmedi'));
    }

    _log.info('Resetting count for dhikr: $_dhikrId');

    final updatedDhikr = dhikr.copyWith(
      currentCount: 0,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: false,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      _dhikrId,
      updatedDhikr,
    );
    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_dhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _deleteDhikr() async {
    _log.info('Deleting dhikr: $_dhikrId');

    final result = await _dhikrRepository.deleteDhikrLocally(_dhikrId);
    switch (result) {
      case Ok():
        _currentDhikr.value = null;
        _log.info('Dhikr deleted successfully: $_dhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  void dispose() {
    loadDhikr.dispose();
    incrementCount.dispose();
    decrementCount.dispose();
    deleteDhikr.dispose();
    resetCount.dispose();
    _currentDhikr.dispose();
    _log.info('DhikrDetailViewModel disposed');
  }
}
