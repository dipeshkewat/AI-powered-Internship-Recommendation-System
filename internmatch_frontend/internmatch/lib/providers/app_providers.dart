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
  final String? error;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.selectedDomain,
    this.selectedType,
    this.error,
  });

  SearchState copyWith({
    List<Internship>? results,
    bool? isLoading,
    String? query,
    String? selectedDomain,
    String? selectedType,
    String? error,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      selectedDomain: selectedDomain ?? this.selectedDomain,
      selectedType: selectedType ?? this.selectedType,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService;
  final Ref _ref;
  List<Internship> _all = const [];

  SearchNotifier(this._apiService, this._ref) : super(const SearchState()) {
    _loadAll();

    // IMPORTANT: SearchTab is kept alive inside an IndexedStack.
    // So initState() runs only once, and recommendations won't refresh after
    // onboarding/profile updates unless we listen for profile changes here.
    _ref.listen<UserProfile>(
      userProvider,
      (prev, next) {
        final prevSkills = prev?.skills ?? const <String>[];
        final prevInterests = prev?.interests ?? const <String>[];

        final profileBecameReady = (prevSkills.isEmpty || prevInterests.isEmpty) &&
            next.skills.isNotEmpty &&
            next.interests.isNotEmpty;

        final profileChanged = prevSkills.join('|') != next.skills.join('|') ||
            prevInterests.join('|') != next.interests.join('|') ||
            (prev?.preferredLocation ?? '') != next.preferredLocation ||
            (prev?.internshipType ?? '') != next.internshipType ||
            (prev?.cgpa ?? '') != next.cgpa;

        if (profileBecameReady || profileChanged) {
          refreshTopMatches();
        }
      },
    );
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Search should work even for new users with empty profiles.
      // Use the internships listing endpoint as the data source.
      _all = await _apiService.searchInternships(limit: 50);
      state = state.copyWith(
        results: _applyLocalFilters(_all),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      _all = const [];
      state = state.copyWith(
        results: const [],
        isLoading: false,
        error: 'Failed to load matches: ${e.toString()}',
      );
    }
  }

  Future<void> refreshTopMatches() async {
    await _loadAll();
  }

  Future<void> search(String query) async {
    state = state.copyWith(
      isLoading: false,
      query: query,
      results: _applyLocalFilters(_all),
    );
  }

  Future<void> applyFilter({String? domain, String? type}) async {
    state = state.copyWith(
      isLoading: false,
      selectedDomain: domain,
      selectedType: type,
      results: _applyLocalFilters(_all),
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
