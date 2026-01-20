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
  }) : _appRepository = appRepository,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _hiveRepository = hiveRepository,
       _dhikrUseCase = dhikrUseCase {
    // DEFINE COMMANDS
    initApp = Command0(_initApp, debugLabel: 'AppViewModel.initApp');
    _authRepository.isSignedIn.addListener(_onAuthStateChanged);
    initUser = Command0(_initUser, debugLabel: 'AppViewModel.initUser');
  }

  // LOGGER
  final _log = Logger('AppViewModel');

  // REPOSITORIES & USE CASES
  final AppRepository _appRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final HiveRepository _hiveRepository;
  final DhikrUseCase _dhikrUseCase;
  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  ValueListenable<Auth> get auth => _authRepository.auth;
  ValueListenable<bool> get isSignedIn => _authRepository.isSignedIn;
  ValueListenable<AppPreferences> get appPreferences =>
      _appRepository.appPreferences;

  // COMMANDS
  late Command0<void> initApp;
  late Command0<bool> initUser;

  // DISPOSE
  void dispose() {
    _authRepository.isSignedIn.removeListener(_onAuthStateChanged);
    initApp.dispose();
    initUser.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _initApp() async {
    try {
      _log.info('Initializing app...');

      // initialize hive
      await _hiveRepository.initializeHive();

      // load app preferences
      final preferencesResult = await _appRepository.getPreferences();
      switch (preferencesResult) {
        case Ok():
          _log.info('App preferences loaded successfully');
        case Error():
          _log.warning(
            'Failed to load app preferences: ${preferencesResult.asError.error}',
          );
      }

      // sync dhikrs
      await _dhikrUseCase.syncDhikrs();

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
      // Kullanıcı giriş yaptı
      // User data yükleme işlemi router redirect mantığı tarafından
      // UserInitializeRoute'a yönlendirilerek yapılıyor
      // Bu yüzden burada tekrar yüklemeye gerek yok
      // Command pattern kullanarak state tracking ve hata yönetimi yapılır
      initApp.execute();
      _log.info('User signed in, router will handle user initialization');
    } else {
      // Kullanıcı çıkış yaptı, user bilgilerini temizle
      _log.info('User signed out, wiping user data');
      _userRepository.wipeUser();
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
        _log.info('User initialized successfully');
        return result;
      case Error():
        _log.warning('Failed to init user', result.error);
        return result;
    }
  }
}
