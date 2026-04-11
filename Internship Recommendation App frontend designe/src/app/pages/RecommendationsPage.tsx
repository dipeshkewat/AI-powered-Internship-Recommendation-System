import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { BottomNav } from "../components/BottomNav";
import { InternshipCard } from "../components/InternshipCard";
import { getRecommendations } from "../data/internships";
import { ArrowLeft, Sparkles, SlidersHorizontal, ChevronDown, Zap } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { MatchScoreRing } from "../components/MatchScoreRing";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function RecommendationsPage() {
  const navigate = useNavigate();
  const { profile } = useUser();
  const [loading, setLoading] = useState(true);
  const [filterDomain, setFilterDomain] = useState("All");
  const [filterLocation, setFilterLocation] = useState("All");
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 1800);
    return () => clearTimeout(timer);
  }, []);

  const allRecommendations = getRecommendations({
    skills: profile.skills,
    tools: profile.tools,
    interests: profile.interests,
    preferredLocation: profile.preferredLocation,
    internshipType: profile.internshipType,
    duration: profile.duration,
  });

  const domains = ["All", ...new Set(allRecommendations.map((r) => r.domain))];
  const locations = ["All", "Remote", "On-site"];

  const filtered = allRecommendations.filter((r) => {
    const domainMatch = filterDomain === "All" || r.domain === filterDomain;
    const locationMatch = filterLocation === "All" || r.locationType === filterLocation;
    return domainMatch && locationMatch;
  });

  const topMatch = allRecommendations[0];
  const avgScore = allRecommendations.length > 0
    ? Math.round(allRecommendations.slice(0, 5).reduce((a, b) => a + b.matchScore, 0) / Math.min(5, allRecommendations.length))
    : 0;

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-6 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        <div className="absolute top-0 right-0 w-48 h-48 rounded-full bg-white/8" style={{ transform: "translate(40%, -50%)" }} />

        <div className="relative">
          <div className="flex items-center gap-3 mb-5">
            <button
              onClick={() => navigate(-1)}
              className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center border border-white/20"
            >
              <ArrowLeft size={18} className="text-white" />
            </button>
            <div>
              <div className="flex items-center gap-2">
                <Zap size={14} style={{ color: "#7DF5A0" }} />
                <span className="text-xs font-semibold" style={{ color: "#7DF5A0" }}>AI Recommendations</span>
              </div>
              <h1 className="text-xl font-bold text-white">Your Top Matches</h1>
            </div>
          </div>

          {/* Stats */}
          {!loading && (
            <div className="grid grid-cols-3 gap-3">
              {[
                { label: "Total Matches", value: allRecommendations.length.toString() },
                { label: "Avg. Score", value: `${avgScore}%` },
                { label: "Best Match", value: `${topMatch?.matchScore || 0}%` },
              ].map(({ label, value }) => (
                <div key={label} className="bg-white/12 rounded-xl p-3 text-center border border-white/10">
                  <p className="text-white font-bold text-xl">{value}</p>
                  <p className="text-white/60 text-[10px] mt-0.5">{label}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {loading ? (
        <div className="px-5 pt-8">
          {/* Loading animation */}
          <div className="text-center mb-8">
            <div className="relative w-20 h-20 mx-auto mb-5">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ repeat: Infinity, duration: 1.5, ease: "linear" }}
                className="absolute inset-0"
              >
                <div
                  className="w-20 h-20 rounded-full border-4 border-transparent border-t-4"
                  style={{ borderTopColor: PRIMARY }}
                />
              </motion.div>
              <div
                className="absolute inset-2 rounded-full flex items-center justify-center"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <Sparkles size={22} style={{ color: PRIMARY }} />
              </div>
            </div>
            <p className="text-base font-bold text-gray-900 mb-1">Analyzing your profile...</p>
            <p className="text-xs text-gray-500">Our Random Forest ML engine is finding your best matches</p>

            {/* Loading steps */}
            <div className="mt-5 space-y-2 max-w-xs mx-auto">
              {["Analyzing your skills & tools...", "Matching with 24+ internships...", "Ranking by fit score..."].map((step, i) => (
                <motion.div
                  key={step}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.4 }}
                  className="flex items-center gap-2 text-left"
                >
                  <div
                    className="w-4 h-4 rounded-full flex items-center justify-center"
                    style={{ backgroundColor: "#EBF0FF" }}
                  >
                    <div className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: PRIMARY }} />
                  </div>
                  <span className="text-xs text-gray-500">{step}</span>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Skeleton cards */}
          {[1, 2, 3].map((i) => (
            <div key={i} className="bg-white rounded-2xl p-5 shadow-sm mb-3 animate-pulse">
              <div className="flex items-start gap-3 mb-3">
                <div className="w-12 h-12 bg-gray-200 rounded-xl" />
                <div className="flex-1">
                  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2" />
                  <div className="h-3 bg-gray-200 rounded w-1/2" />
                </div>
                <div className="w-14 h-14 bg-gray-200 rounded-full" />
              </div>
              <div className="flex gap-2 mb-3">
                {[1, 2, 3].map((j) => (
                  <div key={j} className="h-6 bg-gray-200 rounded-full w-16" />
                ))}
              </div>
              <div className="h-10 bg-gray-200 rounded-xl" />
            </div>
          ))}
        </div>
      ) : (
        <div className="px-5 pt-4">
          {/* Profile summary chip */}
          {profile.skills.length > 0 && (
            <div className="mb-4 p-4 bg-white rounded-2xl shadow-sm border border-gray-100">
              <div className="flex items-center gap-2 mb-2">
                <Sparkles size={13} style={{ color: PRIMARY }} />
                <span className="text-xs font-semibold" style={{ color: PRIMARY }}>Matched Using Your Profile</span>
              </div>
              <div className="flex flex-wrap gap-1.5">
                {profile.skills.slice(0, 4).map((s) => (
                  <span
                    key={s}
                    className="px-2 py-0.5 rounded-full text-xs font-medium"
                    style={{ backgroundColor: "#EBF0FF", color: PRIMARY }}
                  >
                    {s}
                  </span>
                ))}
                {profile.interests.slice(0, 2).map((i) => (
                  <span
                    key={i}
                    className="px-2 py-0.5 rounded-full text-xs font-medium"
                    style={{ backgroundColor: "#E8F5EC", color: TERTIARY }}
                  >
                    {i}
                  </span>
                ))}
                {profile.preferredLocation && (
                  <span className="px-2 py-0.5 bg-gray-100 text-gray-600 rounded-full text-xs font-medium">
                    📍 {profile.preferredLocation}
                  </span>
                )}
              </div>
            </div>
          )}

          {/* Filters */}
          <div className="flex items-center gap-2 mb-4 flex-wrap">
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="flex items-center gap-1.5 px-4 py-2 rounded-xl border-2 bg-white text-xs font-semibold transition-all"
              style={
                showFilters
                  ? { borderColor: PRIMARY, color: PRIMARY, backgroundColor: "#EBF0FF" }
                  : { borderColor: "#E5E7EB", color: "#525252" }
              }
            >
              <SlidersHorizontal size={14} />
              Filters
              <ChevronDown size={12} className={`transition-transform ${showFilters ? "rotate-180" : ""}`} />
            </button>
            {locations.map((loc) => (
              <button
                key={loc}
                onClick={() => setFilterLocation(loc)}
                className="px-3 py-2 rounded-xl text-xs font-semibold whitespace-nowrap border-2 transition-all"
                style={
                  filterLocation === loc
                    ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                    : { backgroundColor: "white", color: "#525252", borderColor: "#E5E7EB" }
                }
              >
                {loc}
              </button>
            ))}
          </div>

          <AnimatePresence>
            {showFilters && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="mb-4 flex flex-wrap gap-2"
              >
                {domains.map((d) => (
                  <button
                    key={d}
                    onClick={() => setFilterDomain(d)}
                    className="px-3 py-1.5 rounded-xl text-xs font-semibold border-2 transition-all"
                    style={
                      filterDomain === d
                        ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                        : { backgroundColor: "white", color: "#525252", borderColor: "#E5E7EB" }
                    }
                  >
                    {d}
                  </button>
                ))}
              </motion.div>
            )}
          </AnimatePresence>

          {/* Top 3 highlight */}
          {filterDomain === "All" && filterLocation === "All" && filtered.length > 0 && (
            <div className="mb-5">
              <h2 className="text-sm font-bold text-gray-900 mb-3">🏆 Top 3 Picks for You</h2>
              <div className="flex gap-3 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide">
                {filtered.slice(0, 3).map((item, idx) => (
                  <motion.div
                    key={item.id}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: idx * 0.1 }}
                    className="min-w-[195px] bg-white rounded-2xl p-4 shadow-sm border border-gray-100 cursor-pointer"
                    onClick={() => navigate(`/internship/${item.id}`)}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <div
                        className="w-10 h-10 rounded-xl flex items-center justify-center text-white text-sm font-bold"
                        style={{ backgroundColor: item.logoColor }}
                      >
                        {item.companyInitial}
                      </div>
                      <MatchScoreRing score={item.matchScore} size={44} strokeWidth={3.5} fontSize="text-[9px]" />
                    </div>
                    <p className="text-xs font-bold text-gray-900 leading-tight mb-0.5">{item.title}</p>
                    <p className="text-[10px] text-gray-400 mb-2">{item.company}</p>
                    <div className="flex items-center gap-1">
                      <span className="text-[10px] font-bold text-amber-500">
                        {["🥇", "🥈", "🥉"][idx]} {["1st", "2nd", "3rd"][idx]} pick
                      </span>
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>
          )}

          <h2 className="text-sm font-bold text-gray-900 mb-3">
            All Matches ({filtered.length})
          </h2>
          <div className="space-y-3">
            {filtered.map((internship, idx) => (
              <motion.div
                key={internship.id}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: Math.min(idx * 0.04, 0.4) }}
              >
                <InternshipCard internship={internship} showMatchScore />
              </motion.div>
            ))}
          </div>

          {filtered.length === 0 && (
            <div className="text-center py-12">
              <div
                className="w-16 h-16 rounded-3xl flex items-center justify-center mx-auto mb-3"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <SlidersHorizontal size={28} style={{ color: PRIMARY }} />
              </div>
              <p className="text-sm font-semibold text-gray-500">No matches with current filters</p>
              <button
                onClick={() => { setFilterDomain("All"); setFilterLocation("All"); }}
                className="mt-3 text-xs font-semibold"
                style={{ color: PRIMARY }}
              >
                Clear filters
              </button>
            </div>
          )}
        </div>
      )}

      <BottomNav />
    </div>
  );
}
