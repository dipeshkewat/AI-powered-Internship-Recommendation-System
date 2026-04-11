import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { BottomNav } from "../components/BottomNav";
import {
  Edit3, LogOut, GraduationCap, Briefcase, MapPin, Clock, ChevronRight,
  Award, Star, TrendingUp, User, Phone, Mail, Settings, Shield,
} from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function ProfilePage() {
  const navigate = useNavigate();
  const { profile, logout } = useUser();

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  const profileCompletion = (() => {
    const fields = [
      profile.fullName,
      profile.degree,
      profile.cgpa,
      profile.skills.length > 0,
      profile.interests.length > 0,
      profile.preferredLocation,
    ];
    return Math.round((fields.filter(Boolean).length / fields.length) * 100);
  })();

  const initials = profile.fullName
    ? profile.fullName.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2)
    : profile.email[0].toUpperCase();

  return (
    <div className="min-h-screen pb-24" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-10 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        <div className="absolute top-0 right-0 w-48 h-48 rounded-full bg-white/8" style={{ transform: "translate(40%, -50%)" }} />
        <div className="absolute bottom-0 left-12 w-32 h-32 rounded-full bg-white/5" style={{ transform: "translateY(50%)" }} />

        <div className="relative flex items-center justify-between mb-6">
          <span className="text-white font-bold text-lg">My Profile</span>
          <div className="flex gap-2">
            <button
              onClick={() => navigate("/settings")}
              className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center border border-white/20"
            >
              <Settings size={16} className="text-white" />
            </button>
            <button
              onClick={() => navigate("/profile/edit")}
              className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center border border-white/20"
            >
              <Edit3 size={16} className="text-white" />
            </button>
          </div>
        </div>

        <div className="relative flex items-center gap-4">
          <div
            className="w-20 h-20 rounded-2xl flex items-center justify-center text-white text-2xl font-bold shadow-xl border-4 border-white/30"
            style={{ backgroundColor: profile.avatarColor || PRIMARY }}
          >
            {initials}
          </div>
          <div className="flex-1">
            <h1 className="text-xl font-bold text-white">
              {profile.fullName || "Set your name →"}
            </h1>
            <p className="text-blue-200 text-sm">
              {profile.degree
                ? `${profile.degree}${profile.branch ? ` · ${profile.branch}` : ""}`
                : "Add your degree"}
            </p>
            <p className="text-blue-300 text-xs mt-0.5">{profile.email}</p>
          </div>
        </div>

        {/* Profile completion */}
        <div className="relative mt-5 bg-white/15 rounded-2xl p-4 border border-white/15">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Shield size={13} className="text-white/70" />
              <span className="text-white/80 text-xs font-medium">Profile Strength</span>
            </div>
            <span className="text-white font-bold text-sm">{profileCompletion}%</span>
          </div>
          <div className="h-2 bg-white/20 rounded-full overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${profileCompletion}%` }}
              transition={{ duration: 1, delay: 0.3 }}
              className="h-full rounded-full"
              style={{ backgroundColor: profileCompletion === 100 ? "#7DF5A0" : "white" }}
            />
          </div>
          {profileCompletion < 100 && (
            <p className="text-white/50 text-[10px] mt-1.5">Complete to unlock better matches</p>
          )}
        </div>
      </div>

      <div className="px-5 -mt-4 relative z-10">
        {/* Stats cards */}
        <div className="grid grid-cols-3 gap-3 mb-5">
          {[
            { label: "Applied", value: profile.appliedInternships.length, icon: Briefcase, color: PRIMARY, bg: "#EBF0FF" },
            { label: "Saved", value: profile.savedInternships.length, icon: Star, color: "#D97706", bg: "#FEF3C7" },
            { label: "Matches", value: profile.skills.length > 0 ? "24" : "—", icon: TrendingUp, color: TERTIARY, bg: "#E8F5EC" },
          ].map(({ label, value, icon: Icon, color, bg }) => (
            <motion.div
              key={label}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-white rounded-2xl p-3 shadow-sm border border-gray-100 text-center"
            >
              <div
                className="w-9 h-9 rounded-xl flex items-center justify-center mx-auto mb-2"
                style={{ backgroundColor: bg }}
              >
                <Icon size={16} style={{ color }} />
              </div>
              <p className="text-base font-bold text-gray-900">{value}</p>
              <p className="text-[10px] text-gray-400">{label}</p>
            </motion.div>
          ))}
        </div>

        {/* Personal Info */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50 flex items-center justify-between">
            <h2 className="text-sm font-bold text-gray-900">Personal Info</h2>
            <button
              onClick={() => navigate("/profile/edit")}
              className="text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              Edit
            </button>
          </div>
          {[
            { icon: User, label: "Full Name", value: profile.fullName || "Not set" },
            { icon: Mail, label: "Email", value: profile.email },
            { icon: Phone, label: "Phone", value: profile.phoneNo || "Not set" },
          ].map(({ icon: Icon, label, value }) => (
            <div key={label} className="flex items-center gap-3 px-4 py-3 border-b border-gray-50 last:border-0">
              <div
                className="w-8 h-8 rounded-lg flex items-center justify-center shrink-0"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <Icon size={14} style={{ color: PRIMARY }} />
              </div>
              <div>
                <p className="text-[10px] text-gray-400 uppercase tracking-wide">{label}</p>
                <p className="text-sm text-gray-800 font-medium">{value}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Academic Info */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50 flex items-center justify-between">
            <h2 className="text-sm font-bold text-gray-900">Academic Details</h2>
            <button
              onClick={() => navigate("/profile/edit")}
              className="text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              Edit
            </button>
          </div>
          {[
            { icon: GraduationCap, label: "Degree & Branch", value: `${profile.degree || "—"}${profile.branch ? ` · ${profile.branch}` : ""}` },
            { icon: GraduationCap, label: "Current Year", value: profile.currentYear || "Not set" },
            { icon: Award, label: "CGPA", value: profile.cgpa ? `${profile.cgpa} / 10` : "Not set" },
          ].map(({ icon: Icon, label, value }) => (
            <div key={label} className="flex items-center gap-3 px-4 py-3 border-b border-gray-50 last:border-0">
              <div
                className="w-8 h-8 rounded-lg flex items-center justify-center shrink-0"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <Icon size={14} style={{ color: PRIMARY }} />
              </div>
              <div>
                <p className="text-[10px] text-gray-400 uppercase tracking-wide">{label}</p>
                <p className="text-sm text-gray-800 font-medium">{value}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Skills */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-bold text-gray-900">Skills</h2>
            <button
              onClick={() => navigate("/profile/edit")}
              className="text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              Edit
            </button>
          </div>
          {profile.skills.length > 0 ? (
            <div className="flex flex-wrap gap-2">
              {profile.skills.map((skill) => (
                <span
                  key={skill}
                  className="px-3 py-1 rounded-full text-xs font-medium"
                  style={{ backgroundColor: "#EBF0FF", color: PRIMARY }}
                >
                  {skill}
                </span>
              ))}
            </div>
          ) : (
            <p className="text-xs text-gray-400">No skills added yet</p>
          )}
          {profile.tools.length > 0 && (
            <>
              <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wide mt-3 mb-2">Tools</p>
              <div className="flex flex-wrap gap-2">
                {profile.tools.map((tool) => (
                  <span
                    key={tool}
                    className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-xs font-medium"
                  >
                    {tool}
                  </span>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Interests */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-bold text-gray-900">Interests</h2>
            <button
              onClick={() => navigate("/profile/edit")}
              className="text-xs font-semibold"
              style={{ color: PRIMARY }}
            >
              Edit
            </button>
          </div>
          {profile.interests.length > 0 ? (
            <div className="flex flex-wrap gap-2">
              {profile.interests.map((interest) => (
                <span
                  key={interest}
                  className="px-3 py-1 rounded-full text-xs font-medium"
                  style={{ backgroundColor: "#E8F5EC", color: TERTIARY }}
                >
                  {interest}
                </span>
              ))}
            </div>
          ) : (
            <p className="text-xs text-gray-400">No interests added yet</p>
          )}
        </div>

        {/* Preferences */}
        {(profile.preferredLocation || profile.internshipType || profile.duration) && (
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 p-4">
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-sm font-bold text-gray-900">Preferences</h2>
              <button
                onClick={() => navigate("/profile/edit")}
                className="text-xs font-semibold"
                style={{ color: PRIMARY }}
              >
                Edit
              </button>
            </div>
            <div className="flex flex-wrap gap-2">
              {profile.preferredLocation && (
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-gray-100 rounded-full">
                  <MapPin size={12} className="text-gray-500" />
                  <span className="text-xs text-gray-600 font-medium">{profile.preferredLocation}</span>
                </div>
              )}
              {profile.internshipType && (
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-gray-100 rounded-full">
                  <Briefcase size={12} className="text-gray-500" />
                  <span className="text-xs text-gray-600 font-medium">{profile.internshipType}</span>
                </div>
              )}
              {profile.duration && (
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-gray-100 rounded-full">
                  <Clock size={12} className="text-gray-500" />
                  <span className="text-xs text-gray-600 font-medium">{profile.duration}</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Quick links */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 mb-4 overflow-hidden">
          {[
            { label: "My Applications", path: "/applications", icon: Briefcase },
            { label: "Saved Internships", path: "/saved", icon: Star },
            { label: "Settings", path: "/settings", icon: Settings },
          ].map(({ label, path, icon: Icon }) => (
            <button
              key={path}
              onClick={() => navigate(path)}
              className="w-full flex items-center gap-3 px-4 py-3.5 border-b border-gray-50 last:border-0 hover:bg-gray-50 transition-colors"
            >
              <div
                className="w-8 h-8 rounded-lg flex items-center justify-center"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <Icon size={14} style={{ color: PRIMARY }} />
              </div>
              <span className="text-sm font-medium text-gray-700 flex-1">{label}</span>
              <ChevronRight size={16} className="text-gray-400" />
            </button>
          ))}
        </div>

        {/* Logout */}
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl border-2 border-red-100 text-red-500 text-sm font-semibold hover:bg-red-50 transition-colors mb-4"
        >
          <LogOut size={16} />
          Logout
        </button>

        <p className="text-center text-xs text-gray-400 mb-4">
          InterMatch v1.0 · AI-Powered Internship Platform
        </p>
      </div>

      <BottomNav />
    </div>
  );
}
