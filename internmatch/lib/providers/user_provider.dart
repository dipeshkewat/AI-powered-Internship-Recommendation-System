import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internmatch/models/user_profile.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserProfile>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserProfile> {
  UserNotifier() : super(const UserProfile());

  void login(String email, String password) {
    // Demo login: demo@intermatch.ai / demo123
    if (email == "demo@intermatch.ai" && password == "demo123") {
      state = state.copyWith(
        email: email,
        isAuthenticated: true,
      );
    }
  }

  void register(String email, String password) {
    state = state.copyWith(
      email: email,
      password: password,
      isAuthenticated: true,
    );
  }

  void logout() {
    state = const UserProfile();
  }

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
  }

  void toggleSaveInternship(String internshipId) {
    final saved = List<String>.from(state.savedInternships);
    if (saved.contains(internshipId)) {
      saved.remove(internshipId);
    } else {
      saved.add(internshipId);
    }
    state = state.copyWith(savedInternships: saved);
  }

  void addAppliedInternship(AppliedInternship internship) {
    final applied = List<AppliedInternship>.from(state.appliedInternships);
    applied.add(internship);
    state = state.copyWith(appliedInternships: applied);
  }

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
