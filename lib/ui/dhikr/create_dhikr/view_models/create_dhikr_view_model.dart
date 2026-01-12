import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class CreateDhikrViewModel {
  CreateDhikrViewModel({
    required DhikrRepository dhikrRepository,
    required UserRepository userRepository,
  }) : _dhikrRepository = dhikrRepository,
       _userRepository = userRepository {
    // DEFINE COMMANDS
    createDhikr = Command1<Dhikr, ({String name, int targetCount})>(
      _createDhikr,
      debugLabel: 'createDhikr',
    );

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('CreateDhikrViewModel');

  // REPOSITORIES & USE CASES
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;

  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  // TARGET COUNT
  final ValueNotifier<int> targetCount = ValueNotifier<int>(33);

  // COMMANDS
  late final Command1<Dhikr, ({String name, int targetCount})> createDhikr;

  // DISPOSE
  void dispose() {
    createDhikr.dispose();
    targetCount.dispose();
  }

  // FUNCTIONS
  Future<Result<Dhikr>> _createDhikr(
    ({String name, int targetCount}) params,
  ) async {
    try {
      final userId = currentUser.value.uid;
      if (userId.isEmpty) {
        _log.warning('User ID is empty, cannot create dhikr');
        return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
      }

      final result = await _dhikrRepository.saveDhikrLocally(
        Dhikr(
          id: userId + params.name + params.targetCount.toString(),
          userId: userId,
          name: params.name,
          targetCount: params.targetCount,
          currentCount: 0,
          day: DateTime.now(),
          isCompleted: false,
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          isSynced: false,
          isDeleted: false,
        ),
      );

      if (result is Error<Dhikr>) {
        _log.warning('Create dhikr failed: ${result.error}');
      } else {
        _log.info('Dhikr created successfully: ${result.asOk.value.id}');
      }

      return result;
    } catch (e) {
      _log.severe('Failed to create dhikr: $e');
      return Result.error(Exception('Failed to create dhikr: $e'));
    }
  }
}
