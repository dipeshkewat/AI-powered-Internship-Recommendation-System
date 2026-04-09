import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';

// ─── CORE PROVIDERS ────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// ─── AUTH STATE ────────────────────────────────────────────────────────────

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await _apiService.getStoredToken();
      final userId = await _apiService.getStoredUserId();
      
      if (token != null && userId != null) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          userId: userId,
        );
      }
    } catch (e) {
      // Silent fail - user not authenticated
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.login(email, password);
      final token = data['access_token'] ?? data['token'];
      final userId = data['user_id'] ?? data['user']['id'];
      
      if (token == null || userId == null) {
        throw Exception('Invalid response: missing token or user_id');
      }

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId.toString(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.register(name, email, password);
      final token = data['access_token'] ?? data['token'];
      final userId = data['user_id'] ?? data['user']['id'];
      
      if (token == null || userId == null) {
        throw Exception('Invalid response: missing token or user_id');
      }

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId.toString(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

// ─── USER PROFILE ──────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<UserProfile> {
  final ApiService _apiService;

  ProfileNotifier(this._apiService) : super(UserProfile.empty());

  Future<void> loadProfile(String userId) async {
    try {
      final profile = await _apiService.getProfile(userId);
      state = profile;
    } catch (_) {
      // Keep current state
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final updated = await _apiService.updateProfile(state.id, data);
      state = updated;
    } catch (_) {
      // Apply locally optimistically
      state = state.copyWith(
        skills: (data['skills'] as List<String>?) ?? state.skills,
        cgpa: (data['cgpa'] as double?) ?? state.cgpa,
        interests: (data['interests'] as List<String>?) ?? state.interests,
        preferredLocation: (data['preferred_location'] as String?) ?? state.preferredLocation,
        preferredType: (data['preferred_type'] as String?) ?? state.preferredType,
      );
    }
  }

  void updateLocally({
    List<String>? skills,
    double? cgpa,
    List<String>? interests,
    String? preferredLocation,
    String? preferredType,
    String? name,
    String? college,
    int? graduationYear,
  }) {
    state = state.copyWith(
      skills: skills ?? state.skills,
      cgpa: cgpa ?? state.cgpa,
      interests: interests ?? state.interests,
      preferredLocation: preferredLocation ?? state.preferredLocation,
      preferredType: preferredType ?? state.preferredType,
      name: name ?? state.name,
      college: college ?? state.college,
      graduationYear: graduationYear ?? state.graduationYear,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref.read(apiServiceProvider));
});

// ─── RECOMMENDATIONS ───────────────────────────────────────────────────────

class RecommendationState {
  final List<Internship> internships;
  final bool isLoading;
  final String? error;
  final bool hasFetched;

  const RecommendationState({
    this.internships = const [],
    this.isLoading = false,
    this.error,
    this.hasFetched = false,
  });

  RecommendationState copyWith({
    List<Internship>? internships,
    bool? isLoading,
    String? error,
    bool? hasFetched,
  }) {
    return RecommendationState(
      internships: internships ?? this.internships,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final ApiService _apiService;

  RecommendationNotifier(this._apiService) : super(const RecommendationState());

  Future<void> fetchRecommendations(UserProfile profile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _apiService.getRecommendations(
        skills: profile.skills,
        cgpa: profile.cgpa,
        interests: profile.interests,
        preferredLocation: profile.preferredLocation,
        preferredType: profile.preferredType,
      );
      state = state.copyWith(
        internships: results,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasFetched: true,
      );
    }
  }

  void toggleBookmark(String internshipId) {
    state = state.copyWith(
      internships: state.internships.map((i) {
        if (i.id == internshipId) {
          return i.copyWith(isBookmarked: !i.isBookmarked);
        }
        return i;
      }).toList(),
    );
  }
}

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  return RecommendationNotifier(ref.read(apiServiceProvider));
});

// ─── SEARCH ────────────────────────────────────────────────────────────────

class SearchState {
  final List<Internship> results;
  final bool isLoading;
  final String query;
  final String? selectedDomain;
  final String? selectedType;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.selectedDomain,
    this.selectedType,
  });

  SearchState copyWith({
    List<Internship>? results,
    bool? isLoading,
    String? query,
    String? selectedDomain,
    String? selectedType,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      selectedDomain: selectedDomain ?? this.selectedDomain,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService;

  SearchNotifier(this._apiService) : super(const SearchState()) {
    // Load initial listings
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    final results = await _apiService.searchInternships();
    state = state.copyWith(results: results, isLoading: false);
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, query: query);
    final results = await _apiService.searchInternships(
      query: query.isNotEmpty ? query : null,
      domain: state.selectedDomain,
      type: state.selectedType,
    );
    state = state.copyWith(results: results, isLoading: false);
  }

  Future<void> applyFilter({String? domain, String? type}) async {
    state = state.copyWith(
      isLoading: true,
      selectedDomain: domain,
      selectedType: type,
    );
    final results = await _apiService.searchInternships(
      query: state.query.isNotEmpty ? state.query : null,
      domain: domain,
      type: type,
    );
    state = state.copyWith(results: results, isLoading: false);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(apiServiceProvider));
});

// ─── BOOKMARKS ─────────────────────────────────────────────────────────────

final bookmarksProvider = StateNotifierProvider<BookmarkNotifier, List<Internship>>((ref) {
  return BookmarkNotifier(ref.read(apiServiceProvider));
});

class BookmarkNotifier extends StateNotifier<List<Internship>> {
  final ApiService _apiService;

  BookmarkNotifier(this._apiService) : super([]);

  Future<void> loadBookmarks(String userId) async {
    final bookmarks = await _apiService.getBookmarks(userId);
    state = bookmarks;
  }

  void toggle(Internship internship) {
    if (state.any((i) => i.id == internship.id)) {
      state = state.where((i) => i.id != internship.id).toList();
    } else {
      state = [...state, internship.copyWith(isBookmarked: true)];
    }
  }
}
