class UserProfile {
  final String id;
  final String name;
  final String email;
  final List<String> skills;
  final double cgpa;
  final List<String> interests;
  final String preferredLocation;
  final String preferredType; // Remote / Hybrid / On-site / Any
  final String? avatarUrl;
  final String? college;
  final int? graduationYear;
  final String? resumeUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.skills = const [],
    this.cgpa = 7.0,
    this.interests = const [],
    this.preferredLocation = '',
    this.preferredType = 'Any',
    this.avatarUrl,
    this.college,
    this.graduationYear,
    this.resumeUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? skills,
    double? cgpa,
    List<String>? interests,
    String? preferredLocation,
    String? preferredType,
    String? avatarUrl,
    String? college,
    int? graduationYear,
    String? resumeUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      cgpa: cgpa ?? this.cgpa,
      interests: interests ?? this.interests,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredType: preferredType ?? this.preferredType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      college: college ?? this.college,
      graduationYear: graduationYear ?? this.graduationYear,
      resumeUrl: resumeUrl ?? this.resumeUrl,
    );
  }

  factory UserProfile.empty() => const UserProfile(
        id: '',
        name: '',
        email: '',
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 7.0,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferredLocation: json['preferred_location'] as String? ?? '',
      preferredType: json['preferred_type'] as String? ?? 'Any',
      avatarUrl: json['avatar_url'] as String?,
      college: json['college'] as String?,
      graduationYear: json['graduation_year'] as int?,
      resumeUrl: json['resume_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'skills': skills,
        'cgpa': cgpa,
        'interests': interests,
        'preferred_location': preferredLocation,
        'preferred_type': preferredType,
        'avatar_url': avatarUrl,
        'college': college,
        'graduation_year': graduationYear,
        'resume_url': resumeUrl,
      };
}
