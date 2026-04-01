import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_shell.dart';
import '../screens/internship_detail_screen.dart';
import '../screens/applications_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../models/internship.dart';

// ─── Route names (use these everywhere — no raw strings) ─────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String detail = '/internship/:id';
  static const String applications = '/applications';
  static const String bookmarks = '/bookmarks';
  static const String editProfile = '/profile/edit';
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
      final isPublicRoute = loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.welcome ||
          loc == AppRoutes.splash ||
          loc == AppRoutes.onboarding;

      // Not logged in and trying to reach a protected route
      if (!isAuth && !isPublicRoute) {
        return AppRoutes.welcome;
      }

      // Already logged in, no need to show welcome/login
      if (isAuth &&
          (loc == AppRoutes.welcome ||
              loc == AppRoutes.login ||
              loc == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null; // No redirect
    },

    // ── Routes ──────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const AuthScreen(isLogin: true),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const AuthScreen(isLogin: false),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const MainShell(),
        routes: [
          // Nested under /home so back button goes back to shell
          GoRoute(
            path: 'internship/:id',
            builder: (context, state) {
              // Extra is passed when navigating programmatically
              final internship = state.extra as Internship?;
              if (internship == null) {
                // Fallback: deep link without object, show placeholder
                return const _InternshipNotFound();
              }
              return InternshipDetailScreen(internship: internship);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.applications,
        builder: (_, __) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        builder: (_, __) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, __) => const ProfileScreen(isOnboarding: false),
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
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─── Helper: navigate to detail screen ───────────────────────────────────────

extension GoRouterX on BuildContext {
  void goToDetail(Internship internship) {
    go('/home/internship/${internship.id}', extra: internship);
  }

  void pushToDetail(Internship internship) {
    push('/home/internship/${internship.id}', extra: internship);
  }
}

// ─── Fallback widget ─────────────────────────────────────────────────────────

class _InternshipNotFound extends StatelessWidget {
  const _InternshipNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Internship not found',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
