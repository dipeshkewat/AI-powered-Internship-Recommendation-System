import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { BottomNav } from "../components/BottomNav";
import { InternshipCard } from "../components/InternshipCard";
import { internships } from "../data/internships";
import { Bookmark, Search, ChevronRight } from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";

export function SavedPage() {
  const navigate = useNavigate();
  const { profile } = useUser();

  const savedInternships = internships.filter((i) => profile.savedInternships.includes(i.id));

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-6 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        <div className="absolute top-0 right-0 w-32 h-32 rounded-full bg-white/8" style={{ transform: "translate(40%, -40%)" }} />
        <div className="relative">
          <h1 className="text-2xl font-bold text-white mb-1">Saved Internships</h1>
          <p className="text-blue-200 text-sm">
            {savedInternships.length} internship{savedInternships.length !== 1 ? "s" : ""} bookmarked
          </p>
          {savedInternships.length > 0 && (
            <button
              onClick={() => navigate("/search")}
              className="mt-3 flex items-center gap-1.5 text-xs font-semibold text-blue-200"
            >
              <Search size={13} />
              Browse more internships
              <ChevronRight size={13} />
            </button>
          )}
        </div>
      </div>

      <div className="px-5 pt-5">
        {savedInternships.length > 0 ? (
          <div className="space-y-3">
            {savedInternships.map((internship, idx) => (
              <motion.div
                key={internship.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.05 }}
              >
                <InternshipCard internship={internship} />
              </motion.div>
            ))}
          </div>
        ) : (
          <div className="text-center py-20">
            <div
              className="w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-4"
              style={{ backgroundColor: "#EBF0FF" }}
            >
              <Bookmark size={36} style={{ color: PRIMARY }} />
            </div>
            <p className="text-base font-bold text-gray-800 mb-2">No saved internships yet</p>
            <p className="text-sm text-gray-400 mb-6 px-8">
              Tap the bookmark icon on any internship card to save it here.
            </p>
            <button
              onClick={() => navigate("/search")}
              className="px-6 py-3 rounded-2xl text-white text-sm font-bold shadow-lg"
              style={{ backgroundColor: PRIMARY, boxShadow: "0 8px 24px rgba(5,29,218,0.25)" }}
            >
              Explore Internships
            </button>
          </div>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
