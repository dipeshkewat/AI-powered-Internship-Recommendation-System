import 'package:internmatch/models/internship.dart';

final List<Internship> internshipData = [
  const Internship(
    id: "1",
    title: "Frontend Developer Intern",
    company: "Google",
    companyInitial: "G",
    logoColor: "#4285F4",
    location: "Bangalore",
    locationType: "Remote",
    domain: "Web Dev",
    requiredSkills: ["React", "JavaScript", "CSS"],
    tools: ["Git/Github", "Docker"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹30,000/month",
    description: "Join Google's engineering team and build cutting-edge web applications used by billions.",
    responsibilities: [
      "Build and maintain React components",
      "Collaborate with UX designers",
      "Optimize performance of web apps",
      "Write clean, testable code",
    ],
    postedDaysAgo: 2,
    applicants: 1240,
    openings: 5,
    matchScore: 92,
  ),
  const Internship(
    id: "2",
    title: "Machine Learning Intern",
    company: "Microsoft",
    companyInitial: "M",
    logoColor: "#00A4EF",
    location: "Hyderabad",
    locationType: "On-site",
    domain: "AI/ML",
    requiredSkills: ["Python", "Machine Learning", "SQL"],
    tools: ["Docker", "AWS", "Git/Github"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹40,000/month",
    description: "Work alongside top ML researchers at Microsoft to build intelligent systems at scale.",
    responsibilities: [
      "Develop ML models for production",
      "Run experiments and evaluate results",
      "Work with large-scale datasets",
      "Present findings to stakeholders",
    ],
    postedDaysAgo: 1,
    applicants: 987,
    openings: 3,
    matchScore: 88,
  ),
  const Internship(
    id: "3",
    title: "Android App Developer Intern",
    company: "Flipkart",
    companyInitial: "F",
    logoColor: "#F7931E",
    location: "Bangalore",
    locationType: "On-site",
    domain: "App Dev",
    requiredSkills: ["Kotlin", "Java", "Android SDK"],
    tools: ["Git", "Firebase"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹25,000/month",
    description: "Build mobile experiences for millions of users on the Flipkart platform.",
    responsibilities: [
      "Develop Android features using Kotlin",
      "Implement UI according to design specs",
      "Collaborate with backend teams",
      "Test and debug applications",
    ],
    postedDaysAgo: 5,
    applicants: 756,
    openings: 4,
    matchScore: 85,
  ),
  const Internship(
    id: "4",
    title: "Data Science Intern",
    company: "Amazon",
    companyInitial: "A",
    logoColor: "#FF9900",
    location: "Bangalore",
    locationType: "Remote",
    domain: "Data Science",
    requiredSkills: ["Python", "SQL", "Data Analysis"],
    tools: ["AWS", "Spark", "Git"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹35,000/month",
    description: "Analyze and process massive datasets to drive business insights.",
    responsibilities: [
      "Perform exploratory data analysis",
      "Build data visualizations",
      "Prepare datasets for ML models",
      "Document findings",
    ],
    postedDaysAgo: 3,
    applicants: 1100,
    openings: 6,
    matchScore: 80,
  ),
  const Internship(
    id: "5",
    title: "Cybersecurity Intern",
    company: "Oracle",
    companyInitial: "O",
    logoColor: "#F80000",
    location: "Hyderabad",
    locationType: "On-site",
    domain: "Cybersecurity",
    requiredSkills: ["Network Security", "Linux", "Python"],
    tools: ["Wireshark", "Burp Suite", "Git"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹28,000/month",
    description: "Help secure Oracle's infrastructure and protect against threats.",
    responsibilities: [
      "Analyze security logs",
      "Test for vulnerabilities",
      "Document security issues",
      "Assist in implementing fixes",
    ],
    postedDaysAgo: 4,
    applicants: 423,
    openings: 2,
    matchScore: 75,
  ),
  const Internship(
    id: "6",
    title: "DevOps Intern",
    company: "Adobe",
    companyInitial: "D",
    logoColor: "#FF0000",
    location: "Bangalore",
    locationType: "Hybrid",
    domain: "Web Dev",
    requiredSkills: ["Docker", "Kubernetes", "Linux"],
    tools: ["AWS", "Jenkins", "Git"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹32,000/month",
    description: "Manage cloud infrastructure and deploy applications at scale.",
    responsibilities: [
      "Set up CI/CD pipelines",
      "Manage cloud resources",
      "Monitor application performance",
      "Handle deployments",
    ],
    postedDaysAgo: 6,
    applicants: 654,
    openings: 3,
    matchScore: 78,
  ),
];

int calculateMatchScore(List<String> userSkills, List<String> requiredSkills, List<String> userInterests, String userLocation, String userType, String userDuration) {
  int score = 0;
  
  // Skills match (40 points max)
  int skillMatches = userSkills.where((skill) => requiredSkills.any((req) => req.toLowerCase().contains(skill.toLowerCase()))).length;
  score += userSkills.isNotEmpty ? (skillMatches * 40 ~/ userSkills.length) : 0;
  
  // Location match (20 points)
  if (userLocation == "Remote") {
    score += 20;
  }
  
  // Type match (20 points)
  if (userType == "Full-time" || userType == "") {
    score += 20;
  }
  
  // Duration match (20 points)
  if (userDuration == "3 months" || userDuration == "6 months" || userDuration == "") {
    score += 20;
  }
  
  return (score / 100 * 100).toInt().clamp(0, 100);
}

List<Internship> getRecommendations({
  List<String> skills = const [],
  List<String> tools = const [],
  List<String> interests = const [],
  String preferredLocation = "",
  String internshipType = "",
  String duration = "",
}) {
  List<Internship> recommendations = internshipData.map((internship) {
    return internship.copyWith(
      matchScore: calculateMatchScore(
        skills,
        internship.requiredSkills,
        interests,
        preferredLocation,
        internshipType,
        duration,
      ),
    );
  }).toList();

  recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
  return recommendations;
}
