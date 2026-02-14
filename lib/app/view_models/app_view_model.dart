import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class AppViewModel {
  AppViewModel({
    required AppRepository appRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required HiveRepository hiveRepository,
    required PostRepository postRepository,
    required DhikrUseCase dhikrUseCase,
    required PrayerTimeUseCase prayerTimeUseCase,
    required SyncPermissionUseCase syncPermissionUseCase,
    required WipeDataUseCase wipeDataUseCase,
    required SchedulePrayerNotificationsUseCase
    schedulePrayerNotificationsUseCase,
    required AdMobService admobService,
  }) : _appRepository = appRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _hiveRepository = hiveRepository,
       _postRepository = postRepository,
       _dhikrUseCase = dhikrUseCase,
       _syncPermissionUseCase = syncPermissionUseCase,
       _wipeDataUseCase = wipeDataUseCase,
       _schedulePrayerNotificationsUseCase = schedulePrayerNotificationsUseCase,
       _prayerTimeUseCase = prayerTimeUseCase,
       _admobService = admobService {
    // DEFINE COMMANDS
    initApp = Command0(_initApp, debugLabel: 'AppViewModel.initApp');
    initUser = Command0(_initUser, debugLabel: 'AppViewModel.initUser');
    wipeData = Command0(_wipeData, debugLabel: 'AppViewModel.wipeData');
    _authRepository.isSignedIn.addListener(_onAuthStateChanged);
  }

  // LOGGER
  final _log = Logger('AppViewModel');

  // REPOSITORIES & USE CASES
  final AppRepository _appRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final HiveRepository _hiveRepository;
  final PostRepository _postRepository;
  final DhikrUseCase _dhikrUseCase;
  final SyncPermissionUseCase _syncPermissionUseCase;
  final WipeDataUseCase _wipeDataUseCase;
  final SchedulePrayerNotificationsUseCase _schedulePrayerNotificationsUseCase;
  final PrayerTimeUseCase _prayerTimeUseCase;
  final AdMobService _admobService;
  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  ValueListenable<Auth> get auth => _authRepository.auth;
  ValueListenable<bool> get isSignedIn => _authRepository.isSignedIn;
  ValueListenable<AppPreferences> get appPreferences =>
      _appRepository.appPreferences;

  // COMMANDS
  late Command0<void> initApp;
  late Command0<bool> initUser;
  late Command0<void> wipeData;

  // DISPOSE
  void dispose() {
    _authRepository.isSignedIn.removeListener(_onAuthStateChanged);
    initApp.dispose();
    initUser.dispose();
    wipeData.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _initApp() async {
    try {
      _log.info('Initializing app...');
      // load app preferences
      final preferencesResult = await _appRepository.getPreferences();
      switch (preferencesResult) {
        case Ok():
          _log.info('App preferences loaded successfully');
          await _checkAssistantDailyLimit();
          await _syncPermissionUseCase.syncNotificationPermissionState();
          break;
        case Error():
          _log.warning(
            'Failed to load app preferences: ${preferencesResult.asError.error}',
          );
          return preferencesResult;
      }
      // initialize hive
      await _hiveRepository.initializeHive();
      // sync dhikrs
      await _dhikrUseCase.syncDhikrs();
      // if user is signed in, initialize user
      bool userInitialized = false;
      if (_authRepository.isSignedIn.value &&
          _authRepository.auth.value.uid.isNotEmpty) {
        _log.info('User is signed in, initializing user...');
        final userInitResult = await _initUser();
        switch (userInitResult) {
          case Ok():
            if (userInitResult.asOk.value == false) {
              _log.info('User not registered yet');
              userInitialized = userInitResult.asOk.value;
              break;
            }
            userInitialized = userInitResult.asOk.value;
            break;
          case Error():
            userInitialized = false;
            _log.warning(
              'Failed to initialize user: ${userInitResult.asError.error}',
            );
        }
      }
      if (userInitialized && currentUser.value.isRegistered) {
        // initialize admob
        await _admobService.initialize();
        // fetch saved post ids
        final savedPostIdsResult = await _postRepository.fetchSavedPostIds(
          userId: currentUser.value.uid,
        );
        switch (savedPostIdsResult) {
          case Ok():
            _log.info('Saved post ids fetched successfully');
            break;
          case Error():
            _log.warning(
              'Failed to fetch saved post ids: ${savedPostIdsResult.asError.error}',
            );
        }
        if (currentUser.value.districtId!.isNotEmpty &&
            currentUser.value.city!.isNotEmpty &&
            currentUser.value.country!.isNotEmpty) {
          // local prayer times.
          final prayerTimesResult = await _prayerTimeUseCase.getPrayerTimes(
            districtId: currentUser.value.districtId!,
            city: currentUser.value.city!,
            country: currentUser.value.country!,
            userId: currentUser.value.uid,
          );
          switch (prayerTimesResult) {
            case Ok():
              if (prayerTimesResult.asOk.value != null &&
                  appPreferences.value.isNotificationsEnabled) {
                _log.info('Prayer times loaded successfully');
                await _schedulePrayerNotificationsUseCase.scheduleForWeek();
              }
            case Error():
              _log.warning(
                'Failed to load prayer times: ${prayerTimesResult.asError.error}',
              );
          }
        }
      }
      _log.info('App initialized successfully');
      return Result.ok(null);
    } catch (e) {
      _log.severe('Failed to initialize app: $e');
      return Result.error(Exception('Uygulama başlatılamadı: $e'));
    }
  }

  void _onAuthStateChanged() {
    final isSignedIn = _authRepository.isSignedIn.value;

    if (isSignedIn) {
      initApp.execute();
      _log.info('User signed in, router will handle user initialization');
    } else {
      _log.info('User signed out, wiping all data');
      wipeData.execute();
    }
  }

  Future<Result<bool>> _initUser() async {
    if (_authRepository.auth.value.uid.isEmpty) {
      return Result.error(Exception('User not authenticated'));
    }
    final result = await _userRepository.initUser(
      uid: _authRepository.auth.value.uid,
    );
    return result;
  }

  Future<Result<void>> _wipeData() async {
    try {
      _log.info('Wiping user data...');
      final result = await _wipeDataUseCase.wipeData();
      switch (result) {
        case Ok():
          _log.info('User data wiped successfully');
          return result;
        case Error():
          _log.severe('Failed to wipe user data: ${result.asError.error}');
          return result;
      }
    } catch (e) {
      _log.severe('Exception wiping user data: $e');
      return Result.error(Exception('Veri temizlenirken hata oluştu: $e'));
    }
  }

  Future<void> _checkAssistantDailyLimit() async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastReset = _appRepository.appPreferences.value.lastLimitResetDate;
    if (lastReset.isEmpty || lastReset != today) {
      final resetResult = await _appRepository.resetAssistantDailyLimit();
      switch (resetResult) {
        case Ok():
          _log.info('Assistant daily limit reset (new day)');
          break;
        case Error():
          _log.warning(
            'Failed to reset assistant daily limit: ${resetResult.asError.error}',
          );
      }
    }
  }
}
