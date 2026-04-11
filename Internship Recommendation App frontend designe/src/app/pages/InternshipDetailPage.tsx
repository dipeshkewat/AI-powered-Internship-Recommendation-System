import { useParams, useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { internships } from "../data/internships";
import { MatchScoreRing } from "../components/MatchScoreRing";
import { calculateMatchScore } from "../data/internships";
import {
  ArrowLeft, MapPin, Clock, Users, Briefcase, Bookmark, BookmarkCheck,
  CheckCircle, Share2, ChevronRight, DollarSign, CalendarDays,
} from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function InternshipDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { profile, toggleSaveInternship, applyToInternship } = useUser();

  const internship = internships.find((i) => i.id === id);
  if (!internship) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-500">Internship not found.</p>
      </div>
    );
  }

  const isSaved = profile.savedInternships.includes(internship.id);
  const isApplied = profile.appliedInternships.some((a) => a.id === internship.id);
  const matchScore =
    profile.skills.length > 0
      ? calculateMatchScore(internship, {
          skills: profile.skills,
          tools: profile.tools,
          interests: profile.interests,
          preferredLocation: profile.preferredLocation,
          internshipType: profile.internshipType,
          duration: profile.duration,
        })
      : null;

  const relatedInternships = internships
    .filter((i) => i.id !== internship.id && i.domain === internship.domain)
    .slice(0, 3);

  return (
    <div className="min-h-screen" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Hero Header */}
      <div
        className="px-5 pt-12 pb-10 relative overflow-hidden"
        style={{ backgroundColor: internship.logoColor }}
      >
        <div className="absolute top-0 right-0 w-48 h-48 rounded-full bg-white/10" style={{ transform: "translate(30%, -50%)" }} />
        <div className="absolute bottom-0 left-0 w-32 h-32 rounded-full bg-black/10" style={{ transform: "translate(-30%, 50%)" }} />

        <div className="relative">
          <div className="flex items-center justify-between mb-6">
            <button
              onClick={() => navigate(-1)}
              className="w-9 h-9 rounded-full bg-white/25 flex items-center justify-center backdrop-blur-sm"
            >
              <ArrowLeft size={18} className="text-white" />
            </button>
            <div className="flex gap-2">
              <button
                onClick={() => toggleSaveInternship(internship.id)}
                className="w-9 h-9 rounded-full bg-white/25 flex items-center justify-center backdrop-blur-sm"
              >
                {isSaved ? (
                  <BookmarkCheck size={18} className="text-white" />
                ) : (
                  <Bookmark size={18} className="text-white" />
                )}
              </button>
              <button className="w-9 h-9 rounded-full bg-white/25 flex items-center justify-center backdrop-blur-sm">
                <Share2 size={18} className="text-white" />
              </button>
            </div>
          </div>

          <div className="flex items-end gap-4">
            <div className="w-18 h-18 rounded-2xl bg-white flex items-center justify-center shadow-xl p-3">
              <span className="text-2xl font-bold" style={{ color: internship.logoColor }}>
                {internship.companyInitial}
              </span>
            </div>
            <div className="flex-1">
              <div
                className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full mb-2"
                style={{ backgroundColor: "rgba(255,255,255,0.2)" }}
              >
                <span className="text-white text-[10px] font-semibold">{internship.domain}</span>
              </div>
              <h1 className="text-xl font-bold text-white leading-tight">{internship.title}</h1>
              <p className="text-white/80 text-sm">{internship.company}</p>
              <div className="flex items-center gap-1.5 mt-1">
                <MapPin size={11} className="text-white/60" />
                <span className="text-white/60 text-xs">{internship.location} · {internship.locationType}</span>
              </div>
            </div>
            {matchScore !== null && (
              <div className="bg-white/20 rounded-2xl p-2 shrink-0 backdrop-blur-sm">
                <MatchScoreRing score={matchScore} size={56} strokeWidth={4.5} fontSize="text-[10px]" />
                <p className="text-white/70 text-[9px] text-center mt-1">Match</p>
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="px-5 -mt-4 relative z-10 pb-32">
        {/* Quick info */}
        <div className="bg-white rounded-2xl shadow-md p-4 mb-4 border border-gray-100">
          <div className="grid grid-cols-3 gap-3">
            {[
              { icon: Briefcase, label: "Type", value: internship.type },
              { icon: Clock, label: "Duration", value: internship.duration },
              { icon: Users, label: "Applicants", value: internship.applicants.toLocaleString() },
            ].map(({ icon: Icon, label, value }) => (
              <div key={label} className="text-center">
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center mx-auto mb-1.5"
                  style={{ backgroundColor: "#EBF0FF" }}
                >
                  <Icon size={16} style={{ color: PRIMARY }} />
                </div>
                <p className="text-xs font-bold text-gray-900">{value}</p>
                <p className="text-[10px] text-gray-400">{label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Stipend + Openings */}
        <div
          className="rounded-2xl p-4 mb-4 border"
          style={{ background: "linear-gradient(135deg, #EBF0FF, #F0F4FF)", borderColor: "#C7D3FF" }}
        >
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center gap-1.5 mb-1">
                <DollarSign size={13} style={{ color: PRIMARY }} />
                <p className="text-[10px] text-gray-500 uppercase tracking-wide font-bold">Monthly Stipend</p>
              </div>
              <p className="text-2xl font-bold" style={{ color: PRIMARY }}>{internship.stipend}</p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1.5 mb-1 justify-end">
                <CalendarDays size={13} style={{ color: TERTIARY }} />
                <p className="text-[10px] text-gray-500 uppercase tracking-wide font-bold">Openings</p>
              </div>
              <p className="text-2xl font-bold" style={{ color: TERTIARY }}>{internship.openings}</p>
            </div>
          </div>
          <p className="text-xs text-gray-400 mt-2 border-t border-blue-100 pt-2">
            Posted {internship.postedDaysAgo === 0 ? "today" : `${internship.postedDaysAgo} days ago`} · {internship.type}
          </p>
        </div>

        {/* Description */}
        <div className="bg-white rounded-2xl p-4 mb-4 shadow-sm border border-gray-100">
          <h2 className="text-sm font-bold text-gray-900 mb-3">About the Role</h2>
          <p className="text-sm text-gray-600 leading-relaxed">{internship.description}</p>
        </div>

        {/* Responsibilities */}
        <div className="bg-white rounded-2xl p-4 mb-4 shadow-sm border border-gray-100">
          <h2 className="text-sm font-bold text-gray-900 mb-3">What You'll Do</h2>
          <div className="space-y-2.5">
            {internship.responsibilities.map((resp, idx) => (
              <div key={idx} className="flex items-start gap-2.5">
                <div
                  className="w-5 h-5 rounded-full flex items-center justify-center shrink-0 mt-0.5"
                  style={{ backgroundColor: "#EBF0FF" }}
                >
                  <CheckCircle size={12} style={{ color: PRIMARY }} />
                </div>
                <p className="text-sm text-gray-600">{resp}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Required Skills */}
        <div className="bg-white rounded-2xl p-4 mb-4 shadow-sm border border-gray-100">
          <h2 className="text-sm font-bold text-gray-900 mb-3">Required Skills</h2>
          <div className="flex flex-wrap gap-2">
            {internship.requiredSkills.map((skill) => {
              const isUserSkill = profile.skills.includes(skill);
              return (
                <span
                  key={skill}
                  className="px-3 py-1.5 rounded-full text-xs font-semibold flex items-center gap-1.5"
                  style={
                    isUserSkill
                      ? { backgroundColor: "#E8F5EC", color: TERTIARY, border: `1px solid #B8E0C5` }
                      : { backgroundColor: "#EBF0FF", color: PRIMARY, border: `1px solid #C7D3FF` }
                  }
                >
                  {isUserSkill && <CheckCircle size={10} />}
                  {skill}
                </span>
              );
            })}
          </div>
          {internship.tools.length > 0 && (
            <>
              <p className="text-xs font-bold text-gray-400 uppercase tracking-wide mt-3 mb-2">Tools & Technologies</p>
              <div className="flex flex-wrap gap-2">
                {internship.tools.map((tool) => (
                  <span
                    key={tool}
                    className="px-3 py-1.5 bg-gray-100 text-gray-600 rounded-full text-xs font-semibold border border-gray-200"
                  >
                    {tool}
                  </span>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Related internships */}
        {relatedInternships.length > 0 && (
          <div className="mb-4">
            <h2 className="text-sm font-bold text-gray-900 mb-3">Similar Internships</h2>
            <div className="space-y-3">
              {relatedInternships.map((rel) => (
                <div
                  key={rel.id}
                  onClick={() => navigate(`/internship/${rel.id}`)}
                  className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 flex items-center gap-3 cursor-pointer active:scale-[0.98] transition-transform"
                >
                  <div
                    className="w-11 h-11 rounded-xl flex items-center justify-center text-white font-bold shrink-0"
                    style={{ backgroundColor: rel.logoColor }}
                  >
                    {rel.companyInitial}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-gray-900 truncate">{rel.title}</p>
                    <p className="text-xs text-gray-400">{rel.company} · {rel.locationType}</p>
                    <p className="text-xs font-semibold mt-0.5" style={{ color: PRIMARY }}>{rel.stipend}</p>
                  </div>
                  <ChevronRight size={16} className="text-gray-400 shrink-0" />
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Bottom apply bar */}
      <div
        className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white border-t border-gray-100 px-5 py-4 shadow-xl"
        style={{ paddingBottom: "calc(1rem + env(safe-area-inset-bottom))" }}
      >
        <div className="flex gap-3">
          <button
            onClick={() => toggleSaveInternship(internship.id)}
            className="w-12 h-12 rounded-xl border-2 flex items-center justify-center shrink-0 transition-all"
            style={
              isSaved
                ? { borderColor: PRIMARY, backgroundColor: "#EBF0FF" }
                : { borderColor: "#E5E7EB" }
            }
          >
            {isSaved ? (
              <BookmarkCheck size={20} style={{ color: PRIMARY }} />
            ) : (
              <Bookmark size={20} className="text-gray-400" />
            )}
          </button>
          <motion.button
            whileTap={{ scale: 0.98 }}
            onClick={() => {
              if (!isApplied) {
                applyToInternship(internship.id, internship.title, internship.company);
              }
            }}
            className="flex-1 py-3.5 rounded-xl text-sm font-bold text-white flex items-center justify-center gap-2 transition-all"
            style={
              isApplied
                ? { backgroundColor: TERTIARY }
                : { backgroundColor: PRIMARY, boxShadow: "0 8px 24px rgba(5,29,218,0.25)" }
            }
          >
            {isApplied ? (
              <>
                <CheckCircle size={16} />
                Applied Successfully!
              </>
            ) : (
              <>Apply Now</>
            )}
          </motion.button>
        </div>
      </div>
    </div>
  );
}
