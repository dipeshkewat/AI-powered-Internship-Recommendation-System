import type {
  DashboardStats,
  DomainCount,
  ApplicationTrend,
  ModeDistribution,
  CompanyListing,
  RecentActivity,
  InternshipListing,
  Application,
  Student,
  ModelMetrics,
  FeatureImportance,
  DatasetInfo,
  DomainTrend,
  LocationHeatmap,
  StipendDistribution,
  ApplicationFunnel,
  TopInternship,
  DomainMatchScore,
  CollegeApplication,
  PaginatedResponse,
  ListingFilters,
  ApplicationStatus,
} from '@/types';

import {
  mockDashboardStats,
  mockDomainCounts,
  mockApplicationTrends,
  mockModeDistribution,
  mockTopCompanies,
  mockRecentActivity,
  mockInternshipListings,
  mockApplications,
  mockStudents,
  mockModelMetrics,
  mockFeatureImportance,
  mockDatasets,
  mockDomainTrends,
  mockLocationHeatmap,
  mockStipendDistribution,
  mockApplicationFunnel,
  mockTopInternships,
  mockDomainMatchScores,
  mockCollegeApplications,
} from '@/data/mockData';

// Simulate API delay
const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

// Dashboard APIs
export const dashboardApi = {
  getStats: async (): Promise<DashboardStats> => {
    await delay(500);
    return mockDashboardStats;
  },

  getDomainCounts: async (): Promise<DomainCount[]> => {
    await delay(500);
    return mockDomainCounts;
  },

  getApplicationTrends: async (): Promise<ApplicationTrend[]> => {
    await delay(500);
    return mockApplicationTrends;
  },

  getModeDistribution: async (): Promise<ModeDistribution[]> => {
    await delay(500);
    return mockModeDistribution;
  },

  getTopCompanies: async (): Promise<CompanyListing[]> => {
    await delay(500);
    return mockTopCompanies;
  },

  getRecentActivity: async (): Promise<RecentActivity[]> => {
    await delay(500);
    return mockRecentActivity;
  },
};

// Internship Listings APIs
export const listingsApi = {
  getListings: async (
    page: number = 1,
    perPage: number = 25,
    filters?: ListingFilters,
    search?: string
  ): Promise<PaginatedResponse<InternshipListing>> => {
    await delay(600);
    
    let filtered = [...mockInternshipListings];
    
    if (filters) {
      if (filters.domain) {
        filtered = filtered.filter((l) => l.domain === filters.domain);
      }
      if (filters.mode) {
        filtered = filtered.filter((l) => l.mode === filters.mode);
      }
      if (filters.country) {
        filtered = filtered.filter((l) => l.country === filters.country);
      }
      if (filters.status) {
        filtered = filtered.filter((l) => l.status === filters.status);
      }
    }
    
    if (search) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(
        (l) =>
          l.title.toLowerCase().includes(searchLower) ||
          l.company.toLowerCase().includes(searchLower)
      );
    }
    
    const start = (page - 1) * perPage;
    const end = start + perPage;
    
    return {
      data: filtered.slice(start, end),
      total: filtered.length,
      page,
      perPage,
      totalPages: Math.ceil(filtered.length / perPage),
    };
  },

  getListing: async (id: string): Promise<InternshipListing | null> => {
    await delay(400);
    return mockInternshipListings.find((l) => l.id === id) || null;
  },

  createListing: async (listing: Omit<InternshipListing, 'id'>): Promise<InternshipListing> => {
    await delay(800);
    const newListing: InternshipListing = {
      ...listing,
      id: Math.random().toString(36).substring(7),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    mockInternshipListings.unshift(newListing);
    return newListing;
  },

  updateListing: async (
    id: string,
    listing: Partial<InternshipListing>
  ): Promise<InternshipListing | null> => {
    await delay(600);
    const index = mockInternshipListings.findIndex((l) => l.id === id);
    if (index === -1) return null;
    
    mockInternshipListings[index] = {
      ...mockInternshipListings[index],
      ...listing,
      updatedAt: new Date().toISOString(),
    };
    return mockInternshipListings[index];
  },

  deleteListing: async (id: string): Promise<boolean> => {
    await delay(500);
    const index = mockInternshipListings.findIndex((l) => l.id === id);
    if (index === -1) return false;
    
    mockInternshipListings[index].status = 'Archived';
    return true;
  },

  bulkDelete: async (ids: string[]): Promise<boolean> => {
    await delay(800);
    ids.forEach((id) => {
      const index = mockInternshipListings.findIndex((l) => l.id === id);
      if (index !== -1) {
        mockInternshipListings[index].status = 'Archived';
      }
    });
    return true;
  },
};

// Applications APIs
export const applicationsApi = {
  getApplications: async (
    page: number = 1,
    perPage: number = 25,
    filters?: {
      domain?: string;
      company?: string;
      status?: ApplicationStatus;
    },
    search?: string
  ): Promise<PaginatedResponse<Application>> => {
    await delay(600);
    
    let filtered = [...mockApplications];
    
    if (filters) {
      if (filters.domain) {
        filtered = filtered.filter((a) => a.domain === filters.domain);
      }
      if (filters.company) {
        filtered = filtered.filter((a) => a.company === filters.company);
      }
      if (filters.status) {
        filtered = filtered.filter((a) => a.status === filters.status);
      }
    }
    
    if (search) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(
        (a) =>
          a.studentName.toLowerCase().includes(searchLower) ||
          a.company.toLowerCase().includes(searchLower)
      );
    }
    
    const start = (page - 1) * perPage;
    const end = start + perPage;
    
    return {
      data: filtered.slice(start, end),
      total: filtered.length,
      page,
      perPage,
      totalPages: Math.ceil(filtered.length / perPage),
    };
  },

  updateStatus: async (id: string, status: ApplicationStatus): Promise<boolean> => {
    await delay(400);
    const index = mockApplications.findIndex((a) => a.id === id);
    if (index === -1) return false;
    
    mockApplications[index].status = status;
    return true;
  },

  bulkUpdateStatus: async (ids: string[], status: ApplicationStatus): Promise<boolean> => {
    await delay(600);
    ids.forEach((id) => {
      const index = mockApplications.findIndex((a) => a.id === id);
      if (index !== -1) {
        mockApplications[index].status = status;
      }
    });
    return true;
  },
};

// Students APIs
export const studentsApi = {
  getStudents: async (
    page: number = 1,
    perPage: number = 25,
    filters?: {
      college?: string;
      branch?: string;
      year?: number;
      domain?: string;
      status?: string;
    },
    search?: string
  ): Promise<PaginatedResponse<Student>> => {
    await delay(600);
    
    let filtered = [...mockStudents];
    
    if (filters) {
      if (filters.college) {
        filtered = filtered.filter((s) => s.college === filters.college);
      }
      if (filters.branch) {
        filtered = filtered.filter((s) => s.branch === filters.branch);
      }
      if (filters.year) {
        filtered = filtered.filter((s) => s.year === filters.year);
      }
      if (filters.domain) {
        filtered = filtered.filter((s) => s.domain === filters.domain);
      }
      if (filters.status) {
        filtered = filtered.filter((s) => s.status === filters.status);
      }
    }
    
    if (search) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(
        (s) =>
          s.name.toLowerCase().includes(searchLower) ||
          s.studentId.toLowerCase().includes(searchLower)
      );
    }
    
    const start = (page - 1) * perPage;
    const end = start + perPage;
    
    return {
      data: filtered.slice(start, end),
      total: filtered.length,
      page,
      perPage,
      totalPages: Math.ceil(filtered.length / perPage),
    };
  },

  getStudent: async (id: string): Promise<Student | null> => {
    await delay(400);
    return mockStudents.find((s) => s.id === id) || null;
  },

  banStudent: async (id: string, ban: boolean): Promise<boolean> => {
    await delay(400);
    const index = mockStudents.findIndex((s) => s.id === id);
    if (index === -1) return false;
    
    mockStudents[index].status = ban ? 'Banned' : 'Active';
    return true;
  },

  deleteStudent: async (id: string): Promise<boolean> => {
    await delay(500);
    const index = mockStudents.findIndex((s) => s.id === id);
    if (index === -1) return false;
    
    mockStudents.splice(index, 1);
    return true;
  },
};

// ML Model APIs
export const mlModelApi = {
  getMetrics: async (): Promise<ModelMetrics> => {
    await delay(500);
    return mockModelMetrics;
  },

  getFeatureImportance: async (): Promise<FeatureImportance[]> => {
    await delay(500);
    return mockFeatureImportance;
  },

  getDatasets: async (): Promise<DatasetInfo[]> => {
    await delay(500);
    return mockDatasets;
  },

  uploadDataset: async (file: File): Promise<DatasetInfo> => {
    await delay(1500);
    const newDataset: DatasetInfo = {
      id: Math.random().toString(36).substring(7),
      filename: file.name,
      uploadedAt: new Date().toISOString(),
      rowCount: Math.floor(Math.random() * 10000) + 40000,
      columnCount: 36,
      classBalance: {
        recommended: Math.floor(Math.random() * 10000) + 25000,
        notRecommended: Math.floor(Math.random() * 5000) + 10000,
      },
    };
    mockDatasets.unshift(newDataset);
    return newDataset;
  },

  retrainModel: async (): Promise<{ success: boolean; jobId: string }> => {
    await delay(1000);
    return { success: true, jobId: Math.random().toString(36).substring(7) };
  },

  getRetrainStatus: async (_jobId: string): Promise<{
    isTraining: boolean;
    progress: number;
    message: string;
  }> => {
    await delay(300);
    // Simulate progress - using _jobId to avoid unused variable warning
    console.log('Checking status for job:', _jobId);
    const progress = Math.floor(Math.random() * 100);
    return {
      isTraining: progress < 100,
      progress,
      message: progress < 100 ? 'Training in progress...' : 'Training complete!',
    };
  },
};

// Analytics APIs
export const analyticsApi = {
  getDomainTrends: async (): Promise<DomainTrend[]> => {
    await delay(600);
    return mockDomainTrends;
  },

  getLocationHeatmap: async (): Promise<LocationHeatmap[]> => {
    await delay(600);
    return mockLocationHeatmap;
  },

  getStipendDistribution: async (): Promise<StipendDistribution[]> => {
    await delay(600);
    return mockStipendDistribution;
  },

  getApplicationFunnel: async (): Promise<ApplicationFunnel[]> => {
    await delay(600);
    return mockApplicationFunnel;
  },

  getTopInternships: async (): Promise<TopInternship[]> => {
    await delay(600);
    return mockTopInternships;
  },

  getDomainMatchScores: async (): Promise<DomainMatchScore[]> => {
    await delay(600);
    return mockDomainMatchScores;
  },

  getCollegeApplications: async (): Promise<CollegeApplication[]> => {
    await delay(600);
    return mockCollegeApplications;
  },
};
