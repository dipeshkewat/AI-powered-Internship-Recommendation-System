import React, { createContext, useContext, useState, useEffect, ReactNode } from "react";

export interface AppliedInternship {
  id: string;
  title: string;
  company: string;
  appliedDate: string;
  status: "Applied" | "Under Review" | "Shortlisted" | "Rejected" | "Selected";
}

export interface UserProfile {
  // Auth
  email: string;
  password: string;

  // Onboarding
  educationLevel: "Graduate" | "Undergraduate" | "";
  experienceLevel: "Fresher" | "Intermediate" | "";
  hasDoneInternship: boolean | null;
  internshipDescription: string;

  // Basic Info
  fullName: string;
  phoneNo: string;
  avatarColor: string;

  // Academic
  degree: string;
  branch: string;
  currentYear: string;
  cgpa: string;

  // Skills
  skills: string[];
  tools: string[];

  // Interests
  interests: string[];

  // Preferences
  preferredLocation: "Remote" | "On-site" | "";
  internshipType: "Full-time" | "Part-time" | "";
  duration: "1 month" | "3 months" | "6 months" | "";

  // App state
  isAuthenticated: boolean;
  onboardingComplete: boolean;
  savedInternships: string[];
  appliedInternships: AppliedInternship[];
  notifications: Notification[];
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  time: string;
  read: boolean;
  type: "match" | "application" | "reminder" | "news";
}

const defaultProfile: UserProfile = {
  email: "",
  password: "",
  educationLevel: "",
  experienceLevel: "",
  hasDoneInternship: null,
  internshipDescription: "",
  fullName: "",
  phoneNo: "",
  avatarColor: "#5B4FCF",
  degree: "",
  branch: "",
  currentYear: "",
  cgpa: "",
  skills: [],
  tools: [],
  interests: [],
  preferredLocation: "",
  internshipType: "",
  duration: "",
  isAuthenticated: false,
  onboardingComplete: false,
  savedInternships: [],
  appliedInternships: [],
  notifications: [
    {
      id: "n1",
      title: "New Match Found!",
      message: "Google has a new Frontend Intern role that matches 90% of your profile.",
      time: "2 hours ago",
      read: false,
      type: "match",
    },
    {
      id: "n2",
      title: "Application Update",
      message: "Your application at Microsoft is now Under Review.",
      time: "1 day ago",
      read: false,
      type: "application",
    },
    {
      id: "n3",
      title: "Complete Your Profile",
      message: "Add your CGPA and skills to get better recommendations.",
      time: "2 days ago",
      read: true,
      type: "reminder",
    },
    {
      id: "n4",
      title: "Internship Season Alert",
      message: "Summer 2025 internship applications are now open at top companies.",
      time: "3 days ago",
      read: true,
      type: "news",
    },
  ],
};

interface UserContextType {
  profile: UserProfile;
  updateProfile: (updates: Partial<UserProfile>) => void;
  login: (email: string, password: string) => boolean;
  register: (email: string, password: string) => void;
  logout: () => void;
  toggleSaveInternship: (id: string) => void;
  applyToInternship: (id: string, title: string, company: string) => void;
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  unreadNotificationCount: number;
}

const UserContext = createContext<UserContextType | null>(null);

const STORAGE_KEY = "intermatch_profile";

const avatarColors = [
  "#051DDA", "#1539F0", "#198038", "#0F766E", "#D97706", "#DC2626", "#0284C7",
];

export function UserProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<UserProfile>(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) return { ...defaultProfile, ...JSON.parse(stored) };
    } catch {}
    return defaultProfile;
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
  }, [profile]);

  const updateProfile = (updates: Partial<UserProfile>) => {
    setProfile((prev) => ({ ...prev, ...updates }));
  };

  const login = (email: string, password: string): boolean => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const savedProfile: UserProfile = JSON.parse(stored);
        if (savedProfile.email === email && savedProfile.password === password) {
          setProfile({ ...savedProfile, isAuthenticated: true });
          return true;
        }
      }
    } catch {}
    // Demo login fallback
    if (email === "demo@intermatch.ai" && password === "demo123") {
      setProfile({
        ...defaultProfile,
        email,
        password,
        fullName: "Arjun Sharma",
        phoneNo: "9876543210",
        isAuthenticated: true,
        onboardingComplete: true,
        educationLevel: "Undergraduate",
        experienceLevel: "Fresher",
        degree: "B.Tech",
        branch: "Computer",
        currentYear: "3rd Year",
        cgpa: "8.5",
        skills: ["React", "Python", "JavaScript"],
        tools: ["Git/Github", "Docker"],
        interests: ["Web Dev", "AI/ML"],
        preferredLocation: "Remote",
        internshipType: "Full-time",
        duration: "3 months",
        avatarColor: avatarColors[0],
        savedInternships: ["1", "4"],
        appliedInternships: [
          {
            id: "2",
            title: "Machine Learning Intern",
            company: "Microsoft",
            appliedDate: "April 3, 2026",
            status: "Under Review",
          },
        ],
      });
      return true;
    }
    return false;
  };

  const register = (email: string, password: string) => {
    const randomColor = avatarColors[Math.floor(Math.random() * avatarColors.length)];
    setProfile({
      ...defaultProfile,
      email,
      password,
      isAuthenticated: true,
      avatarColor: randomColor,
    });
  };

  const logout = () => {
    setProfile({ ...defaultProfile });
    localStorage.removeItem(STORAGE_KEY);
  };

  const toggleSaveInternship = (id: string) => {
    setProfile((prev) => {
      const saved = prev.savedInternships.includes(id)
        ? prev.savedInternships.filter((s) => s !== id)
        : [...prev.savedInternships, id];
      return { ...prev, savedInternships: saved };
    });
  };

  const applyToInternship = (id: string, title: string, company: string) => {
    setProfile((prev) => {
      if (prev.appliedInternships.find((a) => a.id === id)) return prev;
      const newApplication: AppliedInternship = {
        id,
        title,
        company,
        appliedDate: new Date().toLocaleDateString("en-IN", {
          year: "numeric",
          month: "long",
          day: "numeric",
        }),
        status: "Applied",
      };
      return {
        ...prev,
        appliedInternships: [...prev.appliedInternships, newApplication],
      };
    });
  };

  const markNotificationRead = (id: string) => {
    setProfile((prev) => ({
      ...prev,
      notifications: prev.notifications.map((n) =>
        n.id === id ? { ...n, read: true } : n
      ),
    }));
  };

  const markAllNotificationsRead = () => {
    setProfile((prev) => ({
      ...prev,
      notifications: prev.notifications.map((n) => ({ ...n, read: true })),
    }));
  };

  const unreadNotificationCount = profile.notifications.filter((n) => !n.read).length;

  return (
    <UserContext.Provider
      value={{
        profile,
        updateProfile,
        login,
        register,
        logout,
        toggleSaveInternship,
        applyToInternship,
        markNotificationRead,
        markAllNotificationsRead,
        unreadNotificationCount,
      }}
    >
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const ctx = useContext(UserContext);
  if (!ctx) throw new Error("useUser must be used within UserProvider");
  return ctx;
}