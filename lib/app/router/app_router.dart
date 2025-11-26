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
      const UserProfileScreen();
}

@TypedGoRoute<UserInitializeRoute>(path: '/user_initialize')
class UserInitializeRoute extends GoRouteData {
  const UserInitializeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UserInitializeScreen();
}

@TypedGoRoute<CreateProfileRoute>(path: '/create_profile')
class CreateProfileRoute extends GoRouteData {
  const CreateProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateUserProfileScreen();
}

@TypedGoRoute<EditProfileRoute>(path: '/profile/edit_profile')
class EditProfileRoute extends GoRouteData {
  const EditProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EditProfileScreen();
}

/// Creates and returns the app router with refresh listenable support
GoRouter createAppRouter(Listenable refreshListenable) => GoRouter(
  routes: $appRoutes,
  initialLocation: '/',
  routerNeglect: false,
  redirect: _redirect,
  refreshListenable: refreshListenable,
);

String? _redirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;
  final authRepository = context.read<AuthRepository>();
  final userRepository = context.read<UserRepository>();

  final isSignedIn = authRepository.auth.value.isSignedIn();
  final auth = authRepository.auth.value;
  final user = userRepository.currentUser.value;

  // Auth screens
  final authLocs = [
    const OnboardingRoute().location,
    const SignInRoute().location,
    const SignUpRoute().location,
    const EmailVerificationRoute().location,
  ];

  // Routes that handle their own redirect logic
  final noRuleLocs = [
    const UserInitializeRoute().location,
    const CreateProfileRoute().location,
    const EditProfileRoute().location,
  ];

  // Allow routes with no rules
  if (noRuleLocs.contains(location)) return null;

  // Not signed in: allow auth screens, redirect others to sign in
  if (!isSignedIn) {
    if (authLocs.contains(location)) return null;
    return const SignInRoute().location;
  }

  // Signed in but navigating to auth screens: redirect based on status
  if (isSignedIn && authLocs.contains(location)) {
    if (!auth.isEmailVerified) {
      if (location == const EmailVerificationRoute().location) return null;
      return const EmailVerificationRoute().location;
    }
    if (user.uid.isEmpty) return const UserInitializeRoute().location;
    if (!user.isRegistered) return const CreateProfileRoute().location;
    return const FlowRoute().location;
  }

  // Signed in: enforce requirements for protected routes
  if (!auth.isEmailVerified) {
    if (location == const EmailVerificationRoute().location) return null;
    return const EmailVerificationRoute().location;
  }
  if (user.uid.isEmpty) {
    if (location == const UserInitializeRoute().location) return null;
    return const UserInitializeRoute().location;
  }
  if (!user.isRegistered) {
    if (location == const CreateProfileRoute().location) return null;
    return const CreateProfileRoute().location;
  }

  return null;
}
