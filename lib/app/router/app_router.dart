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

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<FlowRoute>(path: '/flow')
class FlowRoute extends GoRouteData {
  const FlowRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FlowScreen();
}

@TypedGoRoute<SearchRoute>(path: '/search')
class SearchRoute extends GoRouteData {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SearchScreen();
}

@TypedGoRoute<PrayerRoute>(path: '/prayer')
class PrayerRoute extends GoRouteData {
  const PrayerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PrayerScreen();
}

@TypedGoRoute<DhikrRoute>(path: '/dhikr')
class DhikrRoute extends GoRouteData {
  const DhikrRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DhikrScreen();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
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
final _authRoutes = {
  const SignInRoute().location,
  const SignUpRoute().location,
  const EmailVerificationRoute().location,
};

/// Protected routes that require authentication and email verification
final _protectedRoutes = {
  const FlowRoute().location,
  const SearchRoute().location,
  const PrayerRoute().location,
  const DhikrRoute().location,
  const ProfileRoute().location,
  const HomeRoute().location,
};

/// Public routes that don't require authentication
final _publicRoutes = {const OnboardingRoute().location};

/// Redirect logic for protected routes
///
/// Checks if user is authenticated and email is verified.
/// If not, redirects to appropriate route.
String? _redirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;

  // Public routes are always accessible
  if (_publicRoutes.contains(location)) {
    return null;
  }

  final authRepository = context.read<AuthRepository>();
  final userRepository = context.read<UserRepository>();

  // Check if user is authenticated
  final isSignedIn = authRepository.isSignedIn.value;

  // Signed in but navigating to auth screens: redirect to home
  if (isSignedIn && _authRoutes.contains(location)) {
    // Check if email is verified - önce Auth'dan kontrol et (Firebase Auth kaynağı)
    final currentAuth = authRepository.auth.value;
    final currentUser = userRepository.currentUser.value;

    // Auth'dan emailVerified kontrolü (öncelikli)
    // Eğer User data yüklenmemişse Auth'u kullan, yüklenmişse User'ı fallback olarak kullan
    final isEmailVerified = currentAuth.isSignedIn()
        ? currentAuth.isEmailVerified
        : (currentUser.isEmpty() ? false : currentUser.emailVerified);

    if (isEmailVerified) {
      // Email verified, redirect to home
      return const HomeRoute().location;
    } else {
      // Email not verified, allow access to email verification
      if (location == const EmailVerificationRoute().location) {
        return null;
      }
      // Otherwise redirect to email verification
      return const EmailVerificationRoute().location;
    }
  }

  // Not signed in and navigating to protected routes: redirect to sign in
  if (!isSignedIn && _protectedRoutes.contains(location)) {
    return const SignInRoute().location;
  }

  // Signed in and navigating to protected routes: check email verification
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
  }

  // Unknown route, allow access (will show 404 if route doesn't exist)
  return null;
}
