import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { OnboardingLayout, ContinueButton } from "../components/OnboardingLayout";
import { GraduationCap } from "lucide-react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

const degrees = ["BSc", "B.Tech", "B.E", "BCA", "MCA", "M.Tech", "MBA", "Other"];
const engineeringDegrees = ["B.Tech", "B.E"];
const branches = ["Computer Science", "Information Technology", "AI/ML", "Electronics", "Mechanical", "Civil"];
const years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "Final Year"];

export function AcademicDetailsPage() {
  const navigate = useNavigate();
  const { profile, updateProfile } = useUser();

  const showBranch = engineeringDegrees.includes(profile.degree);
  const isValid =
    !!profile.degree &&
    (!showBranch || !!profile.branch) &&
    !!profile.currentYear &&
    !!profile.cgpa;

  return (
    <OnboardingLayout currentStep={5} totalSteps={8}>
      <div className="px-6 pt-8">
        <div className="mb-2">
          <span className="text-xs font-semibold uppercase tracking-widest" style={{ color: PRIMARY }}>
            Step 5 · Academics
          </span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Academic Details</h1>
        <p className="text-sm text-gray-500 mb-8">
          Your academic background helps us find the most relevant opportunities.
        </p>

        <div className="space-y-6 mb-10">
          {/* Degree */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-3">
              Degree
            </label>
            <div className="flex flex-wrap gap-2">
              {degrees.map((d) => (
                <button
                  key={d}
                  onClick={() => updateProfile({ degree: d, branch: engineeringDegrees.includes(d) ? profile.branch : "" })}
                  className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                  style={
                    profile.degree === d
                      ? { borderColor: PRIMARY, backgroundColor: PRIMARY, color: "white" }
                      : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                  }
                >
                  {d}
                </button>
              ))}
            </div>
          </div>

          {/* Branch (conditional) */}
          {showBranch && (
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-3">
                Branch / Specialization
              </label>
              <div className="flex flex-wrap gap-2">
                {branches.map((b) => (
                  <button
                    key={b}
                    onClick={() => updateProfile({ branch: b })}
                    className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                    style={
                      profile.branch === b
                        ? { borderColor: PRIMARY, backgroundColor: PRIMARY, color: "white" }
                        : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                    }
                  >
                    {b}
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Current Year */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-3">
              Current Year
            </label>
            <div className="flex flex-wrap gap-2">
              {years.map((y) => (
                <button
                  key={y}
                  onClick={() => updateProfile({ currentYear: y })}
                  className="px-4 py-2 rounded-full text-sm font-medium border-2 transition-all"
                  style={
                    profile.currentYear === y
                      ? { borderColor: PRIMARY, backgroundColor: PRIMARY, color: "white" }
                      : { borderColor: "#E5E7EB", backgroundColor: "white", color: "#525252" }
                  }
                >
                  {y}
                </button>
              ))}
            </div>
          </div>

          {/* CGPA */}
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
              Current CGPA / Percentage
            </label>
            <div className="relative">
              <GraduationCap size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="number"
                placeholder="e.g., 8.5 (out of 10)"
                value={profile.cgpa}
                onChange={(e) => {
                  const val = e.target.value;
                  if (Number(val) <= 10 || val === "") updateProfile({ cgpa: val });
                }}
                min="0"
                max="10"
                step="0.1"
                className="w-full pl-11 pr-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                style={{ fontFamily: "'Poppins', sans-serif" }}
                onFocus={(e) => { e.target.style.borderColor = PRIMARY; e.target.style.backgroundColor = "white"; }}
                onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; e.target.style.backgroundColor = "#F9FAFB"; }}
              />
            </div>

            {/* CGPA indicator */}
            {profile.cgpa && (
              <div className="mt-3">
                <div className="flex justify-between text-xs text-gray-400 mb-1">
                  <span>0</span>
                  <span
                    className="font-semibold"
                    style={{
                      color: Number(profile.cgpa) >= 8 ? TERTIARY : Number(profile.cgpa) >= 6 ? "#D97706" : "#DC2626",
                    }}
                  >
                    {Number(profile.cgpa) >= 8 ? "Excellent 🎯" : Number(profile.cgpa) >= 6 ? "Good 👍" : "Average"}
                  </span>
                  <span>10</span>
                </div>
                <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all"
                    style={{
                      width: `${(Number(profile.cgpa) / 10) * 100}%`,
                      backgroundColor: Number(profile.cgpa) >= 8 ? TERTIARY : Number(profile.cgpa) >= 6 ? "#D97706" : "#DC2626",
                    }}
                  />
                </div>
              </div>
            )}
          </div>
        </div>

        <ContinueButton
          onClick={() => navigate("/onboarding/skills")}
          disabled={!isValid}
        />
      </div>
    </OnboardingLayout>
  );
}
