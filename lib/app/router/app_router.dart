import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

final GoRouter appRouter = GoRouter(
  routes: $appRoutes,
  initialLocation: '/',
  routerNeglect: false,
  //redirect: (BuildContext context, GoRouterState state) {},
);
