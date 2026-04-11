import { useState } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { BottomNav } from "../components/BottomNav";
import { InternshipCard } from "../components/InternshipCard";
import { internships } from "../data/internships";
import { Bell, Search, Sparkles, TrendingUp, MapPin, Award, ChevronRight, Zap } from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

const domainEmojis: Record<string, string> = {
  "Web Dev": "💻",
  "App Dev": "📱",
  "Data Science": "📊",
  "AI/ML": "🤖",
  "Cybersecurity": "🔐",
};

const categories = ["All", "Web Dev", "App Dev", "AI/ML", "Data Science", "Cybersecurity"];

export function DashboardPage() {
  const navigate = useNavigate();
  const { profile, unreadNotificationCount } = useUser();
  const [activeCategory, setActiveCategory] = useState("All");

  const firstName = profile.fullName ? profile.fullName.split(" ")[0] : "there";
  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

  const featuredInternships = internships.slice(0, 6);
  const filteredInternships = activeCategory === "All"
    ? internships
    : internships.filter((i) => i.domain === activeCategory);

  const profileCompletion = (() => {
    let count = 0;
    if (profile.fullName) count++;
    if (profile.degree) count++;
    if (profile.skills.length > 0) count++;
    if (profile.interests.length > 0) count++;
    if (profile.preferredLocation) count++;
    if (profile.cgpa) count++;
    return Math.round((count / 6) * 100);
  })();

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-6 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        {/* Decorative */}
        <div className="absolute top-0 right-0 w-52 h-52 rounded-full bg-white/8" style={{ transform: "translate(40%, -40%)" }} />
        <div className="absolute bottom-0 left-8 w-20 h-20 rounded-full bg-white/5" />

        <div className="relative">
          <div className="flex items-center justify-between mb-5">
            <div className="flex items-center gap-3">
              <div
                className="w-12 h-12 rounded-2xl flex items-center justify-center text-white font-bold text-lg shadow-lg border-2 border-white/30"
                style={{ backgroundColor: profile.avatarColor || "#051DDA" }}
              >
                {profile.fullName ? profile.fullName[0].toUpperCase() : profile.email[0].toUpperCase()}
              </div>
              <div>
                <p className="text-white/70 text-xs">{greeting} 👋</p>
                <p className="text-white font-bold text-base">{firstName}</p>
              </div>
            </div>
            <button
              onClick={() => navigate("/notifications")}
              className="relative w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center border border-white/20"
            >
              <Bell size={18} className="text-white" />
              {unreadNotificationCount > 0 && (
                <div className="absolute -top-1.5 -right-1.5 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center border-2 border-white">
                  <span className="text-white text-[9px] font-bold">{unreadNotificationCount}</span>
                </div>
              )}
            </button>
          </div>

          {/* Search bar */}
          <button
            onClick={() => navigate("/search")}
            className="w-full flex items-center gap-3 rounded-2xl px-4 py-3.5 border border-white/20 mb-4"
            style={{ backgroundColor: "rgba(255,255,255,0.12)", backdropFilter: "blur(10px)" }}
          >
            <Search size={16} className="text-white/60" />
            <span className="text-white/50 text-sm">Search internships, companies...</span>
          </button>

          {/* Stats row */}
          <div className="grid grid-cols-3 gap-3">
            {[
              { label: "Applications", value: profile.appliedInternships.length.toString() },
              { label: "Saved", value: profile.savedInternships.length.toString() },
              { label: "Match Rate", value: profile.onboardingComplete ? "85%" : "—" },
            ].map(({ label, value }) => (
              <div key={label} className="bg-white/12 rounded-xl p-3 text-center border border-white/10">
                <p className="text-white font-bold text-xl">{value}</p>
                <p className="text-white/60 text-[10px] mt-0.5">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="px-5">
        {/* Profile completion */}
        {profileCompletion < 100 && (
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            onClick={() => navigate("/profile")}
            className="w-full mt-4 p-4 bg-white rounded-2xl shadow-sm border border-amber-100 flex items-center gap-3"
          >
            <div className="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center shrink-0">
              <Award size={18} className="text-amber-600" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold text-gray-800">Complete your profile</p>
              <div className="flex items-center gap-2 mt-1">
                <div className="flex-1 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all"
                    style={{ width: `${profileCompletion}%`, backgroundColor: TERTIARY }}
                  />
                </div>
                <span className="text-xs font-semibold shrink-0" style={{ color: TERTIARY }}>{profileCompletion}%</span>
              </div>
            </div>
            <ChevronRight size={16} className="text-gray-400 shrink-0" />
          </motion.button>
        )}

        {/* AI Recommendation CTA */}
        <motion.button
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          onClick={() => navigate("/recommendations")}
          className="w-full mt-4 p-5 rounded-2xl text-left overflow-hidden relative shadow-lg active:scale-[0.98] transition-transform"
          style={{ background: `linear-gradient(135deg, ${PRIMARY}, #1539F0)` }}
        >
          <div className="absolute right-0 top-0 bottom-0 flex items-center opacity-10">
            <TrendingUp size={100} className="text-white" />
          </div>
          <div className="absolute -top-4 -right-4 w-24 h-24 rounded-full bg-white/10" />
          <div className="relative">
            <div className="flex items-center gap-2 mb-2">
              <div
                className="w-6 h-6 rounded-lg flex items-center justify-center"
                style={{ backgroundColor: TERTIARY }}
              >
                <Zap size={12} className="text-white" />
              </div>
              <span className="text-white/80 text-xs font-semibold">AI-Powered · Random Forest ML</span>
            </div>
            <p className="text-white font-bold text-base mb-1">Find Your Best Matches</p>
            <p className="text-white/60 text-xs mb-4">
              Our ML model analyzes your profile to find top internships personalized for you.
            </p>
            <div
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold"
              style={{ backgroundColor: "white", color: PRIMARY }}
            >
              <Sparkles size={12} />
              Get Recommendations →
            </div>
          </div>
        </motion.button>

        {/* Trending / Featured */}
        <div className="mt-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-bold text-gray-900">🔥 Trending Now</h2>
            <button
              onClick={() => navigate("/search")}
              className="text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              See all →
            </button>
          </div>
          <div className="flex gap-3 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide">
            {featuredInternships.map((internship) => (
              <div key={internship.id} className="min-w-[220px]">
                <div
                  className="rounded-2xl p-4 text-white cursor-pointer active:scale-[0.98] transition-transform"
                  style={{ background: `linear-gradient(135deg, ${internship.logoColor}BB, ${internship.logoColor})` }}
                  onClick={() => navigate(`/internship/${internship.id}`)}
                >
                  <div className="flex items-center justify-between mb-3">
                    <div className="w-10 h-10 rounded-xl bg-white/25 flex items-center justify-center">
                      <span className="text-white font-bold">{internship.companyInitial}</span>
                    </div>
                    <div className="flex items-center gap-1 bg-white/20 px-2 py-1 rounded-full">
                      <MapPin size={10} className="text-white/80" />
                      <span className="text-white/80 text-[10px]">{internship.locationType}</span>
                    </div>
                  </div>
                  <p className="text-white font-bold text-sm leading-tight mb-0.5">{internship.title}</p>
                  <p className="text-white/70 text-xs mb-3">{internship.company}</p>
                  <div className="flex items-center justify-between border-t border-white/20 pt-2.5">
                    <span className="text-white font-bold text-xs">{internship.stipend}</span>
                    <span className="text-white/60 text-[10px]">{internship.duration}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Category filter */}
        <div className="mt-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-bold text-gray-900">Browse by Category</h2>
            <span className="text-xs text-gray-400">{filteredInternships.length} results</span>
          </div>

          <div className="flex gap-2 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide mb-4">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className="px-4 py-2 rounded-full text-xs font-semibold whitespace-nowrap border-2 transition-all flex items-center gap-1.5"
                style={
                  activeCategory === cat
                    ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                    : { backgroundColor: "white", color: "#525252", borderColor: "#E5E7EB" }
                }
              >
                {domainEmojis[cat] && <span>{domainEmojis[cat]}</span>}
                {cat}
              </button>
            ))}
          </div>

          <div className="space-y-3">
            {filteredInternships.slice(0, 10).map((internship, idx) => (
              <motion.div
                key={internship.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.04 }}
              >
                <InternshipCard internship={internship} />
              </motion.div>
            ))}
          </div>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
