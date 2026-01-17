import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class FetchDhikrsViewModel {
  FetchDhikrsViewModel({
    required DhikrRepository dhikrRepository,
    required UserRepository userRepository,
  }) : _dhikrRepository = dhikrRepository,
       _userRepository = userRepository {
    fetchDhikrs = Command1<void, DateTime>(
      _fetchDhikrs,
      debugLabel: 'fetchDhikrs',
    );
    _selectedDate = ValueNotifier<DateTime>(_getToday());
    // İlk yüklemede bugünün zikirlerini çek
    fetchDhikrs.execute(_selectedDate.value);
  }

  // LOGGER
  final _log = Logger('FetchDhikrsViewModel');

  // REPOSITORIES & USE CASES
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;

  // DOMAIN
  ValueListenable<List<Dhikr>?> get dhikrs => _dhikrs;
  final ValueNotifier<List<Dhikr>?> _dhikrs = ValueNotifier<List<Dhikr>?>(null);
  ValueListenable<DateTime> get selectedDate => _selectedDate;
  late final ValueNotifier<DateTime> _selectedDate;

  // COMMANDS
  late Command1<void, DateTime> fetchDhikrs;

  // DISPOSE
  void dispose() {
    fetchDhikrs.dispose();
    _selectedDate.dispose();
    _dhikrs.dispose();
    _log.fine('Disposed');
  }

  // DATE NAVIGATION
  void goToPreviousDay() {
    final currentDate = _selectedDate.value;
    final previousDate = currentDate.subtract(const Duration(days: 1));
    _selectedDate.value = previousDate;
    fetchDhikrs.execute(previousDate);
  }

  void goToNextDay() {
    final currentDate = _selectedDate.value;
    final nextDate = currentDate.add(const Duration(days: 1));
    final today = _getToday();
    // Geleceğe gidilemez, bugüne kadar gidilebilir
    if (!nextDate.isAfter(today)) {
      _selectedDate.value = nextDate;
      fetchDhikrs.execute(nextDate);
    }
  }

  void goToToday() {
    final today = _getToday();
    _selectedDate.value = today;
    fetchDhikrs.execute(today);
  }

  bool get canGoToNextDay {
    final currentDate = _selectedDate.value;
    final today = _getToday();
    return currentDate.isBefore(today);
  }

  // PRIVATE HELPERS
  DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // FUNCTIONS
  Future<Result<void>> _fetchDhikrs(DateTime date) async {
    final currentUser = _userRepository.currentUser.value;
    if (currentUser.uid.isEmpty) {
      _log.warning('No authenticated user found');
      return Result.error(Exception('No authenticated user found'));
    }

    final result = await _dhikrRepository.getAllDhikrsByDateLocally(date: date);
    switch (result) {
      case Ok():
        final dhikrs = result.asOk.value;
        if (dhikrs == null) {
          _log.fine('No dhikrs found for date: $date');
          _dhikrs.value = null;
          return Result.ok(null);
        }
        _log.fine('Dhikrs fetched successfully');
        _dhikrs.value = dhikrs;
        return Result.ok(null);
      case Error():
        _log.severe('Failed to fetch dhikrs: ${result.asError.error}');
        _dhikrs.value = null;
        return Result.error(result.asError.error);
    }
  }
}
