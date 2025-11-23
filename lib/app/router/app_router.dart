import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../ui/ui.dart';

part 'app_router.g.dart';

// -------------------- PUBLIC ROUTES --------------------

@TypedGoRoute<OnboardingRoute>(path: '/')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<SignInRoute>(path: '/sign_in')
class SignInRoute extends GoRouteData {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedGoRoute<SignUpRoute>(path: '/sign_up')
class SignUpRoute extends GoRouteData {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<EmailVerificationRoute>(path: '/email_verification')
class EmailVerificationRoute extends GoRouteData {
  const EmailVerificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EmailVerificationScreen();
}

//BOTTOM NAVIGATION BAR ROUTES

/// Main navigation bar route with stateful shell for bottom navigation.
///
/// Each branch represents a tab in the bottom navigation bar.
/// Each branch maintains its own navigation stack.
@TypedStatefulShellRoute<NavigationBarRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<FlowRoute>(path: '/flow')],
    ),
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SearchRoute>(path: '/search'),
      ],
    ),
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<PrayerRoute>(path: '/prayer'),
      ],
    ),
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<DhikrRoute>(path: '/dhikr')],
    ),
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class NavigationBarRouteData extends StatefulShellRouteData {
  const NavigationBarRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return NavigationBarScreen(navigationShell: navigationShell);
  }
}

class FlowRoute extends GoRouteData {
  const FlowRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FlowScreen();
}

class SearchRoute extends GoRouteData {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SearchScreen();
}

class PrayerRoute extends GoRouteData {
  const PrayerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PrayerScreen();
}

class DhikrRoute extends GoRouteData {
  const DhikrRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DhikrScreen();
}

class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

@TypedGoRoute<CreateProfileRoute>(path: '/create_profile')
class CreateProfileRoute extends GoRouteData {
  const CreateProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateProfileScreen();
}

/// Creates and returns the app router with refresh listenable support
GoRouter createAppRouter(Listenable refreshListenable) => GoRouter(
  routes: $appRoutes,
  initialLocation: '/',
  routerNeglect: false,
  redirect: _redirect,
  refreshListenable: refreshListenable,
);

/// Auth screens that authenticated users should not access
final _unAuthenticatedUserRoutes = {
  const OnboardingRoute().location,
  const SignInRoute().location,
  const SignUpRoute().location,
  const EmailVerificationRoute().location,
};

/// Protected routes that require authentication and email verification
final _protectedRoutes = {
  // NavigationBarRouteData branch routes
  const FlowRoute().location,
  const SearchRoute().location,
  const PrayerRoute().location,
  const DhikrRoute().location,
  const ProfileRoute().location,
  // Other protected routes
  const CreateProfileRoute().location,
};

String? _redirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;

  final authRepository = context.read<AuthRepository>();
  final userRepository = context.read<UserRepository>();

  // Check if user is authenticated - use auth.value.isSignedIn() like example app
  final isSignedIn = authRepository.auth.value.isSignedIn();

  // Signed in but navigating to auth screens: redirect based on profile status
  if (isSignedIn && _unAuthenticatedUserRoutes.contains(location)) {
    // Check if email is verified - önce Auth'dan kontrol et (Firebase Auth kaynağı)
    final currentAuth = authRepository.auth.value;
    final currentUser = userRepository.currentUser.value;

    // Auth'dan emailVerified kontrolü (öncelikli)
    // Eğer User data yüklenmemişse Auth'u kullan, yüklenmişse User'ı fallback olarak kullan
    final isEmailVerified = currentAuth.isSignedIn()
        ? currentAuth.isEmailVerified
        : (currentUser.isEmpty() ? false : currentUser.emailVerified);

    if (!isEmailVerified) {
      // Email not verified, allow access to email verification
      if (location == const EmailVerificationRoute().location) {
        return null;
      }
      // Otherwise redirect to email verification
      return const EmailVerificationRoute().location;
    }

    // Email verified, check if profile is created
    final isUserProfileCreated = !currentUser.isEmpty();
    print('isUserProfileCreated: $isUserProfileCreated');

    if (!isUserProfileCreated) {
      // Profile not created, redirect to create profile
      if (location == const CreateProfileRoute().location) {
        return null;
      }
      return const CreateProfileRoute().location;
    }

    // Email verified and profile created, redirect to navigation bar
    return const FlowRoute().location;
  }

  // Not signed in and navigating to protected routes: redirect to sign in
  if (!isSignedIn && _protectedRoutes.contains(location)) {
    return const SignInRoute().location;
  }

  // Signed in and navigating to protected routes: check email verification and profile
  if (isSignedIn && _protectedRoutes.contains(location)) {
    // Check if email is verified - önce Auth'dan kontrol et (Firebase Auth kaynağı)
    final currentAuth = authRepository.auth.value;
    final currentUser = userRepository.currentUser.value;

    // Auth'dan emailVerified kontrolü (öncelikli)
    // Eğer User data yüklenmemişse Auth'u kullan, yüklenmişse User'ı fallback olarak kullan
    final isEmailVerified = currentAuth.isSignedIn()
        ? currentAuth.isEmailVerified
        : (currentUser.isEmpty() ? false : currentUser.emailVerified);

    if (!isEmailVerified) {
      // Email not verified, redirect to email verification
      return const EmailVerificationRoute().location;
    }

    // Email verified, check if profile is created
    final isProfileCreated = !currentUser.isEmpty();

    // Allow access to create profile screen if profile not created
    if (!isProfileCreated && location == const CreateProfileRoute().location) {
      return null;
    }

    // If profile not created and trying to access other protected routes, redirect to create profile
    if (!isProfileCreated) {
      return const CreateProfileRoute().location;
    }
  }

  // Unknown route, allow access (will show 404 if route doesn't exist)
  return null;
}
