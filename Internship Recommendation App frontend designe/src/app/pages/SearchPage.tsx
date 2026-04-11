import { useState, useMemo } from "react";
import { useNavigate } from "react-router";
import { BottomNav } from "../components/BottomNav";
import { InternshipCard } from "../components/InternshipCard";
import { internships } from "../data/internships";
import { Search, X, SlidersHorizontal, ChevronDown } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

const PRIMARY = "#051DDA";

const domainFilters = ["All", "Web Dev", "App Dev", "AI/ML", "Data Science", "Cybersecurity"];
const locationFilters = ["All", "Remote", "On-site"];
const durationFilters = ["All", "1 month", "3 months", "6 months"];
const typeFilters = ["All", "Full-time", "Part-time"];

const domainEmojis: Record<string, string> = {
  "Web Dev": "💻", "App Dev": "📱", "Data Science": "📊", "AI/ML": "🤖", "Cybersecurity": "🔐",
};

export function SearchPage() {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [domain, setDomain] = useState("All");
  const [location, setLocation] = useState("All");
  const [duration, setDuration] = useState("All");
  const [type, setType] = useState("All");
  const [showFilters, setShowFilters] = useState(false);
  const [sortBy, setSortBy] = useState<"recent" | "stipend" | "applicants">("recent");

  const results = useMemo(() => {
    let filtered = internships.filter((i) => {
      const q = query.toLowerCase();
      const matchesQuery =
        !q ||
        i.title.toLowerCase().includes(q) ||
        i.company.toLowerCase().includes(q) ||
        i.requiredSkills.some((s) => s.toLowerCase().includes(q)) ||
        i.domain.toLowerCase().includes(q) ||
        i.location.toLowerCase().includes(q);

      const matchesDomain = domain === "All" || i.domain === domain;
      const matchesLocation = location === "All" || i.locationType === location;
      const matchesDuration = duration === "All" || i.duration === duration;
      const matchesType = type === "All" || i.type === type;

      return matchesQuery && matchesDomain && matchesLocation && matchesDuration && matchesType;
    });

    if (sortBy === "recent") filtered.sort((a, b) => a.postedDaysAgo - b.postedDaysAgo);
    else if (sortBy === "stipend") {
      filtered.sort((a, b) => {
        const aNum = parseInt(a.stipend.replace(/\D/g, ""));
        const bNum = parseInt(b.stipend.replace(/\D/g, ""));
        return bNum - aNum;
      });
    } else if (sortBy === "applicants") {
      filtered.sort((a, b) => b.applicants - a.applicants);
    }

    return filtered;
  }, [query, domain, location, duration, type, sortBy]);

  const hasActiveFilters = domain !== "All" || location !== "All" || duration !== "All" || type !== "All";
  const activeFilterCount = [domain, location, duration, type].filter((f) => f !== "All").length;

  const clearAll = () => {
    setQuery("");
    setDomain("All");
    setLocation("All");
    setDuration("All");
    setType("All");
  };

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div className="bg-white px-5 pt-12 pb-4 shadow-sm sticky top-0 z-10">
        <h1 className="text-xl font-bold text-gray-900 mb-3">Explore Internships</h1>
        <div className="relative">
          <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Role, company, skill, or location..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-11 pr-10 py-3 rounded-2xl border-2 text-sm transition-all focus:outline-none"
            style={{
              borderColor: query ? PRIMARY : "#F3F4F6",
              backgroundColor: query ? "white" : "#F9FAFB",
              fontFamily: "'Poppins', sans-serif",
            }}
            autoFocus
          />
          {query && (
            <button
              onClick={() => setQuery("")}
              className="absolute right-4 top-1/2 -translate-y-1/2"
            >
              <X size={16} className="text-gray-400" />
            </button>
          )}
        </div>
      </div>

      <div className="px-5 pt-4">
        {/* Quick domain tabs */}
        <div className="flex gap-2 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide mb-3">
          {domainFilters.map((d) => (
            <button
              key={d}
              onClick={() => setDomain(d)}
              className="px-3.5 py-2 rounded-full text-xs font-semibold whitespace-nowrap border-2 transition-all flex items-center gap-1"
              style={
                domain === d
                  ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                  : { backgroundColor: "white", color: "#525252", borderColor: "#E5E7EB" }
              }
            >
              {domainEmojis[d] && <span>{domainEmojis[d]}</span>}
              {d}
            </button>
          ))}
        </div>

        {/* Filter bar */}
        <div className="flex items-center gap-2 mb-3">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-1.5 px-3 py-2 rounded-xl border-2 text-xs font-semibold transition-all"
            style={
              showFilters || hasActiveFilters
                ? { borderColor: PRIMARY, backgroundColor: "#EBF0FF", color: PRIMARY }
                : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
            }
          >
            <SlidersHorizontal size={14} />
            Filters
            {hasActiveFilters && (
              <span
                className="w-4 h-4 rounded-full flex items-center justify-center text-[9px] font-bold text-white ml-0.5"
                style={{ backgroundColor: PRIMARY }}
              >
                {activeFilterCount}
              </span>
            )}
            <ChevronDown size={12} className={`transition-transform ${showFilters ? "rotate-180" : ""}`} />
          </button>

          <div className="flex gap-2 overflow-x-auto scrollbar-hide flex-1">
            {locationFilters.map((l) => (
              <button
                key={l}
                onClick={() => setLocation(l)}
                className="px-3 py-2 rounded-xl text-xs font-semibold whitespace-nowrap border-2 transition-all"
                style={
                  location === l
                    ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                    : { backgroundColor: "white", color: "#525252", borderColor: "#E5E7EB" }
                }
              >
                {l}
              </button>
            ))}
          </div>
        </div>

        {/* Expanded filters */}
        <AnimatePresence>
          {showFilters && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="mb-4 bg-white rounded-2xl p-4 shadow-sm border border-gray-100 overflow-hidden"
            >
              <div className="mb-3">
                <p className="text-xs font-bold text-gray-500 uppercase tracking-wide mb-2">Duration</p>
                <div className="flex flex-wrap gap-2">
                  {durationFilters.map((d) => (
                    <button
                      key={d}
                      onClick={() => setDuration(d)}
                      className="px-3 py-1.5 rounded-full text-xs font-medium border-2 transition-all"
                      style={
                        duration === d
                          ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                          : { backgroundColor: "#F9FAFB", color: "#525252", borderColor: "#E5E7EB" }
                      }
                    >
                      {d}
                    </button>
                  ))}
                </div>
              </div>
              <div className="mb-3">
                <p className="text-xs font-bold text-gray-500 uppercase tracking-wide mb-2">Type</p>
                <div className="flex flex-wrap gap-2">
                  {typeFilters.map((t) => (
                    <button
                      key={t}
                      onClick={() => setType(t)}
                      className="px-3 py-1.5 rounded-full text-xs font-medium border-2 transition-all"
                      style={
                        type === t
                          ? { backgroundColor: PRIMARY, color: "white", borderColor: PRIMARY }
                          : { backgroundColor: "#F9FAFB", color: "#525252", borderColor: "#E5E7EB" }
                      }
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>
              {hasActiveFilters && (
                <button
                  onClick={clearAll}
                  className="text-xs text-red-500 font-semibold mt-1"
                >
                  ✕ Clear all filters
                </button>
              )}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Sort + Results count */}
        <div className="flex items-center justify-between mb-4">
          <p className="text-xs text-gray-500">
            <span className="font-bold text-gray-900">{results.length}</span> internships found
          </p>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as typeof sortBy)}
            className="text-xs font-semibold text-gray-600 border-2 border-gray-100 rounded-xl px-3 py-1.5 bg-white focus:outline-none"
            style={{ fontFamily: "'Poppins', sans-serif" }}
          >
            <option value="recent">Most Recent</option>
            <option value="stipend">Highest Stipend</option>
            <option value="applicants">Most Applied</option>
          </select>
        </div>

        {/* Results */}
        {results.length > 0 ? (
          <div className="space-y-3">
            {results.map((internship, idx) => (
              <motion.div
                key={internship.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: Math.min(idx * 0.03, 0.3) }}
              >
                <InternshipCard internship={internship} />
              </motion.div>
            ))}
          </div>
        ) : (
          <div className="text-center py-16">
            <div
              className="w-16 h-16 rounded-3xl flex items-center justify-center mx-auto mb-3"
              style={{ backgroundColor: "#EBF0FF" }}
            >
              <Search size={28} style={{ color: PRIMARY }} />
            </div>
            <p className="text-sm font-semibold text-gray-500 mb-1">No internships found</p>
            <p className="text-xs text-gray-400">Try different keywords or clear filters</p>
            <button
              onClick={clearAll}
              className="mt-4 text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              Reset all filters
            </button>
          </div>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
