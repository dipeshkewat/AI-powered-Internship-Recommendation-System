import 'package:flutter/foundation.dart';

/// Single source of truth for magic strings, limits, and config values.
/// Import this anywhere instead of hardcoding strings.
class AppConstants {
  AppConstants._();

  // ─── API ───────────────────────────────────────────────────────────────────
  static const String baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (baseUrlOverride.isNotEmpty) return baseUrlOverride;
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  // Endpoint paths (append to baseUrl)
  static const String endpointLogin = '/auth/login';
  static const String endpointRegister = '/auth/register';
  static const String endpointRefresh = '/auth/refresh';
  static const String endpointProfile = '/users/{id}/profile';
  static const String endpointRecommendations = '/recommendations';
  static const String endpointInternships = '/internships';
  static const String endpointBookmarks = '/users/{id}/bookmarks';
  static const String endpointApply = '/internships/{id}/apply';

  // ─── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int recommendationsLimit = 30;

  // ─── Storage keys (mirrors StorageService — for doc purposes only) ─────────
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyProfile = 'user_profile_json';
  static const String keyBookmarks = 'bookmarked_ids';
  static const String keyApplications = 'applications_json';
  static const String keyOnboarding = 'onboarding_done';

  // ─── Validation limits ─────────────────────────────────────────────────────
  static const int minPasswordLength = 6;
  static const int maxSkillsCount = 20;
  static const double minCgpa = 0.0;
  static const double maxCgpa = 10.0;

  // ─── UI ────────────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
  static const double pagePadding = 20.0;
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ─── Domains ───────────────────────────────────────────────────────────────
  static const List<String> internshipDomains = [
    'AI/ML',
    'App Dev',
    'Web',
    'Data Science',
    'Cloud',
    'DevOps',
    'Cybersecurity',
    'UI/UX',
    'Blockchain',
    'Game Dev',
  ];

  static const List<String> workTypes = [
    'Remote',
    'Hybrid',
    'On-site',
  ];

  static const List<String> skillSuggestions = [
    'Flutter',
    'Dart',
    'Python',
    'React',
    'Node.js',
    'FastAPI',
    'MongoDB',
    'Firebase',
    'ML',
    'scikit-learn',
    'PyTorch',
    'TensorFlow',
    'Java',
    'Kotlin',
    'Swift',
    'SQL',
    'PostgreSQL',
    'Docker',
    'Git',
    'REST APIs',
    'GraphQL',
    'TypeScript',
    'Next.js',
    'AWS',
    'GCP',
  ];

  // ─── Onboarding steps ──────────────────────────────────────────────────────
  static const List<Map<String, String>> onboardingSteps = [
    {
      'title': 'Smart Matching',
      'subtitle':
          'Our ML model reads your skills, CGPA, and interests to find your best-fit internships — not just keyword matches.',
      'icon': '🤖',
    },
    {
      'title': 'Build Your Profile',
      'subtitle':
          'Add your skills, preferred domain, and location. The more you add, the better your matches get.',
      'icon': '👤',
    },
    {
      'title': 'Track Everything',
      'subtitle':
          'Applied somewhere? Log it. Update the status as you progress. Never lose track of an opportunity.',
      'icon': '📋',
    },
  ];
}
