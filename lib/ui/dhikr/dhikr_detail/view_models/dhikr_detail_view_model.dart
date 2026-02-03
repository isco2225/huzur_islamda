import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class DhikrDetailViewModel {
  DhikrDetailViewModel({
    required DhikrRepository dhikrRepository,
    required DhikrUseCase dhikrUseCase,
    required String initialDhikrId,
    List<String>? groupDhikrIds, // if null, that means single dhikr mode
  }) : _dhikrRepository = dhikrRepository,
       _dhikrUseCase = dhikrUseCase,
       _initialDhikrId = initialDhikrId,
       _groupDhikrIds = groupDhikrIds,
       _currentDhikrId = initialDhikrId,
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

    loadDhikr.execute();
  }

  final DhikrRepository _dhikrRepository;
  final DhikrUseCase _dhikrUseCase;
  final String _initialDhikrId;
  final List<String>? _groupDhikrIds;
  final Logger _log;

  /// Currently displayed dhikr id (changes in group mode when advancing).
  String _currentDhikrId;
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
    // In group mode, on first load resolve to first incomplete dhikr
    final groupIds = _groupDhikrIds;
    if (groupIds != null &&
        groupIds.isNotEmpty &&
        _currentDhikrId == _initialDhikrId) {
      var foundFirstIncomplete = false;
      for (final id in groupIds) {
        final r = await _dhikrRepository.getDhikrLocally(dhikrId: id);
        switch (r) {
          case Ok():
            final d = r.asOk.value;
            if (d != null && d.currentCount < d.targetCount) {
              _currentDhikrId = id;
              foundFirstIncomplete = true;
              break;
            }
          case Error():
            break;
        }
        if (foundFirstIncomplete) break;
      }
    }

    _log.info('Loading dhikr: $_currentDhikrId');

    final result = await _dhikrRepository.getDhikrLocally(
      dhikrId: _currentDhikrId,
    );
    switch (result) {
      case Ok():
        _currentDhikr.value = result.asOk.value;
        _log.info('Dhikr loaded successfully: $_currentDhikrId');
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

    _log.info('Incrementing count for dhikr: $_currentDhikrId');

    final updatedDhikr = dhikr.copyWith(
      currentCount: dhikr.currentCount + 1,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: (dhikr.currentCount + 1) >= dhikr.targetCount,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      dhikrId: _currentDhikrId,
      dhikr: updatedDhikr,
    );
    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_currentDhikrId');

        // if dhikr is completed, cancel today's dhikr reminder
        if (updatedDhikr.isCompleted) {
          try {
            final cancelResult = await _dhikrUseCase
                .cancelTodayDhikrReminderIfAllCompleted();
            switch (cancelResult) {
              case Ok():
                _log.info(
                  'Checked and possibly cancelled today\'s dhikr reminder after completion',
                );
              case Error():
                _log.warning(
                  'Failed to cancel today\'s dhikr reminder after completion: ${cancelResult.asError.error}',
                );
            }
          } catch (e) {
            _log.warning(
              'Exception while cancelling today\'s dhikr reminder after completion: $e',
            );
          }
        }

        // In group mode, when current dhikr just completed, advance to next incomplete
        final groupIds = _groupDhikrIds;
        if (updatedDhikr.currentCount >= updatedDhikr.targetCount &&
            groupIds != null &&
            groupIds.isNotEmpty) {
          final currentIndex = groupIds.indexWhere(
            (id) => id == _currentDhikrId,
          );
          if (currentIndex >= 0 && currentIndex < groupIds.length - 1) {
            final nextIds = groupIds.sublist(currentIndex + 1);
            for (final id in nextIds) {
              final nextResult = await _dhikrRepository.getDhikrLocally(
                dhikrId: id,
              );
              switch (nextResult) {
                case Ok():
                  final nextDhikr = nextResult.asOk.value;
                  if (nextDhikr != null &&
                      nextDhikr.currentCount < nextDhikr.targetCount) {
                    _currentDhikrId = id;
                    await _loadDhikr();
                    return Result.ok(null);
                  }
                case Error():
                  break;
              }
            }
          }
        }
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

    _log.info('Decrementing count for dhikr: $_currentDhikrId');

    final newCount = dhikr.currentCount - 1;
    final updatedDhikr = dhikr.copyWith(
      currentCount: newCount,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: newCount >= dhikr.targetCount,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      dhikrId: _currentDhikrId,
      dhikr: updatedDhikr,
    );

    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_currentDhikrId');
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

    _log.info('Resetting count for dhikr: $_currentDhikrId');

    final updatedDhikr = dhikr.copyWith(
      currentCount: 0,
      lastUpdatedAt: DateTime.now(),
      isSynced: false,
      isCompleted: false,
    );

    final result = await _dhikrRepository.updateDhikrLocally(
      dhikrId: _currentDhikrId,
      dhikr: updatedDhikr,
    );
    switch (result) {
      case Ok():
        _currentDhikr.value = updatedDhikr;
        _log.info('Dhikr updated successfully: $_currentDhikrId');
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _deleteDhikr() async {
    _log.info('Deleting dhikr: $_currentDhikrId');

    final result = await _dhikrUseCase.deleteDhikr(dhikrId: _currentDhikrId);
    switch (result) {
      case Ok():
        _currentDhikr.value = null;
        _log.info('Dhikr deleted successfully: $_currentDhikrId');
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
