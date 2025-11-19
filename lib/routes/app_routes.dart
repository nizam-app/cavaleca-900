import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/core/widget/global_snack_bar.dart';
import 'package:workpleis/features/auth/screens/login_screen.dart';
import 'package:workpleis/features/auth/screens/register_screen.dart';
import 'package:workpleis/features/auth/screens/splash_screen.dart';

import 'error_screen.dart';
class AppRouter {
  static final String initial = SplashScreen.routeName;
 static final GoRouter appRouter = GoRouter(
      initialLocation:initial,
      errorBuilder: (context, state) {
        final String badPath = state.uri.toString() ?? state.uri.toString() ?? '';
        return CustomGoErrorPage(
          location: badPath,
          error: state.error,
          onRetry: () => context.go(initial),
          onReport: () {
            GlobalSnackBar.show(context, title: "We're sorry", message: "'Thanks, we'll look into this.'");
          },
        );
      },

      routes: <RouteBase>[
        GoRoute(
          path: SplashScreen.routeName,
          name: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: LoginScreen.routeName,
          name: LoginScreen.routeName,
          builder: (context, state) => const LoginScreen(),
        ), GoRoute(
          path: RegisterScreen.routeName,
          name: RegisterScreen.routeName,
          builder: (context, state) => const RegisterScreen(),
        ),

      ]);
}
