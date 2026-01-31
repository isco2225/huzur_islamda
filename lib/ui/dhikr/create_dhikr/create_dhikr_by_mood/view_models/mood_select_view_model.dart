import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';

class MoodSelectViewModel {
  MoodSelectViewModel({
    required DhikrMoodService moodService,
    required DhikrRepository dhikrRepository,
    required UserRepository userRepository,
    required DhikrUseCase dhikrUseCase,
  }) : _moodService = moodService,
       _dhikrRepository = dhikrRepository,
       _userRepository = userRepository,
       _dhikrUseCase = dhikrUseCase {
    createDhikrsForMood = Command1<List<String>, Mood>(
      _createDhikrsForMood,
      debugLabel: 'createDhikrsForMood',
    );
  }

  final Logger _log = Logger('MoodSelectViewModel');

  final DhikrMoodService _moodService;
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;
  final DhikrUseCase _dhikrUseCase;

  ValueListenable<List<Mood>?> get moods => _moods;
  final ValueNotifier<List<Mood>?> _moods = ValueNotifier<List<Mood>?>(null);

  ValueListenable<bool> get isLoadingMoods => _isLoadingMoods;
  final ValueNotifier<bool> _isLoadingMoods = ValueNotifier<bool>(true);

  ValueListenable<Object?> get loadMoodsError => _loadMoodsError;
  final ValueNotifier<Object?> _loadMoodsError = ValueNotifier<Object?>(null);

  late final Command1<List<String>, Mood> createDhikrsForMood;

  /// Ruh hallerini yükler. Screen initState'te çağrılır.
  Future<void> loadMoods() async {
    _isLoadingMoods.value = true;
    _loadMoodsError.value = null;

    final result = await _moodService.getDhikrMoods();

    _isLoadingMoods.value = false;
    switch (result) {
      case Ok():
        _moods.value = result.asOk.value;
        _loadMoodsError.value = null;
      case Error():
        _moods.value = null;
        _loadMoodsError.value = result.asError.error;
        _log.severe('Failed to load moods: ${result.asError.error}');
    }
  }

  Future<Result<List<String>>> _createDhikrsForMood(Mood mood) async {
    try {
      final userId = _userRepository.currentUser.value.uid;
      if (userId.isEmpty) {
        _log.warning('User ID is empty, cannot create mood dhikrs');
        return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
      }

      final now = DateTime.now();
      final groupId = 'mood_dhikr_${now.microsecondsSinceEpoch}';

      final dhikrs = mood.suggestions.map((s) {
        return Dhikr(
          id: '${groupId}_${s.id}',
          userId: userId,
          name: s.pronunciation,
          targetCount: s.defaultTarget,
          currentCount: 0,
          day: now,
          isCompleted: false,
          createdAt: now,
          lastUpdatedAt: now,
          isSynced: false,
          isDeleted: false,
          groupId: groupId,
          groupDisplayName: mood.title,
          arabic: s.arabic,
          meaning: s.meaning,
          benefit: s.benefit,
        );
      }).toList();

      final saveResult = await _dhikrRepository.createGroupDhikrs(
        dhikrs: dhikrs,
      );

      switch (saveResult) {
        case Ok():
          final syncResult = await _dhikrUseCase.syncDhikrs();
          switch (syncResult) {
            case Ok():
              _log.info('Mood dhikrs synced successfully');
            case Error():
              _log.warning(
                'Failed to sync mood dhikrs: ${syncResult.asError.error}',
              );
          }
          _log.info('Mood dhikrs created with groupId: $groupId');
          return Result.ok(dhikrs.map((d) => d.id).toList());
        case Error():
          _log.severe(
            'Failed to create mood dhikrs: ${saveResult.asError.error}',
          );
          return Result.error(saveResult.asError.error);
      }
    } catch (e) {
      _log.severe('Failed to create dhikrs for mood: $e');
      return Result.error(Exception('Zikir grubu oluşturulamadı: $e'));
    }
  }

  void dispose() {
    createDhikrsForMood.dispose();
    _moods.dispose();
    _isLoadingMoods.dispose();
    _loadMoodsError.dispose();
  }
}
