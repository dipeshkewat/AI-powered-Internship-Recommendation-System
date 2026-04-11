import { useState } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { ArrowLeft, Check, Plus, X } from "lucide-react";

const skillOptions = ["Flutter", "Java", "Python", "React", "JavaScript", "C/C++", "SQL", "Node.js/Express", "TypeScript", "Kotlin", "Swift"];
const toolOptions = ["Git/Github", "Docker", "AWS", "Linux", "Kubernetes", "Jenkins", "Figma", "Postman"];
const interestOptions = ["Web Dev", "App Dev", "Data Science", "AI/ML", "Cybersecurity", "Cloud Computing", "DevOps", "Blockchain"];
const degrees = ["BSc", "B.Tech", "B.E", "BCA", "MCA", "M.Tech", "MBA", "Other"];
const engineeringDegrees = ["B.Tech", "B.E"];
const branches = ["Computer Science", "Information Technology", "AI/ML", "Electronics", "Mechanical", "Civil"];
const years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "Final Year"];

type Section = "personal" | "academic" | "skills" | "interests" | "preferences";

export function EditProfilePage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();
  const [activeSection, setActiveSection] = useState<Section>("personal");
  const [saved, setSaved] = useState(false);
  const [customSkill, setCustomSkill] = useState("");
  const [customTool, setCustomTool] = useState("");
  const [customInterest, setCustomInterest] = useState("");

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => {
      setSaved(false);
      navigate("/profile");
    }, 1200);
  };

  const toggleItem = (list: string[], item: string, key: "skills" | "tools" | "interests") => {
    const next = list.includes(item) ? list.filter((i) => i !== item) : [...list, item];
    updateProfile({ [key]: next });
  };

  const addCustom = (val: string, list: string[], key: "skills" | "tools" | "interests", setVal: (v: string) => void) => {
    const trimmed = val.trim();
    if (trimmed && !list.includes(trimmed)) {
      updateProfile({ [key]: [...list, trimmed] });
      setVal("");
    }
  };

  const sections: { key: Section; label: string }[] = [
    { key: "personal", label: "Personal" },
    { key: "academic", label: "Academic" },
    { key: "skills", label: "Skills" },
    { key: "interests", label: "Interests" },
    { key: "preferences", label: "Prefs" },
  ];

  return (
    <div className="min-h-screen" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-5 sticky top-0 z-10"
        style={{ background: "linear-gradient(135deg, #051DDA 0%, #1539F0 100%)" }}
      >
        <div className="flex items-center justify-between mb-4">
          <button
            onClick={() => navigate("/profile")}
            className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center"
          >
            <ArrowLeft size={18} className="text-white" />
          </button>
          <h1 className="text-base font-bold text-white">Edit Profile</h1>
          <button
            onClick={handleSave}
            className={`flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              saved ? "bg-green-500 text-white" : "bg-white"
            }`}
            style={saved ? {} : { color: "#051DDA" }}
          >
            {saved ? <><Check size={14} /> Saved!</> : "Save"}
          </button>
        </div>

        {/* Section tabs */}
        <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-1">
          {sections.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setActiveSection(key)}
              className={`px-4 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all ${
                activeSection === key ? "bg-white" : "bg-white/20 text-white"
              }`}
              style={activeSection === key ? { color: "#051DDA" } : {}}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="px-5 pt-5 pb-20">
        {/* Personal Info */}
        {activeSection === "personal" && (
          <div className="space-y-4">
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Full Name</label>
              <input
                type="text"
                value={profile.fullName}
                onChange={(e) => updateProfile({ fullName: e.target.value })}
                className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none transition-all"
                style={{ fontFamily: "'Poppins', sans-serif" }}
                onFocus={(e) => { e.target.style.borderColor = "#051DDA"; }}
                onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
                placeholder="Your full name"
              />
            </div>
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Phone Number</label>
              <input
                type="tel"
                value={profile.phoneNo}
                onChange={(e) => updateProfile({ phoneNo: e.target.value.replace(/\D/g, "").slice(0, 10) })}
                className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none transition-all"
                style={{ fontFamily: "'Poppins', sans-serif" }}
                onFocus={(e) => { e.target.style.borderColor = "#051DDA"; }}
                onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
                placeholder="10-digit number"
              />
            </div>
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Email (read-only)</label>
              <div className="px-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-100 text-sm text-gray-500">
                {profile.email}
              </div>
            </div>
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Experience Level</label>
              <div className="grid grid-cols-2 gap-3">
                {["Fresher", "Intermediate"].map((level) => (
                  <button
                    key={level}
                    onClick={() => updateProfile({ experienceLevel: level as "Fresher" | "Intermediate" })}
                    className={`py-3 rounded-xl border-2 text-sm font-medium transition-all`}
                    style={
                      profile.experienceLevel === level
                        ? { borderColor: "#051DDA", backgroundColor: "#EBF0FF", color: "#051DDA" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {level}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Academic */}
        {activeSection === "academic" && (
          <div className="space-y-5">
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Degree</label>
              <div className="flex flex-wrap gap-2">
                {degrees.map((d) => (
                  <button
                    key={d}
                    onClick={() => updateProfile({ degree: d })}
                    className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                    style={
                      profile.degree === d
                        ? { borderColor: "#051DDA", backgroundColor: "#051DDA", color: "white" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {d}
                  </button>
                ))}
              </div>
            </div>

            {engineeringDegrees.includes(profile.degree) && (
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Branch</label>
                <div className="flex flex-wrap gap-2">
                  {branches.map((b) => (
                    <button
                      key={b}
                      onClick={() => updateProfile({ branch: b })}
                      className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                      style={
                        profile.branch === b
                          ? { borderColor: "#051DDA", backgroundColor: "#051DDA", color: "white" }
                          : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                      }
                    >
                      {b}
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Current Year</label>
              <div className="flex flex-wrap gap-2">
                {years.map((y) => (
                  <button
                    key={y}
                    onClick={() => updateProfile({ currentYear: y })}
                    className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                    style={
                      profile.currentYear === y
                        ? { borderColor: "#051DDA", backgroundColor: "#051DDA", color: "white" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {y}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">CGPA</label>
              <input
                type="number"
                value={profile.cgpa}
                onChange={(e) => updateProfile({ cgpa: e.target.value })}
                min="0" max="10" step="0.1"
                placeholder="e.g., 8.5"
                className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none transition-all"
                style={{ fontFamily: "'Poppins', sans-serif" }}
                onFocus={(e) => { e.target.style.borderColor = "#051DDA"; }}
                onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
              />
            </div>
          </div>
        )}

        {/* Skills */}
        {activeSection === "skills" && (
          <div className="space-y-5">
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Programming Skills</label>
              <div className="flex flex-wrap gap-2 mb-3">
                {skillOptions.map((s) => (
                  <button
                    key={s}
                    onClick={() => toggleItem(profile.skills, s, "skills")}
                    className="px-3 py-1.5 rounded-full text-sm font-medium border-2 transition-all"
                    style={
                      profile.skills.includes(s)
                        ? { borderColor: "#051DDA", backgroundColor: "#051DDA", color: "white" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {s}
                  </button>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Add custom skill..."
                  value={customSkill}
                  onChange={(e) => setCustomSkill(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && addCustom(customSkill, profile.skills, "skills", setCustomSkill)}
                  className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none"
                  style={{ fontFamily: "'Poppins', sans-serif" }}
                  onFocus={(e) => { e.target.style.borderColor = "#051DDA"; }}
                  onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
                />
                <button onClick={() => addCustom(customSkill, profile.skills, "skills", setCustomSkill)}
                  className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
                  style={{ backgroundColor: "#051DDA" }}>
                  <Plus size={18} />
                </button>
              </div>
            </div>

            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Tools & Platforms</label>
              <div className="flex flex-wrap gap-2 mb-3">
                {toolOptions.map((t) => (
                  <button
                    key={t}
                    onClick={() => toggleItem(profile.tools, t, "tools")}
                    className="px-3 py-1.5 rounded-full text-sm font-medium border-2 transition-all"
                    style={
                      profile.tools.includes(t)
                        ? { borderColor: "#198038", backgroundColor: "#198038", color: "white" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {t}
                  </button>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Add custom tool..."
                  value={customTool}
                  onChange={(e) => setCustomTool(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && addCustom(customTool, profile.tools, "tools", setCustomTool)}
                  className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none"
                  style={{ fontFamily: "'Poppins', sans-serif" }}
                  onFocus={(e) => { e.target.style.borderColor = "#198038"; }}
                  onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
                />
                <button onClick={() => addCustom(customTool, profile.tools, "tools", setCustomTool)}
                  className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
                  style={{ backgroundColor: "#198038" }}>
                  <Plus size={18} />
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Interests */}
        {activeSection === "interests" && (
          <div>
            <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-3">Career Interests</label>
            <div className="flex flex-wrap gap-2 mb-4">
              {interestOptions.map((i) => (
                <button
                  key={i}
                  onClick={() => toggleItem(profile.interests, i, "interests")}
                  className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                  style={
                    profile.interests.includes(i)
                      ? { borderColor: "#051DDA", backgroundColor: "#051DDA", color: "white" }
                      : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                  }
                >
                  {i}
                </button>
              ))}
            </div>
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="Add custom interest..."
                value={customInterest}
                onChange={(e) => setCustomInterest(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && addCustom(customInterest, profile.interests, "interests", setCustomInterest)}
                className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-white text-sm focus:outline-none"
                style={{ fontFamily: "'Poppins', sans-serif" }}
                onFocus={(e) => { e.target.style.borderColor = "#051DDA"; }}
                onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
              />
              <button onClick={() => addCustom(customInterest, profile.interests, "interests", setCustomInterest)}
                className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
                style={{ backgroundColor: "#051DDA" }}>
                <Plus size={18} />
              </button>
            </div>
          </div>
        )}

        {/* Preferences */}
        {activeSection === "preferences" && (
          <div className="space-y-5">
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Preferred Location</label>
              <div className="grid grid-cols-2 gap-3">
                {["Remote", "On-site"].map((l) => (
                  <button key={l} onClick={() => updateProfile({ preferredLocation: l as "Remote" | "On-site" })}
                    className={`py-3 rounded-xl border-2 text-sm font-medium transition-all`}
                    style={
                      profile.preferredLocation === l
                        ? { borderColor: "#051DDA", backgroundColor: "#EBF0FF", color: "#051DDA" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }>
                    {l}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Internship Type</label>
              <div className="grid grid-cols-2 gap-3">
                {["Full-time", "Part-time"].map((t) => (
                  <button key={t} onClick={() => updateProfile({ internshipType: t as "Full-time" | "Part-time" })}
                    className={`py-3 rounded-xl border-2 text-sm font-medium transition-all`}
                    style={
                      profile.internshipType === t
                        ? { borderColor: "#051DDA", backgroundColor: "#EBF0FF", color: "#051DDA" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }>
                    {t}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label className="text-xs font-bold text-gray-500 uppercase tracking-wide block mb-2">Duration</label>
              <div className="grid grid-cols-3 gap-3">
                {(["1 month", "3 months", "6 months"] as const).map((d) => (
                  <button key={d} onClick={() => updateProfile({ duration: d })}
                    className={`py-3 rounded-xl border-2 text-sm font-medium transition-all`}
                    style={
                      profile.duration === d
                        ? { borderColor: "#051DDA", backgroundColor: "#EBF0FF", color: "#051DDA" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }>
                    {d}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        <div className="mt-8">
          <button
            onClick={handleSave}
            className="w-full py-4 rounded-2xl text-sm font-bold text-white transition-all"
            style={
              saved
                ? { backgroundColor: "#198038" }
                : { backgroundColor: "#051DDA", boxShadow: "0 8px 24px rgba(5,29,218,0.25)" }
            }
          >
            {saved ? "✓ Profile Saved!" : "Save Changes"}
          </button>
        </div>
      </div>
    </div>
  );
}