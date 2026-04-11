import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: unused_import

import 'package:internmatch/screens/splash_screen.dart';
import 'package:internmatch/screens/welcome_screen.dart';
import 'package:internmatch/screens/auth_screen.dart';
import 'package:internmatch/screens/onboarding_screen.dart';
import 'package:internmatch/screens/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String mainShell = '/app';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadePage(
          state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => _slidePage(
          state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => _slidePage(
          state, const AuthScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _slidePage(
          state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.mainShell,
        pageBuilder: (context, state) => _fadePage(
          state, const MainShell()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.welcome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return SlideTransition(position: slide, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
