// Auth Types
export interface AdminUser {
  id: string;
  email: string;
  name: string;
  role: 'super_admin';
  avatar?: string;
}

export interface AuthState {
  user: AdminUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

// Dashboard Types
export interface DashboardStats {
  totalActiveListings: number;
  totalRegisteredStudents: number;
  totalApplicationsThisMonth: number;
  mlModelAccuracy: number;
}

export interface DomainCount {
  domain: string;
  count: number;
}

export interface ApplicationTrend {
  date: string;
  count: number;
}

export interface ModeDistribution {
  mode: string;
  count: number;
}

export interface CompanyListing {
  company: string;
  count: number;
}

export interface RecentActivity {
  id: string;
  type: 'listing_added' | 'student_registered' | 'model_retrained';
  title: string;
  timestamp: string;
  metadata?: Record<string, any>;
}

// Internship Listing Types
export type InternshipMode = 'Remote' | 'Hybrid' | 'On-site';
export type InternshipStatus = 'Active' | 'Inactive' | 'Archived';
export type InternshipType = 'Full-time' | 'Part-time';

export interface InternshipListing {
  id: string;
  title: string;
  company: string;
  domain: string;
  type: InternshipType;
  mode: InternshipMode;
  country: string;
  city: string;
  stipend: number;
  currency: string;
  duration: number;
  ppoOffered: boolean;
  certificateProvided: boolean;
  minCGPA: number;
  minYear: number;
  eligibleBranches: string[];
  degreeRequired: string;
  requiredSkills: string[];
  bonusSkills: string[];
  postedOn: string;
  applyBy: string;
  totalOpenings: number;
  status: InternshipStatus;
  createdAt: string;
  updatedAt: string;
}

export interface ListingFilters {
  domain?: string;
  mode?: InternshipMode;
  country?: string;
  minCGPA?: number;
  duration?: number;
  ppoOffered?: boolean;
  status?: InternshipStatus;
}

// Application Types
export type ApplicationStatus = 'Applied' | 'Reviewed' | 'Shortlisted' | 'Rejected';

export interface Application {
  id: string;
  studentId: string;
  studentName: string;
  studentCollege: string;
  domain: string;
  company: string;
  internshipTitle: string;
  appliedOn: string;
  status: ApplicationStatus;
  matchScore: number;
}

export interface ApplicationDetail extends Application {
  student: Student;
  internship: InternshipListing;
}

// Student Types
export type StudentStatus = 'Active' | 'Banned';

export interface Student {
  id: string;
  studentId: string;
  name: string;
  email: string;
  college: string;
  branch: string;
  year: number;
  cgpa: number;
  domain: string;
  skills: string[];
  skillsCount: number;
  projects: Project[];
  certifications: Certification[];
  githubRepos: string[];
  priorInternships: PriorInternship[];
  status: StudentStatus;
  joinedOn: string;
  avatar?: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  technologies: string[];
  link?: string;
}

export interface Certification {
  id: string;
  name: string;
  issuer: string;
  date: string;
  link?: string;
}

export interface PriorInternship {
  id: string;
  company: string;
  role: string;
  duration: string;
  description?: string;
}

// ML Model Types
export interface ModelMetrics {
  version: string;
  lastTrained: string;
  accuracy: number;
  precision: number;
  recall: number;
  f1Score: number;
  datasetSize: number;
}

export interface FeatureImportance {
  feature: string;
  importance: number;
}

export interface DatasetInfo {
  id: string;
  filename: string;
  uploadedAt: string;
  rowCount: number;
  columnCount: number;
  classBalance: {
    recommended: number;
    notRecommended: number;
  };
}

export interface RetrainStatus {
  isTraining: boolean;
  progress: number;
  message: string;
}

// Analytics Types
export interface DomainTrend {
  date: string;
  [domain: string]: number | string;
}

export interface LocationHeatmap {
  city: string;
  count: number;
}

export interface StipendDistribution {
  domain: string;
  min: number;
  q1: number;
  median: number;
  q3: number;
  max: number;
}

export interface ApplicationFunnel {
  stage: string;
  count: number;
}

export interface TopInternship {
  id: string;
  title: string;
  company: string;
  applicationCount: number;
}

export interface DomainMatchScore {
  domain: string;
  averageScore: number;
}

export interface CollegeApplication {
  college: string;
  count: number;
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}

// UI Types
export interface NavItem {
  label: string;
  href: string;
  icon: string;
}

export interface ChartData {
  name: string;
  value: number;
  [key: string]: any;
}
