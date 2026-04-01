class Internship {
  final String id;
  final String title;
  final String company;
  final String companyLogo;
  final String location;
  final String type; // Remote / Hybrid / On-site
  final List<String> skills;
  final int matchScore;
  final String duration;
  final String stipend;
  final String domain;
  final bool isBookmarked;
  final bool hasApplied;
  final String? description;
  final String? applyUrl;
  final DateTime? deadline;
  final DateTime? postedAt;

  const Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogo,
    required this.location,
    required this.type,
    required this.skills,
    required this.matchScore,
    required this.duration,
    required this.stipend,
    required this.domain,
    this.isBookmarked = false,
    this.hasApplied = false,
    this.description,
    this.applyUrl,
    this.deadline,
    this.postedAt,
  });

  Internship copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogo,
    String? location,
    String? type,
    List<String>? skills,
    int? matchScore,
    String? duration,
    String? stipend,
    String? domain,
    bool? isBookmarked,
    bool? hasApplied,
    String? description,
    String? applyUrl,
    DateTime? deadline,
    DateTime? postedAt,
  }) {
    return Internship(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      type: type ?? this.type,
      skills: skills ?? this.skills,
      matchScore: matchScore ?? this.matchScore,
      duration: duration ?? this.duration,
      stipend: stipend ?? this.stipend,
      domain: domain ?? this.domain,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasApplied: hasApplied ?? this.hasApplied,
      description: description ?? this.description,
      applyUrl: applyUrl ?? this.applyUrl,
      deadline: deadline ?? this.deadline,
      postedAt: postedAt ?? this.postedAt,
    );
  }

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      companyLogo: json['company_logo'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? 'Remote',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      matchScore: json['match_score'] as int? ?? 0,
      duration: json['duration'] as String? ?? '',
      stipend: json['stipend'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      hasApplied: json['has_applied'] as bool? ?? false,
      description: json['description'] as String?,
      applyUrl: json['apply_url'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      postedAt: json['posted_at'] != null
          ? DateTime.tryParse(json['posted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'company_logo': companyLogo,
        'location': location,
        'type': type,
        'skills': skills,
        'match_score': matchScore,
        'duration': duration,
        'stipend': stipend,
        'domain': domain,
        'is_bookmarked': isBookmarked,
        'has_applied': hasApplied,
        'description': description,
        'apply_url': applyUrl,
        'deadline': deadline?.toIso8601String(),
        'posted_at': postedAt?.toIso8601String(),
      };
}

// Dummy data for development / offline mode
class InternshipDummy {
  static List<Internship> getSamples() {
    return [
      Internship(
        id: '1',
        title: 'Flutter Developer Intern',
        company: 'Google',
        companyLogo: 'https://logo.clearbit.com/google.com',
        location: 'Bangalore, India',
        type: 'Hybrid',
        skills: ['Flutter', 'Dart', 'Firebase'],
        matchScore: 92,
        duration: '3 months',
        stipend: '₹50,000/mo',
        domain: 'App Dev',
        description: 'Work on Flutter-based tools used by millions.',
        deadline: DateTime.now().add(const Duration(days: 15)),
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Internship(
        id: '2',
        title: 'ML Research Intern',
        company: 'Amazon',
        companyLogo: 'https://logo.clearbit.com/amazon.com',
        location: 'Remote',
        type: 'Remote',
        skills: ['Python', 'scikit-learn', 'PyTorch'],
        matchScore: 88,
        duration: '6 months',
        stipend: '₹60,000/mo',
        domain: 'AI/ML',
        description:
            'Build recommendation systems for Amazon\'s product suite.',
        deadline: DateTime.now().add(const Duration(days: 8)),
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Internship(
        id: '3',
        title: 'Full Stack Intern',
        company: 'Razorpay',
        companyLogo: 'https://logo.clearbit.com/razorpay.com',
        location: 'Bangalore, India',
        type: 'On-site',
        skills: ['React', 'Node.js', 'PostgreSQL'],
        matchScore: 81,
        duration: '3 months',
        stipend: '₹45,000/mo',
        domain: 'Web',
        description: 'Work on fintech products serving 8M+ businesses.',
        deadline: DateTime.now().add(const Duration(days: 20)),
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Internship(
        id: '4',
        title: 'Data Science Intern',
        company: 'Flipkart',
        companyLogo: 'https://logo.clearbit.com/flipkart.com',
        location: 'Bangalore, India',
        type: 'Hybrid',
        skills: ['Python', 'SQL', 'Pandas', 'ML'],
        matchScore: 76,
        duration: '4 months',
        stipend: '₹40,000/mo',
        domain: 'AI/ML',
        description:
            'Analyze large-scale e-commerce data to improve recommendations.',
        deadline: DateTime.now().add(const Duration(days: 12)),
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Internship(
        id: '5',
        title: 'iOS/Android Intern',
        company: 'CRED',
        companyLogo: 'https://logo.clearbit.com/cred.club',
        location: 'Bangalore, India',
        type: 'On-site',
        skills: ['Flutter', 'Swift', 'Kotlin'],
        matchScore: 70,
        duration: '3 months',
        stipend: '₹55,000/mo',
        domain: 'App Dev',
        description: 'Build next-gen fintech mobile features at scale.',
        deadline: DateTime.now().add(const Duration(days: 25)),
        postedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
