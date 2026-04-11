export interface Internship {
  id: string;
  title: string;
  company: string;
  companyInitial: string;
  logoColor: string;
  location: string;
  locationType: "Remote" | "On-site";
  domain: string;
  requiredSkills: string[];
  tools: string[];
  duration: "1 month" | "3 months" | "6 months";
  type: "Full-time" | "Part-time";
  stipend: string;
  description: string;
  responsibilities: string[];
  postedDaysAgo: number;
  applicants: number;
  openings: number;
}

export const internships: Internship[] = [
  {
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
  },
  {
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
  },
  {
    id: "3",
    title: "Android App Developer Intern",
    company: "Flipkart",
    companyInitial: "F",
    logoColor: "#F7931E",
    location: "Bangalore",
    locationType: "On-site",
    domain: "App Dev",
    requiredSkills: ["Java", "Flutter", "SQL"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹25,000/month",
    description: "Build the next-gen shopping experience for Flipkart's 400 million customers.",
    responsibilities: [
      "Develop Android features",
      "Integrate REST APIs",
      "Debug and fix performance issues",
      "Code review participation",
    ],
    postedDaysAgo: 5,
    applicants: 643,
    openings: 8,
  },
  {
    id: "4",
    title: "Data Science Intern",
    company: "Amazon",
    companyInitial: "A",
    logoColor: "#FF9900",
    location: "Remote",
    locationType: "Remote",
    domain: "Data Science",
    requiredSkills: ["Python", "SQL", "Machine Learning"],
    tools: ["AWS", "Docker"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹50,000/month",
    description: "Analyze massive datasets and build predictive models to improve Amazon's customer experience.",
    responsibilities: [
      "Exploratory data analysis",
      "Build dashboards and reports",
      "Create predictive models",
      "Collaborate with product teams",
    ],
    postedDaysAgo: 3,
    applicants: 1560,
    openings: 4,
  },
  {
    id: "5",
    title: "React Developer Intern",
    company: "Razorpay",
    companyInitial: "R",
    logoColor: "#2D9EE0",
    location: "Bangalore",
    locationType: "Remote",
    domain: "Web Dev",
    requiredSkills: ["React", "JavaScript", "Node.js/Express"],
    tools: ["Git/Github", "Docker"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹28,000/month",
    description: "Build payment infrastructure and dashboards for India's leading fintech company.",
    responsibilities: [
      "Develop fintech dashboard features",
      "API integration",
      "Write unit and integration tests",
      "Review PRs",
    ],
    postedDaysAgo: 4,
    applicants: 830,
    openings: 6,
  },
  {
    id: "6",
    title: "Flutter Developer Intern",
    company: "PhonePe",
    companyInitial: "P",
    logoColor: "#5F259F",
    location: "Pune",
    locationType: "On-site",
    domain: "App Dev",
    requiredSkills: ["Flutter", "Java", "JavaScript"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹22,000/month",
    description: "Help build PhonePe's cross-platform apps serving 450M+ users.",
    responsibilities: [
      "Develop Flutter widgets",
      "State management with BLoC",
      "API integration",
      "Performance optimization",
    ],
    postedDaysAgo: 7,
    applicants: 540,
    openings: 10,
  },
  {
    id: "7",
    title: "Cybersecurity Analyst Intern",
    company: "Wipro",
    companyInitial: "W",
    logoColor: "#341C71",
    location: "Chennai",
    locationType: "On-site",
    domain: "Cybersecurity",
    requiredSkills: ["Python", "C/C++", "SQL"],
    tools: ["Linux", "Git/Github"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹18,000/month",
    description: "Work with Wipro's security team to identify and mitigate cyber threats.",
    responsibilities: [
      "Vulnerability assessment",
      "Security log analysis",
      "Penetration testing",
      "Write security reports",
    ],
    postedDaysAgo: 6,
    applicants: 320,
    openings: 4,
  },
  {
    id: "8",
    title: "AI Research Intern",
    company: "Meta",
    companyInitial: "M",
    logoColor: "#0668E1",
    location: "Remote",
    locationType: "Remote",
    domain: "AI/ML",
    requiredSkills: ["Python", "Machine Learning", "C/C++"],
    tools: ["Docker", "Linux", "AWS"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹60,000/month",
    description: "Work on cutting-edge AI research at Meta's AI lab.",
    responsibilities: [
      "Train and fine-tune LLMs",
      "Run experiments at scale",
      "Publish findings internally",
      "Collaborate globally",
    ],
    postedDaysAgo: 1,
    applicants: 2100,
    openings: 2,
  },
  {
    id: "9",
    title: "Backend Developer Intern",
    company: "Swiggy",
    companyInitial: "S",
    logoColor: "#FC8019",
    location: "Bangalore",
    locationType: "On-site",
    domain: "Web Dev",
    requiredSkills: ["Node.js/Express", "SQL", "JavaScript"],
    tools: ["Docker", "AWS", "Git/Github"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹26,000/month",
    description: "Build the backbone of Swiggy's food delivery infrastructure.",
    responsibilities: [
      "Design and build REST APIs",
      "Database schema design",
      "Optimize query performance",
      "Microservices architecture",
    ],
    postedDaysAgo: 8,
    applicants: 712,
    openings: 7,
  },
  {
    id: "10",
    title: "Data Analyst Intern",
    company: "Zomato",
    companyInitial: "Z",
    logoColor: "#E23744",
    location: "Gurugram",
    locationType: "On-site",
    domain: "Data Science",
    requiredSkills: ["Python", "SQL", "Machine Learning"],
    tools: ["AWS", "Git/Github"],
    duration: "3 months",
    type: "Part-time",
    stipend: "₹15,000/month",
    description: "Turn data into insights that drive Zomato's business decisions.",
    responsibilities: [
      "SQL query writing",
      "Build dashboards in Tableau",
      "Statistical analysis",
      "Monthly reporting",
    ],
    postedDaysAgo: 10,
    applicants: 890,
    openings: 5,
  },
  {
    id: "11",
    title: "Full Stack Developer Intern",
    company: "Freshworks",
    companyInitial: "F",
    logoColor: "#26B67C",
    location: "Chennai",
    locationType: "Remote",
    domain: "Web Dev",
    requiredSkills: ["React", "Node.js/Express", "JavaScript", "SQL"],
    tools: ["Git/Github", "Docker"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹30,000/month",
    description: "Build SaaS products for Freshworks' global customer base.",
    responsibilities: [
      "Full-stack feature development",
      "Database design",
      "API integration",
      "Deploy to production",
    ],
    postedDaysAgo: 3,
    applicants: 445,
    openings: 6,
  },
  {
    id: "12",
    title: "iOS/Flutter Developer Intern",
    company: "CRED",
    companyInitial: "C",
    logoColor: "#1A1A2E",
    location: "Bangalore",
    locationType: "On-site",
    domain: "App Dev",
    requiredSkills: ["Flutter", "JavaScript", "SQL"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹28,000/month",
    description: "Build beautiful mobile experiences for CRED's credit card users.",
    responsibilities: [
      "Flutter UI development",
      "Payment integrations",
      "Animations and transitions",
      "A/B testing",
    ],
    postedDaysAgo: 5,
    applicants: 623,
    openings: 4,
  },
  {
    id: "13",
    title: "NLP / AI Intern",
    company: "Zoho",
    companyInitial: "Z",
    logoColor: "#E01E37",
    location: "Chennai",
    locationType: "On-site",
    domain: "AI/ML",
    requiredSkills: ["Python", "Machine Learning", "SQL"],
    tools: ["Linux", "Docker"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹20,000/month",
    description: "Develop NLP models that power Zoho's intelligent product suite.",
    responsibilities: [
      "Build NLP pipelines",
      "Train transformer models",
      "Model evaluation and tuning",
      "Deploy via REST API",
    ],
    postedDaysAgo: 9,
    applicants: 380,
    openings: 3,
  },
  {
    id: "14",
    title: "Cloud Security Intern",
    company: "Infosys",
    companyInitial: "I",
    logoColor: "#007CC3",
    location: "Mysuru",
    locationType: "On-site",
    domain: "Cybersecurity",
    requiredSkills: ["Python", "SQL", "C/C++"],
    tools: ["AWS", "Linux", "Docker"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹16,000/month",
    description: "Secure cloud infrastructure for Infosys clients across the globe.",
    responsibilities: [
      "Cloud security monitoring",
      "IAM policy management",
      "Incident response",
      "Security documentation",
    ],
    postedDaysAgo: 12,
    applicants: 260,
    openings: 8,
  },
  {
    id: "15",
    title: "React Native Developer Intern",
    company: "Meesho",
    companyInitial: "M",
    logoColor: "#FF2D78",
    location: "Bangalore",
    locationType: "Remote",
    domain: "App Dev",
    requiredSkills: ["React", "JavaScript", "Node.js/Express"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Part-time",
    stipend: "₹18,000/month",
    description: "Build the Meesho seller app used by 15M+ resellers across India.",
    responsibilities: [
      "React Native UI development",
      "Redux state management",
      "Push notifications",
      "Bug fixes and testing",
    ],
    postedDaysAgo: 6,
    applicants: 490,
    openings: 5,
  },
  {
    id: "16",
    title: "Data Engineering Intern",
    company: "Paytm",
    companyInitial: "P",
    logoColor: "#00B9F1",
    location: "Noida",
    locationType: "On-site",
    domain: "Data Science",
    requiredSkills: ["Python", "SQL", "Java"],
    tools: ["AWS", "Docker", "Linux"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹22,000/month",
    description: "Build real-time data pipelines for Paytm's fintech platform.",
    responsibilities: [
      "ETL pipeline development",
      "Kafka stream processing",
      "Data warehouse management",
      "Performance tuning",
    ],
    postedDaysAgo: 14,
    applicants: 340,
    openings: 4,
  },
  {
    id: "17",
    title: "DevOps Intern",
    company: "HCL",
    companyInitial: "H",
    logoColor: "#0E7FE1",
    location: "Noida",
    locationType: "On-site",
    domain: "Web Dev",
    requiredSkills: ["Python", "JavaScript", "C/C++"],
    tools: ["Docker", "AWS", "Linux", "Git/Github"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹15,000/month",
    description: "Automate CI/CD pipelines and manage cloud infrastructure at HCL.",
    responsibilities: [
      "CI/CD pipeline setup",
      "Kubernetes cluster management",
      "Infrastructure as Code",
      "Monitoring and alerting",
    ],
    postedDaysAgo: 11,
    applicants: 210,
    openings: 6,
  },
  {
    id: "18",
    title: "Blockchain Developer Intern",
    company: "Polygon",
    companyInitial: "P",
    logoColor: "#7B3FE4",
    location: "Remote",
    locationType: "Remote",
    domain: "Web Dev",
    requiredSkills: ["JavaScript", "Node.js/Express", "Python"],
    tools: ["Git/Github", "Docker"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹35,000/month",
    description: "Build decentralized applications on Polygon's Layer 2 blockchain.",
    responsibilities: [
      "Smart contract development",
      "dApp frontend with React",
      "Web3.js integration",
      "Security auditing",
    ],
    postedDaysAgo: 4,
    applicants: 560,
    openings: 3,
  },
  {
    id: "19",
    title: "Computer Vision Intern",
    company: "Ola",
    companyInitial: "O",
    logoColor: "#1BAA37",
    location: "Bangalore",
    locationType: "On-site",
    domain: "AI/ML",
    requiredSkills: ["Python", "Machine Learning", "C/C++"],
    tools: ["Docker", "Linux", "AWS"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹32,000/month",
    description: "Develop computer vision systems for Ola's electric vehicle platform.",
    responsibilities: [
      "Train object detection models",
      "Edge deployment optimization",
      "Dataset curation",
      "Model benchmarking",
    ],
    postedDaysAgo: 7,
    applicants: 480,
    openings: 3,
  },
  {
    id: "20",
    title: "Product Security Intern",
    company: "Byju's",
    companyInitial: "B",
    logoColor: "#5D2D91",
    location: "Bangalore",
    locationType: "Remote",
    domain: "Cybersecurity",
    requiredSkills: ["Python", "SQL", "C/C++"],
    tools: ["Linux", "Git/Github"],
    duration: "1 month",
    type: "Part-time",
    stipend: "₹12,000/month",
    description: "Protect Byju's edtech platform from security vulnerabilities.",
    responsibilities: [
      "Penetration testing",
      "OWASP vulnerability analysis",
      "Security code review",
      "Write remediation reports",
    ],
    postedDaysAgo: 15,
    applicants: 175,
    openings: 2,
  },
  {
    id: "21",
    title: "Java Backend Intern",
    company: "TCS",
    companyInitial: "T",
    logoColor: "#0033A1",
    location: "Mumbai",
    locationType: "On-site",
    domain: "Web Dev",
    requiredSkills: ["Java", "SQL", "JavaScript"],
    tools: ["Git/Github", "Docker", "Linux"],
    duration: "6 months",
    type: "Full-time",
    stipend: "₹14,000/month",
    description: "Develop enterprise-grade backend systems for TCS clients worldwide.",
    responsibilities: [
      "Spring Boot API development",
      "Database optimization",
      "Unit test coverage",
      "Client interaction",
    ],
    postedDaysAgo: 8,
    applicants: 920,
    openings: 15,
  },
  {
    id: "22",
    title: "Web3 Frontend Intern",
    company: "CoinDCX",
    companyInitial: "C",
    logoColor: "#3B71CA",
    location: "Remote",
    locationType: "Remote",
    domain: "Web Dev",
    requiredSkills: ["React", "JavaScript", "Node.js/Express"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Part-time",
    stipend: "₹20,000/month",
    description: "Build web3-powered trading interfaces for India's largest crypto exchange.",
    responsibilities: [
      "Build trading dashboards",
      "WebSocket integration",
      "Chart visualization",
      "Wallet integration",
    ],
    postedDaysAgo: 2,
    applicants: 430,
    openings: 4,
  },
  {
    id: "23",
    title: "Game Developer Intern",
    company: "MPL",
    companyInitial: "M",
    logoColor: "#FF4500",
    location: "Bangalore",
    locationType: "On-site",
    domain: "App Dev",
    requiredSkills: ["C/C++", "Java", "JavaScript"],
    tools: ["Git/Github"],
    duration: "3 months",
    type: "Full-time",
    stipend: "₹18,000/month",
    description: "Build engaging mobile games for MPL's 90M+ player base.",
    responsibilities: [
      "Game mechanics programming",
      "Unity/Unreal integration",
      "Performance optimization",
      "Multiplayer features",
    ],
    postedDaysAgo: 20,
    applicants: 310,
    openings: 5,
  },
  {
    id: "24",
    title: "Growth Data Analyst Intern",
    company: "Urban Company",
    companyInitial: "U",
    logoColor: "#00C4CC",
    location: "Remote",
    locationType: "Remote",
    domain: "Data Science",
    requiredSkills: ["Python", "SQL", "Machine Learning"],
    tools: ["AWS", "Git/Github"],
    duration: "1 month",
    type: "Part-time",
    stipend: "₹12,000/month",
    description: "Analyze user behavior to drive growth for Urban Company's service marketplace.",
    responsibilities: [
      "Funnel analysis",
      "Cohort analysis",
      "A/B test evaluation",
      "Growth metrics reporting",
    ],
    postedDaysAgo: 18,
    applicants: 225,
    openings: 3,
  },
];

export function calculateMatchScore(
  internship: Internship,
  profile: {
    skills: string[];
    tools: string[];
    interests: string[];
    preferredLocation: string;
    internshipType: string;
    duration: string;
  }
): number {
  let score = 0;

  // Skill match (35%)
  if (profile.skills.length > 0 && internship.requiredSkills.length > 0) {
    const normalizedProfileSkills = profile.skills.map((s) => s.toLowerCase());
    const skillMatches = internship.requiredSkills.filter((s) =>
      normalizedProfileSkills.includes(s.toLowerCase())
    ).length;
    score += (skillMatches / internship.requiredSkills.length) * 35;
  }

  // Tools match (10%)
  if (profile.tools.length > 0 && internship.tools.length > 0) {
    const normalizedProfileTools = profile.tools.map((t) => t.toLowerCase());
    const toolMatches = internship.tools.filter((t) =>
      normalizedProfileTools.includes(t.toLowerCase())
    ).length;
    score += (toolMatches / internship.tools.length) * 10;
  }

  // Interest/Domain match (30%)
  if (profile.interests.map((i) => i.toLowerCase()).includes(internship.domain.toLowerCase())) {
    score += 30;
  }

  // Location match (15%)
  if (profile.preferredLocation && internship.locationType === profile.preferredLocation) {
    score += 15;
  }

  // Type match (5%)
  if (profile.internshipType && internship.type === profile.internshipType) {
    score += 5;
  }

  // Duration match (5%)
  if (profile.duration && internship.duration === profile.duration) {
    score += 5;
  }

  return Math.min(Math.round(score), 100);
}

export function getRecommendations(
  profile: {
    skills: string[];
    tools: string[];
    interests: string[];
    preferredLocation: string;
    internshipType: string;
    duration: string;
  }
): (Internship & { matchScore: number })[] {
  return internships
    .map((internship) => ({
      ...internship,
      matchScore: calculateMatchScore(internship, profile),
    }))
    .sort((a, b) => b.matchScore - a.matchScore);
}
