import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    createDhikr = Command1<Dhikr, ({String name, int? targetCount})>(
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

  // CONTROLLERS
  final nameController = TextEditingController();

  // TARGET COUNT
  final ValueNotifier<int> targetCount = ValueNotifier<int>(33);

  // COMMANDS
  late final Command1<Dhikr, ({String name, int? targetCount})> createDhikr;

  // DISPOSE
  void dispose() {
    createDhikr.dispose();
    nameController.dispose();
    targetCount.dispose();
  }

  // FUNCTIONS
  Future<Result<Dhikr>> _createDhikr(
    ({String name, int? targetCount}) params,
  ) async {
    final userId = currentUser.value.uid;
    if (userId.isEmpty) {
      _log.warning('User ID is empty, cannot create dhikr');
      return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
    }

    // Use targetCount from params, or use the ValueNotifier value if null
    final finalTargetCount = params.targetCount ?? targetCount.value;

    final result = await _dhikrRepository.createDhikr(
      userId: userId,
      name: params.name,
      targetCount: finalTargetCount > 0 ? finalTargetCount : null,
    );

    if (result is Error<Dhikr>) {
      _log.warning('Create dhikr failed: ${result.error}');
    } else {
      _log.info('Dhikr created successfully: ${result.asOk.value.id}');
    }

    return result;
  }
}
