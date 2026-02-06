import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/domain.dart';
import 'app_routes.dart';

/// Extension methods for type-safe navigation throughout the app.
///
/// These extensions provide convenient methods to navigate between screens
/// without using magic strings.
extension RouterExtensions on BuildContext {
  // -------------------- GO METHODS (Replace current route) --------------------

  /// Navigate to onboarding screen
  void goToOnboarding() => go(AppRoutes.onboarding);

  /// Navigate to sign in screen
  void goToSignIn() => go(AppRoutes.signIn);

  /// Navigate to sign up screen
  void goToSignUp() => go(AppRoutes.signUp);

  /// Navigate to email verification screen
  void goToEmailVerification() => go(AppRoutes.emailVerification);

  /// Navigate to flow (home) screen
  void goToFlow() => go(AppRoutes.flow);

  /// Navigate to assistant screen
  void goToAssistant() => go(AppRoutes.assistant);

  /// Navigate to prayer screen
  void goToPrayer() => go(AppRoutes.prayer);

  /// Navigate to dhikr screen
  void goToDhikr() => go(AppRoutes.dhikr);

  /// Navigate to profile screen
  void goToProfile() => go(AppRoutes.profile);

  /// Navigate to create profile screen
  void goToCreateProfile() => go(AppRoutes.createProfile);

  /// Navigate to edit profile screen
  void goToEditProfile() => go(AppRoutes.editProfile);

  /// Navigate to settings screen
  void goToSettings() => go(AppRoutes.settings);

  /// Navigate to create dhikr screen
  void goToCreateDhikr() => go(AppRoutes.createDhikr);

  // -------------------- PUSH METHODS (Add to navigation stack) --------------------

  /// Push settings screen
  Future<T?> pushSettings<T extends Object?>() => push<T>(AppRoutes.settings);

  /// Push saved posts screen
  Future<T?> pushSavedPosts<T extends Object?>() =>
      push<T>(AppRoutes.savedPosts);

  /// Push edit profile screen
  Future<T?> pushEditProfile<T extends Object?>() =>
      push<T>(AppRoutes.editProfile);

  /// Push create dhikr screen
  Future<T?> pushCreateDhikr<T extends Object?>() =>
      push<T>(AppRoutes.createDhikr);

  /// Push create dhikr by mood screen
  Future<T?> pushCreateDhikrByMood<T extends Object?>() =>
      push<T>(AppRoutes.createDhikrByMood);

  // -------------------- SPECIAL ROUTES WITH PARAMETERS --------------------

  /// Navigate to post detail screen
  void goToPostDetail(Post post) => go(AppRoutes.postDetail, extra: post);

  /// Push post detail screen
  Future<T?> pushPostDetail<T extends Object?>(Post post) =>
      push<T>(AppRoutes.postDetail, extra: post);

  /// Push dhikr detail screen (single dhikr).
  Future<T?> pushToDhikrDetail<T extends Object?>(String dhikrId) => push<T>(
    AppRoutes.dhikrDetail,
    extra: DhikrDetailParams(initialDhikrId: dhikrId, groupDhikrIds: null),
  );

  /// Push dhikr detail screen for a group.
  Future<T?> pushToDhikrDetailForGroup<T extends Object?>(
    List<String> dhikrIds,
  ) => dhikrIds.isEmpty
      ? Future<T?>.value(null)
      : push<T>(
          AppRoutes.dhikrDetail,
          extra: DhikrDetailParams(
            initialDhikrId: dhikrIds.first,
            groupDhikrIds: dhikrIds,
          ),
        );
}
