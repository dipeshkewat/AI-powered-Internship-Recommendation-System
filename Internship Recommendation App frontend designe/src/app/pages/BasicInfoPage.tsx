import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, ContinueButton } from "../components/OnboardingLayout";
import { User, Phone, Mail } from "lucide-react";

const PRIMARY = "#051DDA";

export function BasicInfoPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  const isValid = profile.fullName.trim().length >= 2 && profile.phoneNo.trim().length >= 10;

  const inputStyle = {
    fontFamily: "'Poppins', sans-serif",
  };

  const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
    e.target.style.borderColor = PRIMARY;
    e.target.style.backgroundColor = "white";
  };
  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    e.target.style.borderColor = "#F3F4F6";
    e.target.style.backgroundColor = "#F9FAFB";
  };

  return (
    <OnboardingLayout currentStep={4} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: PRIMARY }}>
            Step 4 · Basic Info
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Basic Information</h1>
        <p className="text-sm text-gray-500 mb-8">
          Let us know who you are so we can personalize your profile.
        </p>

        <div className="space-y-5 mb-10">
          {/* Full Name */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
              Full Name
            </label>
            <div className="relative">
              <User size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="e.g., Priya Sharma"
                value={profile.fullName}
                onChange={(e) => updateProfile({ fullName: e.target.value })}
                className="w-full pl-11 pr-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                style={inputStyle}
                onFocus={handleFocus}
                onBlur={handleBlur}
              />
            </div>
          </div>

          {/* Phone */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
              Phone Number
            </label>
            <div className="relative">
              <Phone size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="tel"
                placeholder="10-digit mobile number"
                value={profile.phoneNo}
                onChange={(e) => updateProfile({ phoneNo: e.target.value.replace(/\D/g, "").slice(0, 10) })}
                className="w-full pl-11 pr-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                style={inputStyle}
                onFocus={handleFocus}
                onBlur={handleBlur}
              />
            </div>
          </div>

          {/* Email display */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
              Email Address
            </label>
            <div className="flex items-center gap-3 px-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-100">
              <Mail size={16} className="text-gray-400 shrink-0" />
              <p className="text-sm text-gray-600">{profile.email}</p>
            </div>
          </div>
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/academic")}
          disabled={!isValid}
        />
      </div>
    </OnboardingLayout>
  );
}
