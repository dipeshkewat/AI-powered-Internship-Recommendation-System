// ============================================================
// Internship Model — aligned with FastAPI backend schema
// ============================================================

class Internship {
  final String id;
  final String title;
  final String company;
  final String companyLogo;
  final String companyInitial;
  final String logoColor;
  final String location;
  final String locationType; // "Remote" | "On-site" | "Hybrid"
  final String domain;
  final List<String> requiredSkills;
  final List<String> tools;
  final String duration; // "1 month" | "3 months" | "6 months"
  // Backend uses "type" as work type (Remote/Hybrid/On-site). Keep "jobType"
  // for UI compatibility, but don't duplicate values.
  final String jobType; // "Internship" (default) or other
  final String stipend;
  final String description;
  final String applyUrl;
  final List<String> responsibilities;
  final int postedDaysAgo;
  final int applicants;
  final int openings;
  final int matchScore; // Calculated match percentage
  final bool isBookmarked;
  final bool hasApplied;

  const Internship({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo = '',
    required this.companyInitial,
    required this.logoColor,
    required this.location,
    this.locationType = 'Remote',
    required this.domain,
    required this.requiredSkills,
    this.tools = const [],
    required this.duration,
    this.jobType = 'Internship',
    required this.stipend,
    required this.description,
    this.applyUrl = '',
    this.responsibilities = const [],
    required this.postedDaysAgo,
    required this.applicants,
    required this.openings,
    this.matchScore = 0,
    this.isBookmarked = false,
    this.hasApplied = false,
  });

  /// Parse from FastAPI backend JSON response
  factory Internship.fromJson(Map<String, dynamic> json) {
    // company_logo → derive companyInitial and logoColor
    final company = (json['company'] as String? ?? '');
    final companyInitial = company.isNotEmpty ? company[0].toUpperCase() : '?';
    final companyLogo = json['company_logo']?.toString() ?? '';

    // Map backend "type" (Remote/On-site/Hybrid) to locationType
    final type = json['type']?.toString() ?? 'Remote';

    // skills array from backend
    final rawSkills = json['skills'] as List<dynamic>? ?? [];
    final skills = rawSkills.map((s) => s.toString()).toList();

    // Calculate postedDaysAgo from posted_at
    int daysAgo = 0;
    if (json['posted_at'] != null) {
      try {
        final postedAt = DateTime.parse(json['posted_at'] as String);
        daysAgo = DateTime.now().difference(postedAt).inDays;
      } catch (_) {}
    }

    // Pick a deterministic logo color from id hash
    final colors = [
      '#4285F4', '#00A4EF', '#F7931E', '#FF9900',
      '#F80000', '#00C853', '#8E24AA', '#E91E63',
    ];
    final idValue = json['id']?.toString() ?? '';
    final colorIndex = (idValue.isNotEmpty ? idValue : '0').hashCode.abs() % colors.length;

    return Internship(
      id: idValue,
      title: json['title']?.toString() ?? '',
      company: company,
      companyLogo: companyLogo,
      companyInitial: companyInitial,
      logoColor: colors[colorIndex],
      location: json['location']?.toString() ?? '',
      locationType: type,
      domain: json['domain']?.toString() ?? '',
      requiredSkills: skills,
      tools: const [],
      duration: json['duration']?.toString() ?? '',
      jobType: 'Internship',
      stipend: json['stipend']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      applyUrl: json['apply_url']?.toString() ?? '',
      responsibilities: const [],
      postedDaysAgo: daysAgo,
      applicants: 0,
      openings: 1,
      matchScore: (json['match_score'] as num?)?.toInt() ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      hasApplied: json['has_applied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'type': locationType,
        'skills': requiredSkills,
        'duration': duration,
        'stipend': stipend,
        'domain': domain,
        'description': description,
        'apply_url': applyUrl,
        'match_score': matchScore,
        'is_bookmarked': isBookmarked,
        'has_applied': hasApplied,
      };

  Internship copyWith({
    String? id,
    String? title,
    String? company,
    String? companyInitial,
    String? logoColor,
    String? location,
    String? locationType,
    String? domain,
    List<String>? requiredSkills,
    List<String>? tools,
    String? duration,
    String? jobType,
    String? stipend,
    String? description,
    String? applyUrl,
    List<String>? responsibilities,
    int? postedDaysAgo,
    int? applicants,
    int? openings,
    int? matchScore,
    bool? isBookmarked,
    bool? hasApplied,
  }) {
    return Internship(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyInitial: companyInitial ?? this.companyInitial,
      logoColor: logoColor ?? this.logoColor,
      location: location ?? this.location,
      locationType: locationType ?? this.locationType,
      domain: domain ?? this.domain,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      tools: tools ?? this.tools,
      duration: duration ?? this.duration,
      jobType: jobType ?? this.jobType,
      stipend: stipend ?? this.stipend,
      description: description ?? this.description,
      applyUrl: applyUrl ?? this.applyUrl,
      responsibilities: responsibilities ?? this.responsibilities,
      postedDaysAgo: postedDaysAgo ?? this.postedDaysAgo,
      applicants: applicants ?? this.applicants,
      openings: openings ?? this.openings,
      matchScore: matchScore ?? this.matchScore,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasApplied: hasApplied ?? this.hasApplied,
    );
  }
}
