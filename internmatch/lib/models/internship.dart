class Internship {
  final String id;
  final String title;
  final String company;
  final String companyInitial;
  final String logoColor;
  final String location;
  final String locationType; // "Remote" | "On-site"
  final String domain;
  final List<String> requiredSkills;
  final List<String> tools;
  final String duration; // "1 month" | "3 months" | "6 months"
  final String type; // "Full-time" | "Part-time"
  final String stipend;
  final String description;
  final List<String> responsibilities;
  final int postedDaysAgo;
  final int applicants;
  final int openings;
  final int matchScore; // Calculated match percentage

  const Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.companyInitial,
    required this.logoColor,
    required this.location,
    required this.domain,
    required this.requiredSkills,
    this.tools = const [],
    required this.duration,
    required this.type,
    required this.stipend,
    required this.description,
    this.responsibilities = const [],
    required this.postedDaysAgo,
    required this.applicants,
    required this.openings,
    this.matchScore = 0,
  });

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
    String? type,
    String? stipend,
    String? description,
    List<String>? responsibilities,
    int? postedDaysAgo,
    int? applicants,
    int? openings,
    int? matchScore,
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
      type: type ?? this.type,
      stipend: stipend ?? this.stipend,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      postedDaysAgo: postedDaysAgo ?? this.postedDaysAgo,
      applicants: applicants ?? this.applicants,
      openings: openings ?? this.openings,
      matchScore: matchScore ?? this.matchScore,
    );
  }
}

            'Build recommendation systems for Amazon\'s product suite.',
        deadline: DateTime.now().add(Duration(days = 8)),
        postedAt: DateTime.now().subtract(Duration(days = 1)),
      ),
      Internship(
        id = '3',
        title = 'Full Stack Intern',
        company = 'Razorpay',
        companyLogo = 'https://logo.clearbit.com/razorpay.com',
        location = 'Bangalore, India',
        type = 'On-site',
        skills = ['React', 'Node.js', 'PostgreSQL'],
        matchScore = 81,
        duration = '3 months',
        stipend = '₹45,000/mo',
        domain = 'Web',
        description = 'Work on fintech products serving 8M+ businesses.',
        deadline = DateTime.now().add(const Duration(days: 20)),
        postedAt = DateTime.now().subtract(const Duration(days: 4)),
      ),
      Internship(
        id = '4',
        title = 'Data Science Intern',
        company = 'Flipkart',
        companyLogo = 'https://logo.clearbit.com/flipkart.com',
        location = 'Bangalore, India',
        type = 'Hybrid',
        skills = ['Python', 'SQL', 'Pandas', 'ML'],
        matchScore = 76,
        duration = '4 months',
        stipend = '₹40,000/mo',
        domain = 'AI/ML',
        description =
            'Analyze large-scale e-commerce data to improve recommendations.',
        deadline = DateTime.now().add(const Duration(days: 12)),
        postedAt = DateTime.now().subtract(const Duration(days: 3)),
      ),
      Internship(
        id = '5',
        title = 'iOS/Android Intern',
        company = 'CRED',
        companyLogo = 'https://logo.clearbit.com/cred.club',
        location = 'Bangalore, India',
        type = 'On-site',
        skills = ['Flutter', 'Swift', 'Kotlin'],
        matchScore = 70,
        duration = '3 months',
        stipend = '₹55,000/mo',
        domain = 'App Dev',
        description = 'Build next-gen fintech mobile features at scale.',
        deadline = DateTime.now().add(const Duration(days: 25)),
        postedAt = DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
