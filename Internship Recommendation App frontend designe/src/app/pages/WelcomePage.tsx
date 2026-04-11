import { useNavigate } from "react-router";
import { Briefcase, Sparkles, Target, TrendingUp, Zap } from "lucide-react";
import { motion } from "motion/react";
import { useEffect } from "react";
import { useUser } from "../context/UserContext";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function WelcomePage() {
  const navigate = useNavigate();
  const { profile } = useUser();

  useEffect(() => {
    if (profile.isAuthenticated) {
      navigate(profile.onboardingComplete ? "/dashboard" : "/onboarding/education");
    }
  }, [profile.isAuthenticated]);

  const features = [
    { icon: Target, label: "AI-Powered Matching", desc: "ML-based recommendations" },
    { icon: TrendingUp, label: "Career Growth", desc: "Track your applications" },
    { icon: Sparkles, label: "Smart Picks", desc: "Personalized for you" },
  ];

  return (
    <div
      className="min-h-screen flex flex-col relative overflow-hidden"
      style={{
        fontFamily: "'Poppins', sans-serif",
        background: `linear-gradient(160deg, ${PRIMARY} 0%, #0A2FE8 60%, #1539F0 100%)`,
      }}
    >
      {/* Decorative blobs */}
      <div
        className="absolute top-0 right-0 w-80 h-80 rounded-full opacity-10 bg-white"
        style={{ transform: "translate(35%, -35%)" }}
      />
      <div
        className="absolute bottom-1/3 left-0 w-48 h-48 rounded-full opacity-8"
        style={{ transform: "translateX(-50%)", backgroundColor: TERTIARY }}
      />
      <div
        className="absolute top-1/4 right-0 w-24 h-24 rounded-full opacity-15 bg-white"
        style={{ transform: "translateX(50%)" }}
      />

      {/* Main content */}
      <div className="flex-1 flex flex-col items-center justify-center px-8 text-center relative pt-16">
        {/* Logo */}
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.6, type: "spring" }}
          className="mb-8"
        >
          <div className="relative mx-auto w-24 h-24">
            <div className="w-24 h-24 bg-white rounded-3xl flex items-center justify-center shadow-2xl mx-auto">
              <Briefcase size={38} style={{ color: PRIMARY }} />
            </div>
            <div
              className="absolute -top-2 -right-2 w-8 h-8 rounded-xl flex items-center justify-center shadow-lg"
              style={{ backgroundColor: TERTIARY }}
            >
              <Sparkles size={14} className="text-white" />
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
        >
          <h1 className="text-5xl font-bold text-white mb-2 tracking-tight">
            Inter<span style={{ color: "#7DF5A0" }}>Match</span>
          </h1>
          <p className="text-blue-200 text-base mb-10">
            Find internships tailored just for you
          </p>
        </motion.div>

        {/* Feature cards */}
        <motion.div
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5, duration: 0.5 }}
          className="w-full max-w-xs space-y-3 mb-10"
        >
          {features.map(({ icon: Icon, label, desc }, i) => (
            <motion.div
              key={label}
              initial={{ x: -20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.5 + i * 0.1 }}
              className="flex items-center gap-4 px-5 py-3.5 rounded-2xl text-left"
              style={{ backgroundColor: "rgba(255,255,255,0.12)", backdropFilter: "blur(10px)", border: "1px solid rgba(255,255,255,0.15)" }}
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: "rgba(255,255,255,0.2)" }}
              >
                <Icon size={18} className="text-white" />
              </div>
              <div>
                <p className="text-white text-sm font-semibold">{label}</p>
                <p className="text-blue-200 text-xs">{desc}</p>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Stats */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.5 }}
          className="grid grid-cols-3 gap-4 mb-8 w-full max-w-xs"
        >
          {[
            { value: "2000+", label: "Internships" },
            { value: "500+", label: "Companies" },
            { value: "95%", label: "Match Rate" },
          ].map(({ value, label }) => (
            <div key={label} className="text-center">
              <p className="text-2xl font-bold text-white">{value}</p>
              <p className="text-xs text-blue-200">{label}</p>
            </div>
          ))}
        </motion.div>
      </div>

      {/* Bottom section */}
      <motion.div
        initial={{ y: 60, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6, duration: 0.5 }}
        className="px-6 pb-12 pt-8"
        style={{
          borderRadius: "40px 40px 0 0",
          background: "rgba(255,255,255,0.1)",
          backdropFilter: "blur(20px)",
          border: "1px solid rgba(255,255,255,0.15)",
        }}
      >
        <div className="flex items-center justify-center gap-2 mb-5">
          <div className="w-2 h-2 rounded-full" style={{ backgroundColor: TERTIARY }} />
          <p className="text-center text-blue-100 text-sm">
            Join <span className="text-white font-bold">50,000+</span> students already matched
          </p>
        </div>

        <button
          onClick={() => navigate("/auth?mode=register")}
          className="w-full py-4 rounded-2xl text-sm font-bold mb-3 shadow-xl transition-all active:scale-[0.98]"
          style={{ backgroundColor: "white", color: PRIMARY }}
        >
          Get Started — It's Free
        </button>
        <button
          onClick={() => navigate("/auth?mode=login")}
          className="w-full py-4 rounded-2xl text-sm font-semibold transition-all active:scale-[0.98]"
          style={{ border: "2px solid rgba(255,255,255,0.4)", color: "white" }}
        >
          I already have an account
        </button>
        <p className="text-center text-blue-300 text-xs mt-4">
          Demo: demo@intermatch.ai / demo123
        </p>
      </motion.div>
    </div>
  );
}
