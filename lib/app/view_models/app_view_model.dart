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
    required DhikrUseCase dhikrUseCase,
    required PrayerTimeUseCase prayerTimeUseCase,
    required SyncPermissionUseCase syncPermissionUseCase,
    required WipeDataUseCase wipeDataUseCase,
  }) : _appRepository = appRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _hiveRepository = hiveRepository,
       _dhikrUseCase = dhikrUseCase,
       _syncPermissionUseCase = syncPermissionUseCase,
       _wipeDataUseCase = wipeDataUseCase {
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
  final DhikrUseCase _dhikrUseCase;
  final SyncPermissionUseCase _syncPermissionUseCase;
  final WipeDataUseCase _wipeDataUseCase;
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
      // if user is signed in, initialize user
      if (_authRepository.isSignedIn.value &&
          _authRepository.auth.value.uid.isNotEmpty) {
        _log.info('User is signed in, initializing user...');
        final userInitResult = await _initUser();
        switch (userInitResult) {
          case Ok():
            _log.info('User initialized successfully');
          case Error():
            _log.warning(
              'Failed to initialize user: ${userInitResult.asError.error}',
            );
        }
      }

      // initialize hive
      await _hiveRepository.initializeHive();

      // load app preferences
      final preferencesResult = await _appRepository.getPreferences();
      switch (preferencesResult) {
        case Ok():
          print('preferencesResult: ${preferencesResult.value.toJson()}');
          _log.info('App preferences loaded successfully');
          await _syncPermissionUseCase.syncNotificationPermissionState();
        case Error():
          _log.warning(
            'Failed to load app preferences: ${preferencesResult.asError.error}',
          );
      }

      // sync dhikrs
      await _dhikrUseCase.syncDhikrs();
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
    switch (result) {
      case Ok():
        if (result.asOk.value == false) {
          return Result.error(Exception('User not registered'));
        }
        _log.info('User initialized successfully');
        return result;
      case Error():
        _log.warning('Failed to init user', result.error);
        return result;
    }
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
}
