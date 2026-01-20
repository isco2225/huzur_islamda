import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../ui/ui.dart';
import 'app_routes.dart';

/// Creates and returns the app router with refresh listenable support.
///
/// This router handles all navigation logic including authentication-based
/// redirects and maintains the bottom navigation bar state.
GoRouter createAppRouter(Listenable refreshListenable) {
  return GoRouter(
    routes: _routes,
    initialLocation: AppRoutes.onboarding,
    routerNeglect: false,
    redirect: _redirect,
    refreshListenable: refreshListenable,
  );
}

// -------------------- ROUTE DEFINITIONS --------------------

final List<RouteBase> _routes = [
  // -------------------- PUBLIC ROUTES --------------------
  GoRoute(
    path: AppRoutes.onboarding,
    name: 'onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),

  GoRoute(
    path: AppRoutes.signIn,
    name: 'sign_in',
    builder: (context, state) => const SignInScreen(),
  ),

  GoRoute(
    path: AppRoutes.signUp,
    name: 'sign_up',
    builder: (context, state) => const SignUpScreen(),
  ),

  GoRoute(
    path: AppRoutes.emailVerification,
    name: 'email_verification',
    builder: (context, state) => const EmailVerificationScreen(),
  ),

  // -------------------- BOTTOM NAVIGATION BAR ROUTES --------------------

  /// Stateful Shell Route for Bottom Navigation.
  ///
  /// Each branch represents a tab in the bottom navigation bar.
  /// Each branch maintains its own navigation stack.
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return NavigationBarScreen(navigationShell: navigationShell);
    },
    branches: [
      // Flow Tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.flow,
            name: 'flow',
            builder: (context, state) => const FlowScreen(),
          ),
        ],
      ),

      // Search Tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),

      // Prayer Tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.prayer,
            name: 'prayer',
            builder: (context, state) => const PrayerScreen(),
          ),
        ],
      ),

      // Dhikr Tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.dhikr,
            name: 'dhikr',
            builder: (context, state) => const DhikrScreen(),
          ),
        ],
      ),

      // Profile Tab
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
        ],
      ),
    ],
  ),

  // -------------------- USER ROUTES --------------------
  GoRoute(
    path: AppRoutes.userInitialize,
    name: 'user_initialize',
    builder: (context, state) => const UserInitializeScreen(),
  ),

  GoRoute(
    path: AppRoutes.createProfile,
    name: 'create_profile',
    builder: (context, state) => const CreateUserProfileScreen(),
  ),

  GoRoute(
    path: AppRoutes.editProfile,
    name: 'edit_profile',
    builder: (context, state) => const EditProfileScreen(),
  ),

  // -------------------- OTHER ROUTES --------------------
  GoRoute(
    path: AppRoutes.settings,
    name: 'settings',
    builder: (context, state) => const SettingsScreen(),
  ),

  GoRoute(
    path: AppRoutes.postDetail,
    name: 'post_detail',
    builder: (context, state) {
      final post = state.extra as Post?;
      if (post == null) {
        return const Scaffold(body: Center(child: Text('Post not found')));
      }
      return PostDetailScreen(post: post);
    },
  ),

  GoRoute(
    path: AppRoutes.createDhikr,
    name: 'create_dhikr',
    builder: (context, state) => const CreateDhikrScreen(),
  ),

  GoRoute(
    path: AppRoutes.dhikrDetail,
    name: 'dhikr_detail',
    builder: (context, state) {
      final dhikrId = state.extra as String?;
      if (dhikrId == null || dhikrId.isEmpty) {
        return const Scaffold(body: Center(child: Text('Zikir bulunamadı')));
      }
      return DhikrDetailScreen(dhikrId: dhikrId);
    },
  ),
];

// -------------------- REDIRECT LOGIC --------------------

/// Handles authentication-based redirects.
///
/// This function checks the user's authentication state and redirects
/// to appropriate screens based on their status:
/// - Not signed in → Sign in screen
/// - Signed in but email not verified → Email verification screen
/// - Signed in but user not initialized → User initialization screen
/// - Signed in but profile not created → Create profile screen
String? _redirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;
  final authRepository = context.read<AuthRepository>();
  final userRepository = context.read<UserRepository>();
  final appRepository = context.read<AppRepository>();

  final isSignedIn = authRepository.auth.value.isSignedIn();
  final auth = authRepository.auth.value;
  final user = userRepository.currentUser.value;
  final appPreferences = appRepository.appPreferences.value;

  // Auth screens
  final authLocs = [
    AppRoutes.onboarding,
    AppRoutes.signIn,
    AppRoutes.signUp,
    AppRoutes.emailVerification,
  ];

  // Routes that handle their own redirect logic
  final noRuleLocs = [
    AppRoutes.userInitialize,
    AppRoutes.createProfile,
    AppRoutes.editProfile,
    AppRoutes.settings,
  ];

  // Allow routes with no rules
  if (noRuleLocs.contains(location)) return null;

  // Not signed in: allow auth screens, redirect others to onboarding or sign in
  if (!isSignedIn) {
    if (authLocs.contains(location)) return null;
    if (!appPreferences.isOnboardingCompleted &&
        location != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }
    return AppRoutes.signIn;
  }

  // Signed in but navigating to auth screens: redirect based on status
  if (isSignedIn && authLocs.contains(location)) {
    if (!auth.isEmailVerified) {
      if (location == AppRoutes.emailVerification) return null;
      return AppRoutes.emailVerification;
    }
    if (user.uid.isEmpty) return AppRoutes.userInitialize;
    if (!user.isRegistered) return AppRoutes.createProfile;
    return AppRoutes.flow;
  }

  // Signed in: enforce requirements for protected routes
  if (!auth.isEmailVerified) {
    if (location == AppRoutes.emailVerification) return null;
    return AppRoutes.emailVerification;
  }
  if (user.uid.isEmpty) {
    if (location == AppRoutes.userInitialize) return null;
    return AppRoutes.userInitialize;
  }
  if (!user.isRegistered) {
    if (location == AppRoutes.createProfile) return null;
    return AppRoutes.createProfile;
  }

  return null;
}
