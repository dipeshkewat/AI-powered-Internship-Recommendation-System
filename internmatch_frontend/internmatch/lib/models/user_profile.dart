// ============================================================
// UserProfile Model — aligned with FastAPI backend schema
// ============================================================

class UserProfile {
  // Backend fields
  final String id;
  final String name;
  final String email;
  final String college;
  final int? graduationYear;
  final String? avatarUrl;

  // Auth state (local)
  final String password;
  final bool isAuthenticated;
  final bool onboardingComplete;

  // Onboarding
  final String educationLevel; // "Graduate" | "Undergraduate" | ""
  final String experienceLevel; // "Fresher" | "Intermediate" | ""
  final bool? hasDoneInternship;
  final String internshipDescription;

  // Basic Info (onboarding)
  final String fullName;
  final String phoneNo;
  final String avatarColor;

  // Academic
  final String degree;
  final String branch;
  final String currentYear;
  final String cgpa; // stored as string internally, converted to double for API

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
  final List<String> savedInternships;
  final List<AppliedInternship> appliedInternships;
  final List<UserNotification> notifications;

  const UserProfile({
    this.id = '',
    this.name = '',
    this.email = '',
    this.college = '',
    this.graduationYear,
    this.avatarUrl,
    this.password = '',
    this.isAuthenticated = false,
    this.onboardingComplete = false,
    this.educationLevel = '',
    this.experienceLevel = '',
    this.hasDoneInternship,
    this.internshipDescription = '',
    this.fullName = '',
    this.phoneNo = '',
    this.avatarColor = '#5B4FCF',
    this.degree = '',
    this.branch = '',
    this.currentYear = '',
    this.cgpa = '',
    this.skills = const [],
    this.tools = const [],
    this.interests = const [],
    this.preferredLocation = '',
    this.internshipType = '',
    this.duration = '',
    this.savedInternships = const [],
    this.appliedInternships = const [],
    this.notifications = const [],
  });

  /// Parse from FastAPI backend JSON response (profile endpoint).
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'] as List<dynamic>? ?? [];
    final rawInterests = json['interests'] as List<dynamic>? ?? [];

    return UserProfile(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      college: json['college'] as String? ?? '',
      graduationYear: json['graduation_year'] as int?,
      avatarUrl: json['avatar_url'] as String?,
      isAuthenticated: true,
      onboardingComplete: (json['skills'] as List<dynamic>?)?.isNotEmpty == true,
      fullName: json['name'] as String? ?? '',
      skills: rawSkills.map((s) => s.toString()).toList(),
      interests: rawInterests.map((s) => s.toString()).toList(),
      cgpa: ((json['cgpa'] as num?)?.toString()) ?? '',
      preferredLocation: json['preferred_location'] as String? ?? '',
      internshipType: json['preferred_type'] as String? ?? '',
    );
  }

  /// Convert to JSON payload for the profile update endpoint.
  Map<String, dynamic> toJson() => {
        'name': name.isNotEmpty ? name : fullName,
        'college': college,
        'graduation_year': graduationYear,
        'skills': skills,
        'interests': interests,
        'cgpa': double.tryParse(cgpa) ?? 0.0,
        'preferred_location': preferredLocation,
        'preferred_type': internshipType,
      };

  factory UserProfile.empty() => const UserProfile();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? college,
    int? graduationYear,
    String? avatarUrl,
    String? password,
    bool? isAuthenticated,
    bool? onboardingComplete,
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
    List<String>? savedInternships,
    List<AppliedInternship>? appliedInternships,
    List<UserNotification>? notifications,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      graduationYear: graduationYear ?? this.graduationYear,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      password: password ?? this.password,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
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
      savedInternships: savedInternships ?? this.savedInternships,
      appliedInternships: appliedInternships ?? this.appliedInternships,
      notifications: notifications ?? this.notifications,
    );
  }
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
