import { MapPin, Clock, Bookmark, BookmarkCheck, Users, Calendar } from "lucide-react";
import { Internship } from "../data/internships";
import { useUser } from "../context/UserContext";
import { MatchScoreRing } from "./MatchScoreRing";
import { useNavigate } from "react-router";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

interface InternshipCardProps {
  internship: Internship & { matchScore?: number };
  showMatchScore?: boolean;
  compact?: boolean;
}

export function InternshipCard({
  internship,
  showMatchScore = false,
  compact = false,
}: InternshipCardProps) {
  const { profile, toggleSaveInternship, applyToInternship } = useUser();
  const navigate = useNavigate();
  const isSaved = profile.savedInternships.includes(internship.id);
  const isApplied = profile.appliedInternships.some((a) => a.id === internship.id);

  const handleApply = (e: React.MouseEvent) => {
    e.stopPropagation();
    applyToInternship(internship.id, internship.title, internship.company);
  };

  const handleSave = (e: React.MouseEvent) => {
    e.stopPropagation();
    toggleSaveInternship(internship.id);
  };

  const handleCardClick = () => {
    navigate(`/internship/${internship.id}`);
  };

  if (compact) {
    return (
      <div
        onClick={handleCardClick}
        className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 cursor-pointer active:scale-[0.98] transition-transform"
      >
        <div className="flex items-start gap-3">
          <div
            className="w-11 h-11 rounded-xl flex items-center justify-center text-white shrink-0"
            style={{ backgroundColor: internship.logoColor }}
          >
            <span className="text-base font-bold">{internship.companyInitial}</span>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div>
                <p className="text-sm font-semibold text-gray-900 truncate">{internship.title}</p>
                <p className="text-xs" style={{ color: "#6F6F6F" }}>{internship.company}</p>
              </div>
              {showMatchScore && internship.matchScore !== undefined && (
                <MatchScoreRing score={internship.matchScore} size={44} strokeWidth={4} fontSize="text-[9px]" />
              )}
            </div>
            <div className="flex items-center gap-3 mt-1.5">
              <span className="flex items-center gap-1 text-xs" style={{ color: "#9CA3AF" }}>
                <MapPin size={10} /> {internship.locationType}
              </span>
              <span className="flex items-center gap-1 text-xs" style={{ color: "#9CA3AF" }}>
                <Clock size={10} /> {internship.duration}
              </span>
              <span className="text-xs font-semibold" style={{ color: PRIMARY }}>{internship.stipend}</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      onClick={handleCardClick}
      className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 cursor-pointer active:scale-[0.98] transition-transform"
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div
            className="w-12 h-12 rounded-xl flex items-center justify-center text-white shrink-0 shadow-sm"
            style={{ backgroundColor: internship.logoColor }}
          >
            <span className="text-lg font-bold">{internship.companyInitial}</span>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900">{internship.title}</h3>
            <p className="text-xs" style={{ color: "#6F6F6F" }}>{internship.company}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {showMatchScore && internship.matchScore !== undefined && (
            <MatchScoreRing score={internship.matchScore} size={52} strokeWidth={4} fontSize="text-[10px]" />
          )}
          <button
            onClick={handleSave}
            className="p-1.5 rounded-lg transition-colors"
            style={{ backgroundColor: isSaved ? "#EBF0FF" : "transparent" }}
          >
            {isSaved ? (
              <BookmarkCheck size={18} style={{ color: PRIMARY }} />
            ) : (
              <Bookmark size={18} className="text-gray-400" />
            )}
          </button>
        </div>
      </div>

      {/* Domain badge + skills */}
      <div className="flex flex-wrap gap-1.5 mb-3">
        <span
          className="px-2.5 py-0.5 rounded-full text-xs font-semibold"
          style={{ backgroundColor: "#EBF0FF", color: PRIMARY }}
        >
          {internship.domain}
        </span>
        {internship.requiredSkills.slice(0, 2).map((skill) => (
          <span
            key={skill}
            className="px-2 py-0.5 bg-gray-100 text-gray-600 rounded-full text-xs font-medium"
          >
            {skill}
          </span>
        ))}
        {internship.requiredSkills.length > 2 && (
          <span className="px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full text-xs">
            +{internship.requiredSkills.length - 2}
          </span>
        )}
      </div>

      {/* Meta info */}
      <div className="flex items-center gap-3 mb-4 flex-wrap">
        <span className="flex items-center gap-1 text-xs text-gray-500">
          <MapPin size={11} className="text-gray-400" />
          {internship.location} · {internship.locationType}
        </span>
        <span className="flex items-center gap-1 text-xs text-gray-500">
          <Clock size={11} className="text-gray-400" />
          {internship.duration}
        </span>
        <span className="flex items-center gap-1 text-xs text-gray-500">
          <Users size={11} className="text-gray-400" />
          {internship.applicants.toLocaleString()} applied
        </span>
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between pt-3 border-t border-gray-50">
        <div>
          <p className="text-sm font-bold text-gray-900">{internship.stipend}</p>
          <p className="text-xs" style={{ color: "#6F6F6F" }}>{internship.type}</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={handleSave}
            className="px-3 py-2 rounded-xl text-xs font-semibold border-2 transition-colors"
            style={
              isSaved
                ? { borderColor: PRIMARY, color: PRIMARY, backgroundColor: "#EBF0FF" }
                : { borderColor: "#E5E7EB", color: "#525252", backgroundColor: "transparent" }
            }
          >
            {isSaved ? "Saved ✓" : "Save"}
          </button>
          <button
            onClick={handleApply}
            className="px-4 py-2 rounded-xl text-xs font-semibold text-white transition-all active:scale-95"
            style={
              isApplied
                ? { backgroundColor: TERTIARY, cursor: "default" }
                : { backgroundColor: PRIMARY, boxShadow: "0 4px 12px rgba(5,29,218,0.2)" }
            }
          >
            {isApplied ? "Applied ✓" : "Apply"}
          </button>
        </div>
      </div>

      {internship.postedDaysAgo <= 3 && (
        <div className="mt-2.5 flex items-center gap-1">
          <Calendar size={10} style={{ color: TERTIARY }} />
          <span className="text-xs font-medium" style={{ color: TERTIARY }}>
            Posted {internship.postedDaysAgo === 0 ? "today" : `${internship.postedDaysAgo}d ago`} · {internship.openings} openings
          </span>
        </div>
      )}
    </div>
  );
}
