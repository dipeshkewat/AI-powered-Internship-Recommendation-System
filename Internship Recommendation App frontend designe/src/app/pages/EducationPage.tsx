import { useNavigate } from "react-router";
import { GraduationCap, BookOpen } from "lucide-react";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, OptionCard, ContinueButton } from "../components/OnboardingLayout";

export function EducationPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  const options = [
    {
      value: "Undergraduate" as const,
      label: "Undergraduate",
      description: "Currently pursuing B.Tech, BCA, BSc or similar",
      icon: <BookOpen size={22} />,
    },
    {
      value: "Graduate" as const,
      label: "Graduate / Postgraduate",
      description: "Pursuing M.Tech, MBA, MCA or similar",
      icon: <GraduationCap size={22} />,
    },
  ];

  return (
    <OnboardingLayout currentStep={1} totalSteps={8} showBack={false}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: "#051DDA" }}>
            Step 1 · Education
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">What's your education level?</h1>
        <p className="text-sm text-gray-500 mb-8">
          This helps us recommend internships that match your academic stage.
        </p>

        <div className="space-y-3 mb-10">
          {options.map((opt) => (
            <OptionCard
              key={opt.value}
              selected={profile.educationLevel === opt.value}
              onClick={() => updateProfile({ educationLevel: opt.value })}
              icon={opt.icon}
              label={opt.label}
              description={opt.description}
            />
          ))}
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/experience")}
          disabled={!profile.educationLevel}
        />
      </div>
    </OnboardingLayout>
  );
}
