import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';

// Optional override:
// flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000/api/v1
const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

String _resolveBaseUrl() {
  if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;

  if (kIsWeb) {
    return 'http://localhost:8000/api/v1';
  }

  // Android emulator maps host loopback to 10.0.2.2.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api/v1';
  }

  return 'http://localhost:8000/api/v1';
}

class ApiService {
  late final Dio _dio;
  SharedPreferences? _prefs;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Initialize SharedPreferences asynchronously
    _initPrefs();

    // Request interceptor: attach JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure prefs are loaded before attaching token
          if (_prefs == null) await _initPrefs();
          final token = _prefs?.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Clear stored credentials on 401
          if (error.response?.statusCode == 401) {
            _prefs?.remove('auth_token');
            _prefs?.remove('user_id');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─── TOKEN MANAGEMENT ─────────────────────────────────────────────────────

  Future<void> saveToken(String token, String userId) async {
    await _initPrefs();
    await _prefs!.setString('auth_token', token);
    await _prefs!.setString('user_id', userId);
  }

  Future<void> clearAuth() async {
    await _initPrefs();
    await _prefs!.remove('auth_token');
    await _prefs!.remove('user_id');
  }

  Future<String?> getStoredToken() async {
    await _initPrefs();
    return _prefs?.getString('auth_token');
  }

  Future<String?> getStoredUserId() async {
    await _initPrefs();
    return _prefs?.getString('user_id');
  }

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  /// Login with email + password.
  /// Returns the full TokenResponse map from backend.
  /// Throws [DioException] on network/server errors.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    final userId = data['user_id'] as String?;
    if (token != null && userId != null) {
      await saveToken(token, userId);
    }
    return data;
  }

  /// Register a new account.
  /// Returns the full TokenResponse map from backend.
  /// Throws [DioException] on network/server errors.
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    final userId = data['user_id'] as String?;
    if (token != null && userId != null) {
      await saveToken(token, userId);
    }
    return data;
  }

  Future<void> logout() async {
    await clearAuth();
  }

  // ─── PROFILE ───────────────────────────────────────────────────────────────

  Future<UserProfile> getProfile(String userId) async {
    final response = await _dio.get('/users/$userId/profile');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(
      String userId, Map<String, dynamic> data) async {
    final response = await _dio.put('/users/$userId/profile', data: data);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── RECOMMENDATIONS (ML endpoint) ─────────────────────────────────────────

  List<String> _normalizeInterestsForBackend(List<String> interests) {
    // Onboarding labels -> MongoDB domain labels
    final mapped = <String>[];
    for (final raw in interests) {
      final s = raw.trim();
      if (s.isEmpty) continue;
      switch (s.toLowerCase()) {
        case 'web dev':
          mapped.add('Web Development');
          break;
        case 'app dev':
          mapped.add('Mobile App Development');
          break;
        case 'data science':
          mapped.add('Data Analytics');
          break;
        case 'ai/ml':
          mapped.add('Machine Learning');
          break;
        case 'cybersecurity':
          mapped.add('Information Security');
          break;
        case 'cloud computing':
          mapped.add('Cloud Computing');
          break;
        default:
          mapped.add(s);
      }
    }
    return mapped.toSet().toList();
  }

  /// Calls the FastAPI ML recommendation endpoint.
  /// Sends user profile features → receives ranked internships.
  Future<List<Internship>> getRecommendations({
    required List<String> skills,
    required double cgpa,
    required List<String> interests,
    required String preferredLocation,
    required String preferredType,
  }) async {
    final response = await _dio.post('/recommendations', data: {
      'skills': skills,
      'cgpa': cgpa,
      'interests': _normalizeInterestsForBackend(interests),
      'preferred_location': preferredLocation,
      'preferred_type': preferredType,
    });
    final List<dynamic> data = response.data['recommendations'] as List;
    return data
        .map((item) => Internship.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ─── SEARCH ────────────────────────────────────────────────────────────────

  Future<List<Internship>> searchInternships({
    String? query,
    String? domain,
    String? type,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/internships', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      if (domain != null) 'domain': domain,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
      'page': page,
      'limit': limit,
    });
    final List<dynamic> data = response.data['results'] as List;
    return data
        .map((item) => Internship.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ─── BOOKMARKS ─────────────────────────────────────────────────────────────

  Future<void> bookmarkInternship(String userId, String internshipId) async {
    await _dio.post('/users/$userId/bookmarks/$internshipId');
  }

  Future<void> removeBookmark(String userId, String internshipId) async {
    await _dio.delete('/users/$userId/bookmarks/$internshipId');
  }

  Future<List<Internship>> getBookmarks(String userId) async {
    final response = await _dio.get('/users/$userId/bookmarks');
    final List<dynamic> data = response.data['bookmarks'] as List? ?? [];
    return data
        .map((item) => Internship.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ─── APPLICATIONS ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> applyToInternship(
      String internshipId, {String? notes}) async {
    final response = await _dio.post('/internships/$internshipId/apply',
        queryParameters: notes != null ? {'notes': notes} : null);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getApplications(String userId) async {
    final response = await _dio.get('/users/$userId/applications');
    return response.data as List<dynamic>;
  }

  // ─── FILE UPLOAD ───────────────────────────────────────────────────────────

  Future<void> uploadResume(String userId, String filePath) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath),
    });
    await _dio.put('/users/$userId/resume', data: formData);
  }
}
