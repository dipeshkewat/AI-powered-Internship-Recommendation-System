import { useNavigate } from "react-router";
import { Zap, Award } from "lucide-react";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, OptionCard, ContinueButton } from "../components/OnboardingLayout";

export function ExperienceLevelPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  const options = [
    {
      value: "Fresher" as const,
      label: "Fresher",
      description: "No prior internship or work experience",
      icon: <Zap size={22} />,
    },
    {
      value: "Intermediate" as const,
      label: "Intermediate",
      description: "Have done at least one internship before",
      icon: <Award size={22} />,
    },
  ];

  return (
    <OnboardingLayout currentStep={2} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: "#051DDA" }}>
            Step 2 · Experience
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Your experience level?</h1>
        <p className="text-sm text-gray-500 mb-8">
          We'll tailor recommendations to your current experience level.
        </p>

        <div className="space-y-3 mb-10">
          {options.map((opt) => (
            <OptionCard
              key={opt.value}
              selected={profile.experienceLevel === opt.value}
              onClick={() => updateProfile({ experienceLevel: opt.value })}
              icon={opt.icon}
              label={opt.label}
              description={opt.description}
            />
          ))}
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/past-internship")}
          disabled={!profile.experienceLevel}
        />
      </div>
    </OnboardingLayout>
  );
}