import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internmatch/models/user_profile.dart';
import 'package:internmatch/services/api_service.dart';

// Singleton ApiService shared across the app
final _apiService = ApiService();

final userProvider = StateNotifierProvider<UserNotifier, UserProfile>((ref) {
  return UserNotifier(_apiService);
});

class UserNotifier extends StateNotifier<UserProfile> {
  final ApiService _api;

  UserNotifier(this._api) : super(const UserProfile()) {
    _restoreSession();
  }

  // ─── Session restoration ──────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    try {
      final token = await _api.getStoredToken();
      final userId = await _api.getStoredUserId();
      if (token != null && userId != null) {
        state = state.copyWith(
          id: userId,
          isAuthenticated: true,
        );
        // Optionally load full profile in background
        _loadProfile(userId);
      }
    } catch (_) {
      // Silent fail — user stays unauthenticated
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _api.getProfile(userId);
      state = profile.copyWith(
        isAuthenticated: true,
        onboardingComplete: profile.skills.isNotEmpty,
        // Preserve any locally set onboarding fields not in backend profile
        savedInternships: state.savedInternships,
        appliedInternships: state.appliedInternships,
        notifications: state.notifications,
      );
    } catch (_) {
      // Keep current state if profile load fails
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Login with real backend. Throws on failure.
  Future<void> login(String email, String password) async {
    final data = await _api.login(email, password);
    final userId = data['user_id'] as String? ?? '';
    final name = data['name'] as String? ?? email.split('@').first;
    state = state.copyWith(
      id: userId,
      email: email,
      name: name,
      fullName: name,
      isAuthenticated: true,
    );
    // Load full profile in background
    if (userId.isNotEmpty) _loadProfile(userId);
  }

  /// Register with real backend. Throws on failure.
  Future<void> register(String email, String password, {String name = ''}) async {
    final data = await _api.register(name, email, password);
    final userId = data['user_id'] as String? ?? '';
    final serverName = data['name'] as String? ?? name;
    state = state.copyWith(
      id: userId,
      email: email,
      name: serverName,
      fullName: serverName,
      isAuthenticated: true,
    );
  }

  void logout() {
    _api.logout();
    state = const UserProfile();
  }

  // ─── Profile update (local + backend sync) ────────────────────────────────

  void updateProfile({
    String? fullName,
    String? phoneNo,
    String? avatarColor,
    String? degree,
    String? branch,
    String? currentYear,
    String? cgpa,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phoneNo: phoneNo,
      avatarColor: avatarColor,
      degree: degree,
      branch: branch,
      currentYear: currentYear,
      cgpa: cgpa,
    );
    _syncProfile();
  }

  void updateEducation(String educationLevel) {
    state = state.copyWith(educationLevel: educationLevel);
  }

  void updateExperience(String experienceLevel) {
    state = state.copyWith(experienceLevel: experienceLevel);
  }

  void updateInternshipHistory(bool hasDone, String description) {
    state = state.copyWith(
      hasDoneInternship: hasDone,
      internshipDescription: description,
    );
  }

  void updateSkills(List<String> skills) {
    state = state.copyWith(skills: skills);
  }

  void updateTools(List<String> tools) {
    state = state.copyWith(tools: tools);
  }

  void updateInterests(List<String> interests) {
    state = state.copyWith(interests: interests);
  }

  void updatePreferences({
    String? preferredLocation,
    String? internshipType,
    String? duration,
  }) {
    state = state.copyWith(
      preferredLocation: preferredLocation,
      internshipType: internshipType,
      duration: duration,
    );
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
    _syncProfile();
  }

  /// Push local profile state to backend
  Future<void> _syncProfile() async {
    if (state.id.isEmpty) return;
    try {
      await _api.updateProfile(state.id, state.toJson());
    } catch (_) {
      // Ignore sync errors — state is already updated locally
    }
  }

  // ─── Bookmarks (local + backend) ─────────────────────────────────────────

  void toggleSaveInternship(String internshipId) {
    final saved = List<String>.from(state.savedInternships);
    if (saved.contains(internshipId)) {
      saved.remove(internshipId);
      if (state.id.isNotEmpty) {
        _api.removeBookmark(state.id, internshipId).catchError((_) {});
      }
    } else {
      saved.add(internshipId);
      if (state.id.isNotEmpty) {
        _api.bookmarkInternship(state.id, internshipId).catchError((_) {});
      }
    }
    state = state.copyWith(savedInternships: saved);
  }

  // ─── Applications ─────────────────────────────────────────────────────────

  void addAppliedInternship(AppliedInternship internship) {
    final applied = List<AppliedInternship>.from(state.appliedInternships);
    applied.add(internship);
    state = state.copyWith(appliedInternships: applied);
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  void addNotification(UserNotification notification) {
    final notifications = List<UserNotification>.from(state.notifications);
    notifications.insert(0, notification);
    state = state.copyWith(notifications: notifications);
  }

  void markNotificationAsRead(String notificationId) {
    final notifications = state.notifications.map((n) =>
      n.id == notificationId
        ? UserNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            time: n.time,
            read: true,
            type: n.type,
          )
        : n
    ).toList();
    state = state.copyWith(notifications: notifications);
  }

  int get unreadNotificationCount {
    return state.notifications.where((n) => !n.read).length;
  }
}
