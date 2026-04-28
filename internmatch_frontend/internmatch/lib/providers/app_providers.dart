import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';
import '../data/internships_data.dart';

// ─── CORE PROVIDERS ────────────────────────────────────────────────────────

// Singleton instance shared across all providers
final _sharedApiService = ApiService();

final apiServiceProvider = Provider<ApiService>((ref) => _sharedApiService);

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
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
      final cgpa = double.tryParse(profile.cgpa) ?? 0.0;
      Future<List<Internship>> fetchFromApi() {
        return _apiService.getRecommendations(
          skills: profile.skills,
          cgpa: cgpa,
          interests: profile.interests,
          preferredLocation: profile.preferredLocation,
          preferredType:
              profile.internshipType.isNotEmpty ? profile.internshipType : 'Any',
        );
      }

      List<Internship> results;
      try {
        results = await fetchFromApi();
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _apiService.clearAuth();
          results = await fetchFromApi();
        } else {
          rethrow;
        }
      }
      state = state.copyWith(
        internships: results,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      // Fall back to local data with locally calculated match scores
      final localRecommendations = getRecommendations(
        skills: profile.skills,
        tools: profile.tools,
        interests: profile.interests,
        preferredLocation: profile.preferredLocation,
        internshipType: profile.internshipType,
        duration: profile.duration,
      );
      state = state.copyWith(
        internships: localRecommendations,
        isLoading: false,
        error: 'Using offline data: ${e.toString()}',
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
    _loadAll();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      List<Internship> results;
      try {
        results = await _apiService.searchInternships();
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _apiService.clearAuth();
          results = await _apiService.searchInternships();
        } else {
          rethrow;
        }
      }
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      print('API SEARCH ERROR (_loadAll): $e');
      // Fall back to local data
      state = state.copyWith(results: internshipData, isLoading: false);
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, query: query);
    try {
      Future<List<Internship>> searchApi() {
        return _apiService.searchInternships(
          query: query.isNotEmpty ? query : null,
          domain: state.selectedDomain,
          type: state.selectedType,
        );
      }

      List<Internship> results;
      try {
        results = await searchApi();
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _apiService.clearAuth();
          results = await searchApi();
        } else {
          rethrow;
        }
      }
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      print('API SEARCH ERROR (search): $e');
      // Filter local data
      final filtered = internshipData.where((i) {
        final matchQ = query.isEmpty ||
            i.title.toLowerCase().contains(query.toLowerCase()) ||
            i.company.toLowerCase().contains(query.toLowerCase());
        final matchD = state.selectedDomain == null || i.domain == state.selectedDomain;
        return matchQ && matchD;
      }).toList();
      state = state.copyWith(results: filtered, isLoading: false);
    }
  }

  Future<void> applyFilter({String? domain, String? type}) async {
    state = state.copyWith(
      isLoading: true,
      selectedDomain: domain,
      selectedType: type,
    );
    try {
      Future<List<Internship>> filterApi() {
        return _apiService.searchInternships(
          query: state.query.isNotEmpty ? state.query : null,
          domain: domain,
          type: type,
        );
      }

      List<Internship> results;
      try {
        results = await filterApi();
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _apiService.clearAuth();
          results = await filterApi();
        } else {
          rethrow;
        }
      }
      state = state.copyWith(results: results, isLoading: false);
    } catch (_) {
      final filtered = internshipData.where((i) {
        final matchD = domain == null || i.domain == domain;
        final matchT = type == null || i.locationType == type;
        return matchD && matchT;
      }).toList();
      state = state.copyWith(results: filtered, isLoading: false);
    }
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
    try {
      final bookmarks = await _apiService.getBookmarks(userId);
      state = bookmarks;
    } catch (_) {
      // Keep current state if load fails
    }
  }

  void toggle(Internship internship) {
    if (state.any((i) => i.id == internship.id)) {
      state = state.where((i) => i.id != internship.id).toList();
    } else {
      state = [...state, internship.copyWith(isBookmarked: true)];
    }
  }
}
