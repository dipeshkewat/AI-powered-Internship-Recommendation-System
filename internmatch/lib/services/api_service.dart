import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';

const String _baseUrl = 'http://localhost:8000/api/v1';

class ApiService {
  late final Dio _dio;
  SharedPreferences? _prefs;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
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
          final token = _prefs?.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Centralized error handling
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - clear stored token
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

  Future<void> saveToken(String token, String userId) async {
    await _initPrefs();
    await _prefs?.setString('auth_token', token);
    await _prefs?.setString('user_id', userId);
  }

  Future<void> clearAuth() async {
    await _initPrefs();
    await _prefs?.remove('auth_token');
    await _prefs?.remove('user_id');
  }

  Future<String?> getStoredToken() async {
    await _initPrefs();
    return _prefs?.getString('auth_token');
  }

  Future<String?> getStoredUserId() async {
    await _initPrefs();
    return _prefs?.getString('user_id');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] ?? data['token'];
      final userId = data['user_id'] ?? data['user']['id'];
      
      if (token != null && userId != null) {
        await saveToken(token, userId.toString());
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] ?? data['token'];
      final userId = data['user_id'] ?? data['user']['id'];
      
      if (token != null && userId != null) {
        await saveToken(token, userId.toString());
      }
      return data;
    } catch (e) {
      rethrow;
    }
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

  /// Calls the FastAPI ML recommendation endpoint.
  /// Sends user profile features → receives ranked internships.
  Future<List<Internship>> getRecommendations({
    required List<String> skills,
    required double cgpa,
    required List<String> interests,
    required String preferredLocation,
    required String preferredType,
  }) async {
    try {
      final response = await _dio.post('/recommendations', data: {
        'skills': skills,
        'cgpa': cgpa,
        'interests': interests,
        'preferred_location': preferredLocation,
        'preferred_type': preferredType,
      });
      final List<dynamic> data = response.data['recommendations'] as List;
      return data
          .map((item) => Internship.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback to dummy data during development
      return InternshipDummy.getSamples();
    }
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
    try {
      final response = await _dio.get('/internships', queryParameters: {
        if (query != null) 'q': query,
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
    } catch (_) {
      return InternshipDummy.getSamples()
          .where((i) =>
              query == null ||
              i.title.toLowerCase().contains(query.toLowerCase()) ||
              i.company.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // ─── BOOKMARKS ─────────────────────────────────────────────────────────────

  Future<void> bookmarkInternship(String userId, String internshipId) async {
    await _dio.post('/users/$userId/bookmarks/$internshipId');
  }

  Future<void> removeBookmark(String userId, String internshipId) async {
    await _dio.delete('/users/$userId/bookmarks/$internshipId');
  }

  Future<List<Internship>> getBookmarks(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/bookmarks');
      final List<dynamic> data = response.data['bookmarks'] as List;
      return data
          .map((item) => Internship.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> uploadResume(String userId, String filePath) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath),
    });
    await _dio.put('/users/$userId/resume', data: formData);
  }
}
