import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen_new.dart';
import '../screens/auth_screen_new.dart';
import '../screens/main_shell_new.dart';
import '../screens/onboarding_new.dart';
import '../screens/internship_detail_new.dart';

// ─── Route names (use these everywhere — no raw strings) ─────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String mainShell = '/main-shell';
  static const String internshipDetail = '/internship/:id';
}

// ─── Router provider ─────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Redirect guard ──────────────────────────────────────────────────────
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;

      final isPublicRoute = loc == AppRoutes.auth ||
          loc == AppRoutes.welcome ||
          loc == AppRoutes.splash ||
          loc.startsWith(AppRoutes.onboarding);

      // Not logged in and trying to reach a protected route
      if (!isAuth && !isPublicRoute) {
        return AppRoutes.welcome;
      }

      // Already logged in, no need to show welcome/login
      if (isAuth &&
          (loc == AppRoutes.welcome || loc == AppRoutes.auth)) {
        return AppRoutes.mainShell;
      }

      return null; // No redirect
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreenNew(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'login';
          return AuthScreenNew(mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreenNew(),
      ),
      GoRoute(
        path: AppRoutes.mainShell,
        builder: (_, __) => const MainShellNew(),
        routes: [
          GoRoute(
            path: 'internship/:id',
            builder: (context, state) {
              final internshipId = state.pathParameters['id'] ?? '';
              return InternshipDetailScreenNew(internshipId: internshipId);
            },
          ),
        ],
      ),
    ],

    // ── Error page ───────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.mainShell),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
