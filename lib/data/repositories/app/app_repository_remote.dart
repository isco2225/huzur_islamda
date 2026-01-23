import 'package:flutter/foundation.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/repositories/app/app_repository.dart';
import 'package:huzur_islamda/data/services/shared_preferences_sevice.dart';
import 'package:huzur_islamda/domain/app/models/app_preferences.dart';

class AppRepositoryRemote implements AppRepository {
  AppRepositoryRemote({
    required SharedPreferencesService sharedPreferencesService,
  }) : _sharedPreferencesService = sharedPreferencesService;

  final SharedPreferencesService _sharedPreferencesService;

  static const String _appPreferencesKey = 'APP_PREFERENCES';
  @override
  ValueListenable<AppPreferences> get appPreferences => _appPreferences;
  final ValueNotifier<AppPreferences> _appPreferences =
      ValueNotifier<AppPreferences>(AppPreferences.empty());

  @override
  Future<Result<AppPreferences>> getPreferences() async {
    try {
      final result = await _sharedPreferencesService.fetchJson(
        key: _appPreferencesKey,
      );
      switch (result) {
        case Ok():
          final json = result.value;
          if (json == null) {
            return Result.ok(AppPreferences.empty());
          }
          _appPreferences.value = AppPreferences.fromJson(json);
          return Result.ok(_appPreferences.value);
        case Error():
          return Result.error(result.error);
      }
    } on Exception catch (exception) {
      return Result.error(exception);
    }
  }

  @override
  Future<Result<void>> updateIsVibrationEnabled({
    required bool isVibrationEnabled,
  }) async {
    final result = await _updateAppPreferences(
      _appPreferences.value.copyWith(isVibrationEnabled: isVibrationEnabled),
    );
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> updateIsNotificationsEnabled({
    required bool isNotificationsEnabled,
  }) async {
    final result = await _updateAppPreferences(
      _appPreferences.value.copyWith(
        isNotificationsEnabled: isNotificationsEnabled,
      ),
    );
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }

  @override
  Future<Result<void>> updateIsOnboardingCompleted({
    required bool isOnboardingCompleted,
  }) async {
    final result = await _updateAppPreferences(
      _appPreferences.value.copyWith(
        isOnboardingCompleted: isOnboardingCompleted,
      ),
    );
    switch (result) {
      case Ok():
        print('updateIsOnboardingCompleted: ok');
        return Result.ok(null);
      case Error():
        print('updateIsOnboardingCompleted: error');
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _updateAppPreferences(
    AppPreferences appPreferences,
  ) async {
    try {
      final result = await _sharedPreferencesService.saveJson(
        key: _appPreferencesKey,
        json: appPreferences.toJson(),
      );
      switch (result) {
        case Ok():
          _appPreferences.value = appPreferences;
          return Result.ok(null);
        case Error():
          return Result.error(result.error);
      }
    } on Exception catch (exception) {
      return Result.error(exception);
    }
  }
}
