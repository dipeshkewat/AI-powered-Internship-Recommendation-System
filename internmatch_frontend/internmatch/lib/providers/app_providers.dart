import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';
import 'user_provider.dart';

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
      state = state.copyWith(
        internships: const [],
        isLoading: false,
        error: 'Failed to fetch recommendations: ${e.toString()}',
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
  final Ref _ref;
  List<Internship> _allRecommended = const [];

  SearchNotifier(this._apiService, this._ref) : super(const SearchState()) {
    _loadAll();
  }

  List<Internship> _applyLocalFilters(List<Internship> source) {
    final query = state.query.trim().toLowerCase();
    return source.where((i) {
      final matchesQuery = query.isEmpty ||
          i.title.toLowerCase().contains(query) ||
          i.company.toLowerCase().contains(query) ||
          i.requiredSkills.any((s) => s.toLowerCase().contains(query));
      final matchesDomain = state.selectedDomain == null || i.domain == state.selectedDomain;
      final matchesType = state.selectedType == null || i.locationType == state.selectedType;
      return matchesQuery && matchesDomain && matchesType;
    }).toList();
  }

  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = _ref.read(userProvider);
      if (profile.skills.isEmpty || profile.interests.isEmpty) {
        _allRecommended = const [];
        state = state.copyWith(results: const [], isLoading: false);
        return;
      }

      final cgpa = double.tryParse(profile.cgpa) ?? 0.0;
      List<Internship> results = await _apiService.getRecommendations(
        skills: profile.skills,
        cgpa: cgpa,
        interests: profile.interests,
        preferredLocation: profile.preferredLocation,
        preferredType: profile.internshipType.isNotEmpty ? profile.internshipType : 'Any',
      );
      results.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      _allRecommended = results.take(5).toList();
      state = state.copyWith(
        results: _applyLocalFilters(_allRecommended),
        isLoading: false,
      );
    } catch (e) {
      _allRecommended = const [];
      state = state.copyWith(results: const [], isLoading: false);
    }
  }

  Future<void> refreshTopMatches() async {
    await _loadAll();
  }

  Future<void> search(String query) async {
    state = state.copyWith(
      isLoading: false,
      query: query,
      results: _applyLocalFilters(_allRecommended),
    );
  }

  Future<void> applyFilter({String? domain, String? type}) async {
    state = state.copyWith(
      isLoading: false,
      selectedDomain: domain,
      selectedType: type,
      results: _applyLocalFilters(_allRecommended),
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(apiServiceProvider), ref);
});

// ─── DASHBOARD INTERNSHIP FEED (real backend data) ─────────────────────────

class InternshipFeedState {
  final List<Internship> internships;
  final bool isLoading;
  final String? error;

  const InternshipFeedState({
    this.internships = const [],
    this.isLoading = false,
    this.error,
  });

  InternshipFeedState copyWith({
    List<Internship>? internships,
    bool? isLoading,
    String? error,
  }) {
    return InternshipFeedState(
      internships: internships ?? this.internships,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InternshipFeedNotifier extends StateNotifier<InternshipFeedState> {
  final ApiService _apiService;

  InternshipFeedNotifier(this._apiService) : super(const InternshipFeedState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _apiService.searchInternships(limit: 50);
      state = state.copyWith(
        internships: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        internships: const [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final internshipFeedProvider =
    StateNotifierProvider<InternshipFeedNotifier, InternshipFeedState>((ref) {
  return InternshipFeedNotifier(ref.read(apiServiceProvider));
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
