import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, OptionCard, ContinueButton } from "../components/OnboardingLayout";
import { CheckCircle, XCircle } from "lucide-react";

export function PastInternshipPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  return (
    <OnboardingLayout currentStep={3} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: "#051DDA" }}>
            Step 3 · Past Experience
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Any past internship?</h1>
        <p className="text-sm text-gray-500 mb-8">
          Tell us about your previous experience — it helps us understand your strengths.
        </p>

        <div className="space-y-3 mb-6">
          <OptionCard
            selected={profile.hasDoneInternship === true}
            onClick={() => updateProfile({ hasDoneInternship: true })}
            icon={<CheckCircle size={22} />}
            label="Yes, I have"
            description="I've completed at least one internship"
          />
          <OptionCard
            selected={profile.hasDoneInternship === false}
            onClick={() => updateProfile({ hasDoneInternship: false, internshipDescription: "" })}
            icon={<XCircle size={22} />}
            label="No, not yet"
            description="This will be my first internship"
          />
        </div>

        {profile.hasDoneInternship === true && (
          <div className="mb-6">
            <label className="text-sm font-semibold text-gray-700 block mb-2">
              Describe your past internship experience
            </label>
            <textarea
              placeholder="e.g., I worked as a frontend developer intern at XYZ startup for 2 months, built React components and integrated APIs..."
              value={profile.internshipDescription}
              onChange={(e) => updateProfile({ internshipDescription: e.target.value })}
              rows={5}
              className="w-full px-4 py-3 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all resize-none"
              style={{ fontFamily: "'Poppins', sans-serif" }}
              onFocus={(e) => { e.target.style.borderColor = "#051DDA"; e.target.style.backgroundColor = "white"; }}
              onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; e.target.style.backgroundColor = "#F9FAFB"; }}
            />
          </div>
        )}

        <ContinueButton
          onClick={() => navigate("/onboarding/basic-info")}
          disabled={
            profile.hasDoneInternship === null ||
            (profile.hasDoneInternship === true && !profile.internshipDescription.trim())
          }
        />
      </div>
    </OnboardingLayout>
  );
}