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
    fetchDhikrs = Command0<void>(_fetchDhikrs, debugLabel: 'fetchDhikrs');
  }

  // LOGGER
  final _log = Logger('FetchDhikrsViewModel');

  // REPOSITORIES & USE CASES
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;

  // DOMAIN
  ValueListenable<List<Dhikr>> get dhikrs => _dhikrRepository.dhikrs;

  // COMMANDS
  late Command0<void> fetchDhikrs;

  // DISPOSE
  void dispose() {
    fetchDhikrs.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _fetchDhikrs() async {
    final currentUser = _userRepository.currentUser.value;
    if (currentUser.uid.isEmpty) {
      _log.warning('No authenticated user found');
      return Result.error(Exception('No authenticated user found'));
    }

    final result = await _dhikrRepository.fetchDhikrs(userId: currentUser.uid);
    switch (result) {
      case Ok():
        _log.fine('Dhikrs fetched successfully');
        return Result.ok(null);
      case Error():
        _log.severe('Failed to fetch dhikrs: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }
}
