import { useState } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, SelectChip, ContinueButton } from "../components/OnboardingLayout";
import { Plus, X } from "lucide-react";

const PRIMARY = "#051DDA";

const skillOptions = [
  "Flutter", "Java", "Python", "React", "JavaScript", "C/C++", "SQL", "Node.js/Express",
  "TypeScript", "Kotlin", "Swift", "PHP", "Ruby", "Go", "Rust", "MATLAB",
];

const toolOptions = [
  "Git/Github", "Docker", "AWS", "Linux", "Kubernetes", "Jenkins", "Figma", "Postman",
];

export function SkillsPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();
  const [customSkill, setCustomSkill] = useState("");
  const [customTool, setCustomTool] = useState("");

  const toggleSkill = (skill: string) => {
    const current = profile.skills;
    if (current.includes(skill)) {
      updateProfile({ skills: current.filter((s) => s !== skill) });
    } else {
      updateProfile({ skills: [...current, skill] });
    }
  };

  const toggleTool = (tool: string) => {
    const current = profile.tools;
    if (current.includes(tool)) {
      updateProfile({ tools: current.filter((t) => t !== tool) });
    } else {
      updateProfile({ tools: [...current, tool] });
    }
  };

  const addCustomSkill = () => {
    const trimmed = customSkill.trim();
    if (trimmed && !profile.skills.includes(trimmed)) {
      updateProfile({ skills: [...profile.skills, trimmed] });
      setCustomSkill("");
    }
  };

  const addCustomTool = () => {
    const trimmed = customTool.trim();
    if (trimmed && !profile.tools.includes(trimmed)) {
      updateProfile({ tools: [...profile.tools, trimmed] });
      setCustomTool("");
    }
  };

  const removeSkill = (skill: string) => {
    updateProfile({ skills: profile.skills.filter((s) => s !== skill) });
  };

  const removeTool = (tool: string) => {
    updateProfile({ tools: profile.tools.filter((t) => t !== tool) });
  };

  const customSkills = profile.skills.filter((s) => !skillOptions.includes(s));
  const customTools = profile.tools.filter((t) => !toolOptions.includes(t));

  return (
    <OnboardingLayout currentStep={6} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: PRIMARY }}>
            Step 6 · Skills
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Your Skills & Tools</h1>
        <p className="text-sm text-gray-500 mb-6">
          Select skills and tools you're comfortable with. This is the key to accurate matching.
        </p>

        {/* Selected count */}
        {(profile.skills.length > 0 || profile.tools.length > 0) && (
          <div className="flex gap-2 mb-5">
            {profile.skills.length > 0 && (
              <div
                className="px-3 py-1 rounded-full"
                style={{ backgroundColor: "#EBF0FF" }}
              >
                <span className="text-xs font-semibold" style={{ color: PRIMARY }}>
                  {profile.skills.length} skills selected
                </span>
              </div>
            )}
            {profile.tools.length > 0 && (
              <div
                className="px-3 py-1 rounded-full"
                style={{ backgroundColor: "#E8F5EC" }}
              >
                <span className="text-xs font-semibold" style={{ color: "#198038" }}>
                  {profile.tools.length} tools selected
                </span>
              </div>
            )}
          </div>
        )}

        {/* Skills Section */}
        <div className="mb-8">
          <h2 className="text-sm font-bold text-gray-800 mb-3">Programming Languages & Frameworks</h2>
          <div className="flex flex-wrap gap-2 mb-3">
            {skillOptions.map((skill) => (
              <SelectChip
                key={skill}
                label={skill}
                selected={profile.skills.includes(skill)}
                onClick={() => toggleSkill(skill)}
              />
            ))}
          </div>

          {/* Custom skills */}
          {customSkills.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-3">
              {customSkills.map((skill) => (
                <div
                  key={skill}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium text-white"
                  style={{ backgroundColor: PRIMARY }}
                >
                  {skill}
                  <button onClick={() => removeSkill(skill)}>
                    <X size={12} />
                  </button>
                </div>
              ))}
            </div>
          )}

          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Add custom skill..."
              value={customSkill}
              onChange={(e) => setCustomSkill(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addCustomSkill()}
              className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
              style={{ fontFamily: "'Poppins', sans-serif" }}
              onFocus={(e) => { e.target.style.borderColor = PRIMARY; }}
              onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
            />
            <button
              onClick={addCustomSkill}
              className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
              style={{ backgroundColor: PRIMARY }}
            >
              <Plus size={18} />
            </button>
          </div>
        </div>

        {/* Tools Section */}
        <div className="mb-10">
          <h2 className="text-sm font-bold text-gray-800 mb-3">Tools & Platforms</h2>
          <div className="flex flex-wrap gap-2 mb-3">
            {toolOptions.map((tool) => (
              <SelectChip
                key={tool}
                label={tool}
                selected={profile.tools.includes(tool)}
                onClick={() => toggleTool(tool)}
              />
            ))}
          </div>

          {customTools.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-3">
              {customTools.map((tool) => (
                <div
                  key={tool}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium text-white"
                  style={{ backgroundColor: "#198038" }}
                >
                  {tool}
                  <button onClick={() => removeTool(tool)}>
                    <X size={12} />
                  </button>
                </div>
              ))}
            </div>
          )}

          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Add custom tool..."
              value={customTool}
              onChange={(e) => setCustomTool(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addCustomTool()}
              className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
              style={{ fontFamily: "'Poppins', sans-serif" }}
              onFocus={(e) => { e.target.style.borderColor = "#198038"; }}
              onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
            />
            <button
              onClick={addCustomTool}
              className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
              style={{ backgroundColor: "#198038" }}
            >
              <Plus size={18} />
            </button>
          </div>
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/interests")}
          disabled={profile.skills.length === 0}
          label={profile.skills.length === 0 ? "Select at least 1 skill" : "Continue"}
        />
      </div>
    </OnboardingLayout>
  );
}
