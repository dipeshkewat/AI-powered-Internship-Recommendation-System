import { ArrowLeft, Briefcase, Sparkles } from "lucide-react";
import { useNavigate } from "react-router";

const PRIMARY = "#051DDA";

interface OnboardingLayoutProps {
  children: React.ReactNode;
  currentStep: number;
  totalSteps: number;
  onBack?: () => void;
  showBack?: boolean;
}

export function OnboardingLayout({
  children,
  currentStep,
  totalSteps,
  onBack,
  showBack = true,
}: OnboardingLayoutProps) {
  const navigate = useNavigate();

  const handleBack = () => {
    if (onBack) {
      onBack();
    } else {
      navigate(-1);
    }
  };

  const progress = (currentStep / totalSteps) * 100;

  return (
    <div className="min-h-screen flex flex-col" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Progress header */}
      <div className="bg-white px-5 pt-12 pb-4 shadow-sm">
        {/* Logo */}
        <div className="flex items-center gap-2 mb-4">
          <div
            className="w-8 h-8 rounded-xl flex items-center justify-center"
            style={{ backgroundColor: PRIMARY }}
          >
            <Briefcase size={15} className="text-white" />
          </div>
          <span className="font-bold text-sm" style={{ color: PRIMARY }}>
            Inter<span style={{ color: "#198038" }}>Match</span>
          </span>
        </div>

        <div className="flex items-center gap-3">
          {showBack && (
            <button
              onClick={handleBack}
              className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center active:scale-95 transition-transform shrink-0"
            >
              <ArrowLeft size={18} className="text-gray-600" />
            </button>
          )}
          <div className="flex-1">
            <div className="flex justify-between items-center mb-1.5">
              <span className="text-xs text-gray-400 font-medium">
                Step {currentStep} of {totalSteps}
              </span>
              <span className="text-xs font-semibold" style={{ color: PRIMARY }}>
                {Math.round(progress)}%
              </span>
            </div>
            <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{ width: `${progress}%`, backgroundColor: PRIMARY }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Step dots */}
      <div className="flex gap-1.5 justify-center py-3 bg-white border-b border-gray-50">
        {Array.from({ length: totalSteps }).map((_, i) => (
          <div
            key={i}
            className="h-1.5 rounded-full transition-all duration-300"
            style={{
              width: i + 1 === currentStep ? "20px" : "6px",
              backgroundColor: i + 1 <= currentStep ? PRIMARY : "#E5E7EB",
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto pb-8">{children}</div>
    </div>
  );
}

interface OptionCardProps {
  selected: boolean;
  onClick: () => void;
  icon?: React.ReactNode;
  label: string;
  description?: string;
}

export function OptionCard({ selected, onClick, icon, label, description }: OptionCardProps) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center gap-4 p-4 rounded-2xl border-2 transition-all text-left"
      style={{
        borderColor: selected ? PRIMARY : "#E5E7EB",
        backgroundColor: selected ? "#EBF0FF" : "#FFFFFF",
      }}
    >
      {icon && (
        <div
          className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0"
          style={{
            backgroundColor: selected ? PRIMARY : "#F3F4F6",
            color: selected ? "#FFFFFF" : "#6F6F6F",
          }}
        >
          {icon}
        </div>
      )}
      <div className="flex-1">
        <p
          className="text-sm font-semibold"
          style={{ color: selected ? PRIMARY : "#1F2937" }}
        >
          {label}
        </p>
        {description && (
          <p
            className="text-xs mt-0.5"
            style={{ color: selected ? "#3355E0" : "#9CA3AF" }}
          >
            {description}
          </p>
        )}
      </div>
      <div
        className="w-5 h-5 rounded-full border-2 shrink-0 flex items-center justify-center"
        style={{
          borderColor: selected ? PRIMARY : "#D1D5DB",
          backgroundColor: selected ? PRIMARY : "transparent",
        }}
      >
        {selected && (
          <svg viewBox="0 0 12 12" fill="none" className="w-3 h-3">
            <path d="M2 6l3 3 5-5" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </div>
    </button>
  );
}

interface ChipProps {
  selected: boolean;
  onClick: () => void;
  label: string;
  color?: string;
}

export function SelectChip({ selected, onClick, label, color }: ChipProps) {
  return (
    <button
      onClick={onClick}
      className="px-4 py-2 rounded-full text-sm font-medium transition-all border-2 active:scale-95"
      style={
        selected
          ? { borderColor: PRIMARY, backgroundColor: PRIMARY, color: "#FFFFFF" }
          : { borderColor: "#E5E7EB", backgroundColor: "#FFFFFF", color: "#525252" }
      }
    >
      {label}
    </button>
  );
}

interface ContinueButtonProps {
  onClick: () => void;
  label?: string;
  disabled?: boolean;
  loading?: boolean;
}

export function ContinueButton({ onClick, label = "Continue", disabled = false, loading = false }: ContinueButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled || loading}
      className="w-full py-4 rounded-2xl text-sm font-semibold text-white transition-all active:scale-[0.98]"
      style={
        disabled
          ? { backgroundColor: "#D1D5DB", cursor: "not-allowed" }
          : { backgroundColor: PRIMARY, boxShadow: "0 8px 24px rgba(5,29,218,0.25)" }
      }
    >
      {loading ? "Loading..." : label}
    </button>
  );
}
