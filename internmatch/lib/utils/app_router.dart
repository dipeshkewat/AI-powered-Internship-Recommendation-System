import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internmatch/providers/user_provider.dart';
import 'package:internmatch/screens/welcome_screen.dart';
import 'package:internmatch/screens/auth_screen.dart';
import 'package:internmatch/screens/dashboard_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String auth = '/auth';
  static const String onboardingEducation = '/onboarding/education';
  static const String onboardingExperience = '/onboarding/experience';
  static const String onboardingPastInternship = '/onboarding/past-internship';
  static const String onboardingBasicInfo = '/onboarding/basic-info';
  static const String onboardingAcademic = '/onboarding/academic';
  static const String onboardingSkills = '/onboarding/skills';
  static const String onboardingInterests = '/onboarding/interests';
  static const String onboardingPreferences = '/onboarding/preferences';
  static const String dashboard = '/dashboard';
  static const String recommendations = '/recommendations';
  static const String search = '/search';
  static const String saved = '/saved';
  static const String applications = '/applications';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String notifications = '/notifications';
  static const String internshipDetail = '/internship/:id';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(userProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      // TODO: Add remaining onboarding routes
      // TODO: Add app routes (recommendations, search, saved, etc.)
    ],
    redirect: (context, state) {
      if (!userState.isAuthenticated && state.matchedLocation != AppRoutes.welcome && state.matchedLocation != AppRoutes.auth) {
        return AppRoutes.welcome;
      }
      return null;
    },
  );
});

      ),
    ],

    // ── Error page ───────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body = Center(
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
