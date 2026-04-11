import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, ContinueButton } from "../components/OnboardingLayout";
import { Wifi, Building2, Clock, Briefcase, Sparkles, CheckCircle } from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function PreferencesPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  const isValid = !!profile.preferredLocation && !!profile.internshipType && !!profile.duration;

  const handleFinish = () => {
    updateProfile({ onboardingComplete: true });
    navigate("/dashboard");
  };

  const PrefCard = ({
    value,
    selected,
    icon,
    label,
    desc,
    onClick,
  }: {
    value: string;
    selected: boolean;
    icon: React.ReactNode;
    label: string;
    desc: string;
    onClick: () => void;
  }) => (
    <button
      onClick={onClick}
      className="p-4 rounded-2xl border-2 text-left transition-all active:scale-95"
      style={{
        borderColor: selected ? PRIMARY : "#E5E7EB",
        backgroundColor: selected ? "#EBF0FF" : "white",
        boxShadow: selected ? "0 2px 12px rgba(5,29,218,0.12)" : undefined,
      }}
    >
      <div
        className="w-10 h-10 rounded-xl flex items-center justify-center mb-2.5"
        style={{
          backgroundColor: selected ? PRIMARY : "#F3F4F6",
          color: selected ? "white" : "#9CA3AF",
        }}
      >
        {icon}
      </div>
      <p
        className="text-sm font-semibold"
        style={{ color: selected ? PRIMARY : "#374151" }}
      >
        {label}
      </p>
      <p className="text-xs text-gray-400 mt-0.5">{desc}</p>
      {selected && (
        <div className="mt-2 flex items-center gap-1">
          <CheckCircle size={11} style={{ color: PRIMARY }} />
          <span className="text-xs font-medium" style={{ color: PRIMARY }}>Selected</span>
        </div>
      )}
    </button>
  );

  return (
    <OnboardingLayout currentStep={8} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <div className="flex items-center gap-2">
            <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: PRIMARY }}>
              Step 8
            </span>
            <span
              className="text-xs font-bold px-2 py-0.5 rounded-full"
              style={{ backgroundColor: "#E8F5EC", color: TERTIARY }}
            >
              Final Step!
            </span>
          </div>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Internship Preferences</h1>
        <p className="text-sm text-gray-500 mb-8">
          Tell us your preferences and we'll find the perfect match!
        </p>

        {/* Preferred Location */}
        <div className="mb-6">
          <h3 className="text-sm font-bold text-gray-700 mb-3">Preferred Work Location</h3>
          <div className="grid grid-cols-2 gap-3">
            <PrefCard
              value="Remote"
              selected={profile.preferredLocation === "Remote"}
              icon={<Wifi size={20} />}
              label="Remote"
              desc="Work from anywhere"
              onClick={() => updateProfile({ preferredLocation: "Remote" })}
            />
            <PrefCard
              value="On-site"
              selected={profile.preferredLocation === "On-site"}
              icon={<Building2 size={20} />}
              label="On-site"
              desc="Office-based work"
              onClick={() => updateProfile({ preferredLocation: "On-site" })}
            />
          </div>
        </div>

        {/* Internship Type */}
        <div className="mb-6">
          <h3 className="text-sm font-bold text-gray-700 mb-3">Internship Type</h3>
          <div className="grid grid-cols-2 gap-3">
            <PrefCard
              value="Full-time"
              selected={profile.internshipType === "Full-time"}
              icon={<Briefcase size={20} />}
              label="Full-time"
              desc="5 days a week"
              onClick={() => updateProfile({ internshipType: "Full-time" })}
            />
            <PrefCard
              value="Part-time"
              selected={profile.internshipType === "Part-time"}
              icon={<Briefcase size={20} />}
              label="Part-time"
              desc="Flexible hours"
              onClick={() => updateProfile({ internshipType: "Part-time" })}
            />
          </div>
        </div>

        {/* Duration */}
        <div className="mb-8">
          <h3 className="text-sm font-bold text-gray-700 mb-3">Preferred Duration</h3>
          <div className="grid grid-cols-3 gap-3">
            {(["1 month", "3 months", "6 months"] as const).map((d) => (
              <button
                key={d}
                onClick={() => updateProfile({ duration: d })}
                className="p-3 rounded-2xl border-2 text-center transition-all active:scale-95"
                style={{
                  borderColor: profile.duration === d ? PRIMARY : "#E5E7EB",
                  backgroundColor: profile.duration === d ? "#EBF0FF" : "white",
                }}
              >
                <Clock
                  size={18}
                  className="mx-auto mb-1.5"
                  style={{ color: profile.duration === d ? PRIMARY : "#9CA3AF" }}
                />
                <p
                  className="text-xs font-semibold"
                  style={{ color: profile.duration === d ? PRIMARY : "#374151" }}
                >
                  {d}
                </p>
              </button>
            ))}
          </div>
        </div>

        {isValid && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-5 p-4 rounded-2xl border"
            style={{ background: "linear-gradient(135deg, #EBF0FF, #E8F5EC)", borderColor: "#C7D3FF" }}
          >
            <div className="flex items-center gap-2 mb-1.5">
              <Sparkles size={14} style={{ color: PRIMARY }} />
              <span className="text-xs font-bold" style={{ color: PRIMARY }}>Profile Ready!</span>
            </div>
            <p className="text-xs text-gray-600">
              Your profile is complete! We'll match you with <strong>{profile.preferredLocation?.toLowerCase()}</strong>, <strong>{profile.internshipType?.toLowerCase()}</strong> internships for <strong>{profile.duration}</strong>.
            </p>
          </motion.div>
        )}

        <ContinueButton
          onClick={handleFinish}
          disabled={!isValid}
          label={isValid ? "🎉 Find My Internships!" : "Fill all fields to continue"}
        />
      </div>
    </OnboardingLayout>
  );
}
