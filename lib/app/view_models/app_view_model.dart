import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class AppViewModel {
  AppViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required HiveRepository hiveRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _hiveRepository = hiveRepository {
    // DEFINE COMMANDS
    initApp = Command0(_initApp, debugLabel: 'AppViewModel.initApp');

    // Define Listeners
    // Auth state değişikliklerini dinle (isSignedIn daha direkt)
    _authRepository.isSignedIn.addListener(_onAuthStateChanged);

    // INIT
    // initUser artık initApp içinde await ediliyor
    // Constructor'da çağırmıyoruz çünkü initApp zaten user'ı yükleyecek
  }

  // LOGGER
  final _log = Logger('AppViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final HiveRepository _hiveRepository;
  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  ValueListenable<Auth> get auth => _authRepository.auth;
  ValueListenable<bool> get isSignedIn => _authRepository.isSignedIn;

  // COMMANDS
  late Command0<void> initApp;

  // DISPOSE
  void dispose() {
    _authRepository.isSignedIn.removeListener(_onAuthStateChanged);
    initApp.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _initApp() async {
    try {
      _log.info('Initializing app...');

      // initialize hive
      await _hiveRepository.initializeHive();

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
      _log.info('User signed in, router will handle user initialization');
    } else {
      // Kullanıcı çıkış yaptı, user bilgilerini temizle
      _log.info('User signed out, wiping user data');
      _userRepository.wipeUser();
    }
  }
}
