import { useState } from "react";
import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, ContinueButton } from "../components/OnboardingLayout";
import { Globe, Smartphone, BarChart2, Brain, Shield, Plus, X, CheckCircle } from "lucide-react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

const interestOptions = [
  { label: "Web Dev", icon: Globe, color: PRIMARY, bg: "#EBF0FF" },
  { label: "App Dev", icon: Smartphone, color: "#7C3AED", bg: "#F5F3FF" },
  { label: "Data Science", icon: BarChart2, color: "#0284C7", bg: "#E0F2FE" },
  { label: "AI/ML", icon: Brain, color: TERTIARY, bg: "#E8F5EC" },
  { label: "Cybersecurity", icon: Shield, color: "#DC2626", bg: "#FEE2E2" },
  { label: "Cloud Computing", icon: Globe, color: "#D97706", bg: "#FEF3C7" },
  { label: "DevOps", icon: Globe, color: "#0F766E", bg: "#CCFBF1" },
  { label: "Blockchain", icon: Globe, color: "#7C3AED", bg: "#F5F3FF" },
];

export function InterestsPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();
  const [customInterest, setCustomInterest] = useState("");

  const toggleInterest = (interest: string) => {
    const current = profile.interests;
    if (current.includes(interest)) {
      updateProfile({ interests: current.filter((i) => i !== interest) });
    } else {
      updateProfile({ interests: [...current, interest] });
    }
  };

  const addCustom = () => {
    const trimmed = customInterest.trim();
    if (trimmed && !profile.interests.includes(trimmed)) {
      updateProfile({ interests: [...profile.interests, trimmed] });
      setCustomInterest("");
    }
  };

  const customInterests = profile.interests.filter(
    (i) => !interestOptions.map((o) => o.label).includes(i)
  );

  return (
    <OnboardingLayout currentStep={7} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: PRIMARY }}>
            Step 7 · Interests
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Your Interests</h1>
        <p className="text-sm text-gray-500 mb-6">
          Choose the domains you're passionate about. Select multiple!
        </p>

        {profile.interests.length > 0 && (
          <div
            className="mb-4 px-3.5 py-2.5 rounded-xl flex items-center gap-2"
            style={{ backgroundColor: "#EBF0FF" }}
          >
            <CheckCircle size={14} style={{ color: PRIMARY }} />
            <span className="text-xs font-semibold" style={{ color: PRIMARY }}>
              {profile.interests.length} selected: {profile.interests.join(", ")}
            </span>
          </div>
        )}

        {/* Interest grid */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          {interestOptions.map(({ label, icon: Icon, color, bg }) => {
            const selected = profile.interests.includes(label);
            return (
              <button
                key={label}
                onClick={() => toggleInterest(label)}
                className="p-4 rounded-2xl border-2 text-left transition-all active:scale-95"
                style={{
                  borderColor: selected ? color : "#E5E7EB",
                  backgroundColor: selected ? bg : "white",
                  boxShadow: selected ? `0 2px 8px ${color}20` : undefined,
                }}
              >
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center mb-3"
                  style={{ backgroundColor: selected ? color : "#F3F4F6" }}
                >
                  <Icon size={18} style={{ color: selected ? "white" : "#9CA3AF" }} />
                </div>
                <p
                  className="text-sm font-semibold"
                  style={{ color: selected ? color : "#374151" }}
                >
                  {label}
                </p>
                {selected && (
                  <div className="mt-1.5 flex items-center gap-1">
                    <CheckCircle size={11} style={{ color }} />
                    <span className="text-xs font-medium" style={{ color }}>Selected</span>
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Custom interests */}
        {customInterests.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-4">
            {customInterests.map((interest) => (
              <div
                key={interest}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium text-white"
                style={{ backgroundColor: PRIMARY }}
              >
                {interest}
                <button onClick={() => toggleInterest(interest)}>
                  <X size={12} />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Custom input */}
        <div className="flex gap-2 mb-10">
          <input
            type="text"
            placeholder="Add another interest..."
            value={customInterest}
            onChange={(e) => setCustomInterest(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && addCustom()}
            className="flex-1 px-4 py-2.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
            style={{ fontFamily: "'Poppins', sans-serif" }}
            onFocus={(e) => { e.target.style.borderColor = PRIMARY; }}
            onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; }}
          />
          <button
            onClick={addCustom}
            className="w-10 h-10 rounded-xl flex items-center justify-center text-white"
            style={{ backgroundColor: PRIMARY }}
          >
            <Plus size={18} />
          </button>
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/preferences")}
          disabled={profile.interests.length === 0}
          label={profile.interests.length === 0 ? "Select at least 1 interest" : "Continue"}
        />
      </div>
    </OnboardingLayout>
  );
}
