import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../domain/user/use_cases/use_cases.dart';
import '../../../../domain/domain.dart';

class EmailVerificationViewModel {
  EmailVerificationViewModel({
    required CheckEmailVerificationUseCase checkEmailVerificationUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required AuthRepository authRepository,
    this.checkInterval = const Duration(seconds: 5),
    this.onEmailVerified,
  }) : _checkEmailVerificationUseCase = checkEmailVerificationUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       _authRepository = authRepository {
    // DEFINE COMMANDS
    sendEmailVerification = Command0<void>(
      _sendEmailVerification,
      debugLabel: 'sendEmailVerification',
    );

    checkEmailVerification = Command0<bool>(
      _checkEmailVerification,
      debugLabel: 'checkEmailVerification',
    );

    deleteAccount = Command0<void>(_deleteAccount, debugLabel: 'deleteAccount');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('EmailVerificationViewModel');

  // REPOSITORIES & USE CASES
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final AuthRepository _authRepository;

  // DOMAIN
  Timer? _verificationTimer;
  bool _isChecking = false;
  bool _isEmailVerified = false; // Email doğrulandı mı?

  ValueListenable<Auth?> get auth => _authRepository.auth;

  /// Email doğrulama kontrolü için kullanılacak interval (varsayılan: 5 saniye)
  final Duration checkInterval;

  /// Email doğrulandığında çağrılacak callback
  final VoidCallback? onEmailVerified;

  // COMMANDS
  late final Command0<void> sendEmailVerification;
  late final Command0<bool> checkEmailVerification;
  late final Command0<void> deleteAccount;

  // DISPOSE
  void dispose() {
    _verificationTimer?.cancel();
    sendEmailVerification.dispose();
    checkEmailVerification.dispose();
    deleteAccount.dispose();
  }

  // FUNCTIONS

  /// Email doğrulama linkini gönderir
  Future<Result<void>> _sendEmailVerification() async {
    final result = await _authRepository.sendEmailVerification();
    _log.info('Send email verification result: $result');

    if (result is Error<void>) {
      _log.warning('Send email verification failed! ${result.error}');
    } else {
      // Email gönderildikten sonra periyodik kontrolü başlat
      _startPeriodicVerificationCheck();
    }

    return result;
  }

  /// Email doğrulama durumunu kontrol eder
  Future<Result<bool>> _checkEmailVerification() async {
    if (_isChecking) {
      _log.info('Email verification check already in progress, skipping...');
      return Result.ok(false);
    }

    _isChecking = true;
    final result = await _checkEmailVerificationUseCase.execute();
    _log.info('Check email verification result: $result');

    if (result is Error<bool>) {
      _log.warning('Check email verification failed! ${result.error}');
    } else if (result is Ok<bool>) {
      final isVerified = result.asOk.value;
      if (isVerified) {
        _isEmailVerified = true; // Email doğrulandı, flag'i set et
        _log.info('Email verified! Stopping periodic check.');
        _stopPeriodicVerificationCheck();
        // Email doğrulandığında callback'i çağır
        onEmailVerified?.call();
      }
    }

    _isChecking = false;
    return result;
  }

  /// Periyodik email doğrulama kontrolünü başlatır
  void _startPeriodicVerificationCheck() {
    // Email zaten doğrulandıysa, timer başlatma
    if (_isEmailVerified) {
      _log.info('Email already verified, not starting periodic check.');
      return;
    }

    _stopPeriodicVerificationCheck(); // Önceki timer'ı durdur

    _log.info(
      'Starting periodic email verification check (interval: $checkInterval)',
    );

    // İlk kontrolü hemen yap, sonra periyodik olarak devam et
    _performCheckAndScheduleNext();
  }

  /// Kontrolü yapar ve bir sonraki kontrolü planlar
  Future<void> _performCheckAndScheduleNext() async {
    // Email zaten doğrulandıysa, timer başlatma
    if (_isEmailVerified) {
      _log.info('Email already verified, skipping check.');
      return;
    }

    // Kontrolü yap
    await _checkEmailVerification();

    // Email doğrulandıysa timer başlatma
    if (_isEmailVerified) {
      _log.info('Email verified during check, not scheduling next.');
      return;
    }

    // Eğer timer iptal edilmediyse (email doğrulanmadıysa), bir sonraki kontrolü planla
    _verificationTimer ??= Timer(checkInterval, () {
      _verificationTimer = null;
      _performCheckAndScheduleNext();
    });
  }

  /// Periyodik email doğrulama kontrolünü durdurur
  void _stopPeriodicVerificationCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    _log.info('Stopped periodic email verification check');
  }

  /// Kullanıcı hesabını siler
  Future<Result<void>> _deleteAccount() async {
    // Periyodik kontrolü durdur
    _stopPeriodicVerificationCheck();

    final result = await _deleteAccountUseCase.execute();
    _log.info('Delete account result: $result');

    if (result is Error<void>) {
      _log.warning('Delete account failed! ${result.error}');
    }

    return result;
  }
}
