import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class CreateDhikrViewModel {
  CreateDhikrViewModel({
    required DhikrRepository dhikrRepository,
    required UserRepository userRepository,
    required DhikrUseCase dhikrUseCase,
    required ShowAdUseCase showAdUseCase,
  }) : _dhikrRepository = dhikrRepository,
       _userRepository = userRepository,
       _dhikrUseCase = dhikrUseCase,
       _showAdUseCase = showAdUseCase {
    // DEFINE COMMANDS
    createDhikr = Command1<void, ({String name, int targetCount})>(
      _createDhikr,
      debugLabel: 'createDhikr',
    );
    createDhikrsForPrayer = Command0<List<String>>(
      _createDhikrsForPrayer,
      debugLabel: 'createDhikrsForPrayer',
    );
    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('CreateDhikrViewModel');

  // REPOSITORIES & USE CASES
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;
  final DhikrUseCase _dhikrUseCase;
  final ShowAdUseCase _showAdUseCase;

  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  // TARGET COUNT
  final ValueNotifier<int> targetCount = ValueNotifier<int>(33);

  // COMMANDS
  late final Command1<void, ({String name, int targetCount})> createDhikr;
  late final Command0<List<String>> createDhikrsForPrayer;

  // DISPOSE
  void dispose() {
    createDhikr.dispose();
    targetCount.dispose();
    createDhikrsForPrayer.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _createDhikr(
    ({String name, int targetCount}) params,
  ) async {
    try {
      final userId = currentUser.value.uid;
      if (userId.isEmpty) {
        _log.warning('User ID is empty, cannot create dhikr');
        return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
      }

      final currentDate = DateTime.now();
      final result = await _dhikrRepository.saveDhikrLocally(
        dhikr: Dhikr(
          id: currentDate.toString(),
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

      if (result is Error<void>) {
        _log.warning('Create dhikr failed: ${result.error}');
      } else {
        final syncResult = await _dhikrUseCase.syncDhikrs();
        switch (syncResult) {
          case Ok():
            _log.info('Dhikr synced successfully');
          case Error():
            _log.warning('Failed to sync dhikr: ${syncResult.error}');
        }
        _log.info('Dhikr created successfully');
      }

      return result;
    } catch (e) {
      _log.severe('Failed to create dhikr: $e');
      return Result.error(Exception('Failed to create dhikr: $e'));
    }
  }

  /// Interstitial ad gösterir
  /// UI layer'dan context alır ve use case üzerinden ad gösterir
  Future<void> showInterstitialAd() async {
    await _showAdUseCase.showInterstitialAd();
  }

  Future<Result<List<String>>> _createDhikrsForPrayer() async {
    try {
      final userId = currentUser.value.uid;
      if (userId.isEmpty) {
        _log.warning('User ID is empty, cannot create prayer dhikrs');
        return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
      }

      // Generate unique group ID
      final currentDate = DateTime.now();
      final groupId = 'prayer_dhikr_${currentDate.microsecondsSinceEpoch}';
      final dhikrs = [
        Dhikr(
          id: '${groupId}_subhanallah',
          userId: userId,
          name: PrayerDhikrConstants.subhanallahName,
          targetCount: PrayerDhikrConstants.prayerDhikrTargetCount,
          currentCount: 0,
          day: currentDate,
          isCompleted: false,
          createdAt: currentDate,
          lastUpdatedAt: currentDate,
          isSynced: false,
          isDeleted: false,
          groupId: groupId,
          groupDisplayName: 'Namaz Tesbihatı',
        ),
        Dhikr(
          id: '${groupId}_elhamdulillah',
          userId: userId,
          name: PrayerDhikrConstants.elhamdulillahName,
          targetCount: PrayerDhikrConstants.prayerDhikrTargetCount,
          currentCount: 0,
          day: currentDate,
          isCompleted: false,
          createdAt: currentDate,
          lastUpdatedAt: currentDate,
          isSynced: false,
          isDeleted: false,
          groupId: groupId,
          groupDisplayName: 'Namaz Tesbihatı',
        ),
        Dhikr(
          id: '${groupId}_allahu_ekber',
          userId: userId,
          name: PrayerDhikrConstants.allahuEkberName,
          targetCount: PrayerDhikrConstants.prayerDhikrTargetCount,
          currentCount: 0,
          day: currentDate,
          isCompleted: false,
          createdAt: currentDate,
          lastUpdatedAt: currentDate,
          isSynced: false,
          isDeleted: false,
          groupId: groupId,
          groupDisplayName: 'Namaz Tesbihatı',
        ),
      ];
      final result = await _dhikrRepository.createGroupDhikrs(dhikrs: dhikrs);
      switch (result) {
        case Ok():
          // Sync dhikrs to Firestore
          final syncResult = await _dhikrUseCase.syncDhikrs();
          switch (syncResult) {
            case Ok():
              _log.info('Prayer dhikrs synced successfully');
            case Error():
              _log.warning('Failed to sync prayer dhikrs: ${syncResult.error}');
          }
          _log.info(
            'Prayer dhikrs created successfully with groupId: $groupId',
          );
          final dhikrIds = dhikrs.map((d) => d.id).toList();
          return Result.ok(dhikrIds);
        case Error():
          _log.severe('Failed to create prayer dhikrs: ${result.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Failed to create dhikrs for prayer: $e');
      return Result.error(Exception('Failed to create dhikrs for prayer: $e'));
    }
  }
}
