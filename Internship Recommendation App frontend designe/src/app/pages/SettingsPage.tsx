import { useState } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { ArrowLeft, Bell, Shield, Globe, ChevronRight, Trash2, LogOut } from "lucide-react";

interface ToggleProps {
  enabled: boolean;
  onChange: () => void;
}

function Toggle({ enabled, onChange }: ToggleProps) {
  return (
    <button
      onClick={onChange}
      className={`w-12 h-6 rounded-full transition-all relative`}
      style={{ backgroundColor: enabled ? "#051DDA" : "#E5E7EB" }}
    >
      <div
        className="w-5 h-5 bg-white rounded-full shadow absolute top-0.5 transition-all"
        style={{ left: enabled ? "1.375rem" : "0.125rem" }}
      />
    </button>
  );
}

export function SettingsPage() {
  const navigate = useNavigate();
  const { profile, logout } = useUser();

  const [notifications, setNotifications] = useState({
    matches: true,
    applications: true,
    reminders: false,
    news: true,
  });

  const [privacy, setPrivacy] = useState({
    profileVisible: true,
    shareData: false,
  });

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  return (
    <div className="min-h-screen pb-10" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-5"
        style={{ background: "linear-gradient(135deg, #051DDA 0%, #1539F0 100%)" }}
      >
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate(-1)}
            className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center"
          >
            <ArrowLeft size={18} className="text-white" />
          </button>
          <h1 className="text-xl font-bold text-white">Settings</h1>
        </div>
      </div>

      <div className="px-5 pt-5 space-y-4">
        {/* Account */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50">
            <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">Account</p>
          </div>
          <div className="flex items-center gap-3 px-4 py-3.5 border-b border-gray-50">
            <div
              className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold"
              style={{ backgroundColor: profile.avatarColor || "#5B4FCF" }}
            >
              {profile.fullName?.[0]?.toUpperCase() || profile.email[0].toUpperCase()}
            </div>
            <div className="flex-1">
              <p className="text-sm font-semibold text-gray-900">{profile.fullName || "No name set"}</p>
              <p className="text-xs text-gray-400">{profile.email}</p>
            </div>
            <button onClick={() => navigate("/profile/edit")} className="text-xs font-semibold" style={{ color: "#051DDA" }}>
              Edit
            </button>
          </div>
          <button
            onClick={() => navigate("/profile/edit")}
            className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-gray-50"
          >
            <Globe size={16} className="text-gray-500" />
            <span className="text-sm text-gray-700 flex-1">Edit Profile</span>
            <ChevronRight size={14} className="text-gray-400" />
          </button>
        </div>

        {/* Notifications */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50 flex items-center gap-2">
            <Bell size={14} style={{ color: "#051DDA" }} />
            <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">Notifications</p>
          </div>
          {[
            { key: "matches" as const, label: "New match alerts", desc: "When we find a new internship for you" },
            { key: "applications" as const, label: "Application updates", desc: "Status changes on your applications" },
            { key: "reminders" as const, label: "Profile reminders", desc: "Reminders to complete your profile" },
            { key: "news" as const, label: "Industry news", desc: "Latest internship season updates" },
          ].map(({ key, label, desc }) => (
            <div key={key} className="flex items-center gap-3 px-4 py-3.5 border-b border-gray-50 last:border-0">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-800">{label}</p>
                <p className="text-xs text-gray-400">{desc}</p>
              </div>
              <Toggle
                enabled={notifications[key]}
                onChange={() => setNotifications((prev) => ({ ...prev, [key]: !prev[key] }))}
              />
            </div>
          ))}
        </div>

        {/* Privacy */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50 flex items-center gap-2">
            <Shield size={14} style={{ color: "#051DDA" }} />
            <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">Privacy</p>
          </div>
          {[
            { key: "profileVisible" as const, label: "Profile visibility", desc: "Allow companies to view your profile" },
            { key: "shareData" as const, label: "Data sharing", desc: "Share anonymized data to improve AI" },
          ].map(({ key, label, desc }) => (
            <div key={key} className="flex items-center gap-3 px-4 py-3.5 border-b border-gray-50 last:border-0">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-800">{label}</p>
                <p className="text-xs text-gray-400">{desc}</p>
              </div>
              <Toggle
                enabled={privacy[key]}
                onChange={() => setPrivacy((prev) => ({ ...prev, [key]: !prev[key] }))}
              />
            </div>
          ))}
        </div>

        {/* About */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50">
            <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">About</p>
          </div>
          {[
            { label: "Version", value: "1.0.0" },
            { label: "Terms of Service", value: "" },
            { label: "Privacy Policy", value: "" },
            { label: "Help & Support", value: "" },
          ].map(({ label, value }) => (
            <button
              key={label}
              className="w-full flex items-center justify-between px-4 py-3.5 border-b border-gray-50 last:border-0 hover:bg-gray-50"
            >
              <span className="text-sm text-gray-700">{label}</span>
              {value ? (
                <span className="text-xs text-gray-400">{value}</span>
              ) : (
                <ChevronRight size={14} className="text-gray-400" />
              )}
            </button>
          ))}
        </div>

        {/* Danger zone */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-50">
            <p className="text-xs font-bold text-red-400 uppercase tracking-wide">Danger Zone</p>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3.5 border-b border-gray-50 hover:bg-gray-50"
          >
            <LogOut size={16} className="text-red-500" />
            <span className="text-sm text-red-500 font-medium flex-1 text-left">Sign Out</span>
          </button>
          <button className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-gray-50">
            <Trash2 size={16} className="text-red-500" />
            <span className="text-sm text-red-500 font-medium flex-1 text-left">Delete Account</span>
          </button>
        </div>

        <p className="text-center text-xs text-gray-400 py-4">
          InterMatch · Made with ❤️ for students
        </p>
      </div>
    </div>
  );
}