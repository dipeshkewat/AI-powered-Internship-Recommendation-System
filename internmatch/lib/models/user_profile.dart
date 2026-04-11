class UserProfile {
  // Auth
  final String email;
  final String password;

  // Onboarding
  final String educationLevel; // "Graduate" | "Undergraduate" | ""
  final String experienceLevel; // "Fresher" | "Intermediate" | ""
  final bool? hasDoneInternship;
  final String internshipDescription;

  // Basic Info
  final String fullName;
  final String phoneNo;
  final String avatarColor;

  // Academic
  final String degree;
  final String branch;
  final String currentYear;
  final String cgpa;

  // Skills
  final List<String> skills;
  final List<String> tools;

  // Interests
  final List<String> interests;

  // Preferences
  final String preferredLocation; // "Remote" | "On-site" | ""
  final String internshipType; // "Full-time" | "Part-time" | ""
  final String duration; // "1 month" | "3 months" | "6 months" | ""

  // App state
  final bool isAuthenticated;
  final bool onboardingComplete;
  final List<String> savedInternships;
  final List<AppliedInternship> appliedInternships;
  final List<UserNotification> notifications;

  const UserProfile({
    this.email = "",
    this.password = "",
    this.educationLevel = "",
    this.experienceLevel = "",
    this.hasDoneInternship,
    this.internshipDescription = "",
    this.fullName = "",
    this.phoneNo = "",
    this.avatarColor = "#5B4FCF",
    this.degree = "",
    this.branch = "",
    this.currentYear = "",
    this.cgpa = "",
    this.skills = const [],
    this.tools = const [],
    this.interests = const [],
    this.preferredLocation = "",
    this.internshipType = "",
    this.duration = "",
    this.isAuthenticated = false,
    this.onboardingComplete = false,
    this.savedInternships = const [],
    this.appliedInternships = const [],
    this.notifications = const [],
  });

  UserProfile copyWith({
    String? email,
    String? password,
    String? educationLevel,
    String? experienceLevel,
    bool? hasDoneInternship,
    String? internshipDescription,
    String? fullName,
    String? phoneNo,
    String? avatarColor,
    String? degree,
    String? branch,
    String? currentYear,
    String? cgpa,
    List<String>? skills,
    List<String>? tools,
    List<String>? interests,
    String? preferredLocation,
    String? internshipType,
    String? duration,
    bool? isAuthenticated,
    bool? onboardingComplete,
    List<String>? savedInternships,
    List<AppliedInternship>? appliedInternships,
    List<UserNotification>? notifications,
  }) {
    return UserProfile(
      email: email ?? this.email,
      password: password ?? this.password,
      educationLevel: educationLevel ?? this.educationLevel,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      hasDoneInternship: hasDoneInternship ?? this.hasDoneInternship,
      internshipDescription: internshipDescription ?? this.internshipDescription,
      fullName: fullName ?? this.fullName,
      phoneNo: phoneNo ?? this.phoneNo,
      avatarColor: avatarColor ?? this.avatarColor,
      degree: degree ?? this.degree,
      branch: branch ?? this.branch,
      currentYear: currentYear ?? this.currentYear,
      cgpa: cgpa ?? this.cgpa,
      skills: skills ?? this.skills,
      tools: tools ?? this.tools,
      interests: interests ?? this.interests,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      internshipType: internshipType ?? this.internshipType,
      duration: duration ?? this.duration,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      savedInternships: savedInternships ?? this.savedInternships,
      appliedInternships: appliedInternships ?? this.appliedInternships,
      notifications: notifications ?? this.notifications,
    );
  }

  factory UserProfile.empty() => const UserProfile();
}

class AppliedInternship {
  final String id;
  final String title;
  final String company;
  final String appliedDate;
  final String status; // "Applied" | "Under Review" | "Shortlisted" | "Rejected" | "Selected"

  const AppliedInternship({
    required this.id,
    required this.title,
    required this.company,
    required this.appliedDate,
    required this.status,
  });
}

class UserNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool read;
  final String type; // "match" | "application" | "reminder" | "news"

  const UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    required this.type,
  });
}

