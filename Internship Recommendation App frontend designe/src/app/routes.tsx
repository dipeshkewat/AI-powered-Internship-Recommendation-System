import { createBrowserRouter } from "react-router";
import { WelcomePage } from "./pages/WelcomePage";
import { AuthPage } from "./pages/AuthPage";
import { EducationPage } from "./pages/EducationPage";
import { ExperienceLevelPage } from "./pages/ExperienceLevelPage";
import { PastInternshipPage } from "./pages/PastInternshipPage";
import { BasicInfoPage } from "./pages/BasicInfoPage";
import { DashboardPage } from "./pages/DashboardPage";
import { AcademicDetailsPage } from "./pages/AcademicDetailsPage";
import { SkillsPage } from "./pages/SkillsPage";
import { InterestsPage } from "./pages/InterestsPage";
import { PreferencesPage } from "./pages/PreferencesPage";
import { RecommendationsPage } from "./pages/RecommendationsPage";
import { SearchPage } from "./pages/SearchPage";
import { SavedPage } from "./pages/SavedPage";
import { ApplicationsPage } from "./pages/ApplicationsPage";
import { ProfilePage } from "./pages/ProfilePage";
import { EditProfilePage } from "./pages/EditProfilePage";
import { NotificationsPage } from "./pages/NotificationsPage";
import { InternshipDetailPage } from "./pages/InternshipDetailPage";
import { SettingsPage } from "./pages/SettingsPage";

function NotFound() {
  return (
    <div
      className="min-h-screen flex flex-col items-center justify-center"
      style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}
    >
      <div
        className="w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-4 text-4xl"
        style={{ backgroundColor: "#EBF0FF" }}
      >
        🔍
      </div>
      <h1 className="text-xl font-bold text-gray-800 mb-2">Page Not Found</h1>
      <p className="text-gray-500 text-sm mb-6">The page you're looking for doesn't exist.</p>
      <a
        href="/"
        className="px-6 py-3 rounded-2xl text-white text-sm font-semibold"
        style={{ backgroundColor: "#051DDA" }}
      >
        Go Home
      </a>
    </div>
  );
}

export const router = createBrowserRouter([
  // Public routes
  { path: "/", Component: WelcomePage },
  { path: "/auth", Component: AuthPage },

  // Onboarding flow (step by step)
  { path: "/onboarding/education", Component: EducationPage },
  { path: "/onboarding/experience", Component: ExperienceLevelPage },
  { path: "/onboarding/past-internship", Component: PastInternshipPage },
  { path: "/onboarding/basic-info", Component: BasicInfoPage },
  { path: "/onboarding/academic", Component: AcademicDetailsPage },
  { path: "/onboarding/skills", Component: SkillsPage },
  { path: "/onboarding/interests", Component: InterestsPage },
  { path: "/onboarding/preferences", Component: PreferencesPage },

  // Main app (authenticated)
  { path: "/dashboard", Component: DashboardPage },
  { path: "/recommendations", Component: RecommendationsPage },
  { path: "/search", Component: SearchPage },
  { path: "/saved", Component: SavedPage },
  { path: "/applications", Component: ApplicationsPage },
  { path: "/profile", Component: ProfilePage },
  { path: "/profile/edit", Component: EditProfilePage },
  { path: "/notifications", Component: NotificationsPage },
  { path: "/internship/:id", Component: InternshipDetailPage },
  { path: "/settings", Component: SettingsPage },

  // 404
  { path: "*", Component: NotFound },
]);
