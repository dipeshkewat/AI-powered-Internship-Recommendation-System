import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { BottomNav } from "../components/BottomNav";
import { ClipboardList, Clock, CheckCircle, XCircle, Star, ChevronRight, TrendingUp } from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

const statusConfig = {
  Applied: { color: PRIMARY, bg: "#EBF0FF", icon: Clock, label: "Applied" },
  "Under Review": { color: "#D97706", bg: "#FEF3C7", icon: Clock, label: "Under Review" },
  Shortlisted: { color: TERTIARY, bg: "#E8F5EC", icon: Star, label: "Shortlisted" },
  Selected: { color: TERTIARY, bg: "#E8F5EC", icon: CheckCircle, label: "Selected 🎉" },
  Rejected: { color: "#DC2626", bg: "#FEE2E2", icon: XCircle, label: "Rejected" },
};

const stages = ["Applied", "Under Review", "Shortlisted", "Selected"];

export function ApplicationsPage() {
  const navigate = useNavigate();
  const { profile } = useUser();

  const applications = profile.appliedInternships;

  const countByStatus = {
    Applied: applications.filter((a) => a.status === "Applied").length,
    "Under Review": applications.filter((a) => a.status === "Under Review").length,
    Shortlisted: applications.filter((a) => a.status === "Shortlisted").length,
    Selected: applications.filter((a) => a.status === "Selected").length,
    Rejected: applications.filter((a) => a.status === "Rejected").length,
  };

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-6 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        <div className="absolute top-0 right-0 w-40 h-40 rounded-full bg-white/8" style={{ transform: "translate(40%, -40%)" }} />
        <div className="relative">
          <h1 className="text-2xl font-bold text-white mb-1">My Applications</h1>
          <p className="text-blue-200 text-sm">
            {applications.length} application{applications.length !== 1 ? "s" : ""} submitted
          </p>

          {/* Status summary */}
          {applications.length > 0 && (
            <div className="grid grid-cols-4 gap-2 mt-4">
              {Object.entries(countByStatus)
                .filter(([status]) => status !== "Rejected")
                .map(([status, count]) => (
                  <div key={status} className="bg-white/12 rounded-xl p-2.5 text-center border border-white/10">
                    <p className="text-white font-bold text-xl">{count}</p>
                    <p className="text-white/60 text-[9px] leading-tight mt-0.5">{status}</p>
                  </div>
                ))}
            </div>
          )}
        </div>
      </div>

      <div className="px-5 pt-5">
        {applications.length > 0 ? (
          <>
            {/* Pipeline visualization */}
            <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 mb-4">
              <div className="flex items-center gap-2 mb-3">
                <TrendingUp size={14} style={{ color: PRIMARY }} />
                <p className="text-xs font-bold text-gray-700">Application Pipeline</p>
              </div>
              <div className="flex items-center">
                {stages.map((stage, idx) => {
                  const config = statusConfig[stage as keyof typeof statusConfig];
                  const count = countByStatus[stage as keyof typeof countByStatus];
                  const isLast = idx === stages.length - 1;
                  return (
                    <div key={stage} className="flex items-center flex-1">
                      <div className="flex-1 text-center">
                        <div
                          className="w-9 h-9 rounded-full flex items-center justify-center mx-auto mb-1"
                          style={{
                            backgroundColor: count > 0 ? config.bg : "#F3F4F6",
                          }}
                        >
                          <span
                            className="text-xs font-bold"
                            style={{ color: count > 0 ? config.color : "#9CA3AF" }}
                          >
                            {count}
                          </span>
                        </div>
                        <p className="text-[9px] text-gray-400 leading-tight">{stage}</p>
                      </div>
                      {!isLast && (
                        <div
                          className="w-4 h-0.5 shrink-0"
                          style={{ backgroundColor: "#E5E7EB" }}
                        />
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Application cards */}
            <div className="space-y-3">
              {applications.map((application, idx) => {
                const config = statusConfig[application.status];
                const Icon = config.icon;
                const stageIndex = stages.indexOf(application.status);

                return (
                  <motion.div
                    key={application.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.05 }}
                    className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 cursor-pointer active:scale-[0.98] transition-transform"
                    onClick={() => navigate(`/internship/${application.id}`)}
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-bold text-gray-900 truncate">{application.title}</p>
                        <p className="text-xs text-gray-500">{application.company}</p>
                        <p className="text-xs text-gray-400 mt-0.5">Applied {application.appliedDate}</p>
                      </div>
                      <div
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-full shrink-0 ml-3"
                        style={{ backgroundColor: config.bg }}
                      >
                        <Icon size={11} style={{ color: config.color }} />
                        <span className="text-[11px] font-semibold" style={{ color: config.color }}>
                          {config.label}
                        </span>
                      </div>
                    </div>

                    {/* Progress bar */}
                    {application.status !== "Rejected" && (
                      <div className="mt-2">
                        <div className="flex gap-1">
                          {stages.map((stage, i) => (
                            <div
                              key={stage}
                              className="flex-1 h-1.5 rounded-full transition-all"
                              style={{
                                backgroundColor: i <= stageIndex ? config.color : "#E5E7EB",
                              }}
                            />
                          ))}
                        </div>
                        <p className="text-[10px] text-gray-400 mt-1.5">
                          Stage {stageIndex + 1} of {stages.length} · {application.status}
                        </p>
                      </div>
                    )}

                    <div className="flex items-center justify-end mt-3 pt-2 border-t border-gray-50">
                      <span
                        className="text-xs font-semibold flex items-center gap-1"
                        style={{ color: PRIMARY }}
                      >
                        View Details <ChevronRight size={12} />
                      </span>
                    </div>
                  </motion.div>
                );
              })}
            </div>
          </>
        ) : (
          <div className="text-center py-20">
            <div
              className="w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-4"
              style={{ backgroundColor: "#EBF0FF" }}
            >
              <ClipboardList size={36} style={{ color: PRIMARY }} />
            </div>
            <p className="text-base font-bold text-gray-800 mb-2">No applications yet</p>
            <p className="text-sm text-gray-400 mb-6 px-8">
              Start applying to internships! Your applications will be tracked here.
            </p>
            <button
              onClick={() => navigate("/recommendations")}
              className="px-6 py-3 rounded-2xl text-white text-sm font-bold shadow-lg"
              style={{ backgroundColor: PRIMARY, boxShadow: "0 8px 24px rgba(5,29,218,0.25)" }}
            >
              Find Internships
            </button>
          </div>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
