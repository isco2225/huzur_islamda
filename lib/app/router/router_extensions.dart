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

  /// Navigate to sign in screen
  void goToSignIn() => go(AppRoutes.signIn);

  /// Navigate to sign up screen
  void goToSignUp() => go(AppRoutes.signUp);

  /// Navigate to email verification screen
  void goToEmailVerification() => go(AppRoutes.emailVerification);

  /// Navigate to flow (home) screen
  void goToFlow() => go(AppRoutes.flow);

  /// Gönderi hakkında asistan ekranını açar (yeni ekran, post zorunlu).
  Future<T?> pushToAssistantForPost<T extends Object?>(Post post) =>
      push<T>(AppRoutes.assistantForPost, extra: post);

  /// Navigate to dhikr screen
  void goToDhikr() => go(AppRoutes.dhikr);

  // -------------------- PUSH METHODS (Add to navigation stack) --------------------
  /// Push settings screen
  Future<T?> pushSettings<T extends Object?>() => push<T>(AppRoutes.settings);

  /// Push purchase (paywall) screen
  Future<T?> pushPurchase<T extends Object?>() => push<T>(AppRoutes.purchase);

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
