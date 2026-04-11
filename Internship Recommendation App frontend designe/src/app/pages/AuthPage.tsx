import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { ArrowLeft, Eye, EyeOff, Mail, Lock, Briefcase, Sparkles, CheckCircle } from "lucide-react";
import { useUser } from "../context/UserContext";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

export function AuthPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const initialMode = searchParams.get("mode") === "login" ? "login" : "register";
  const [mode, setMode] = useState<"login" | "register">(initialMode);

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const { login, register } = useUser();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!email || !password) {
      setError("Please fill in all fields.");
      return;
    }

    if (mode === "register" && password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    if (password.length < 6) {
      setError("Password must be at least 6 characters.");
      return;
    }

    setLoading(true);
    await new Promise((r) => setTimeout(r, 800));

    if (mode === "login") {
      const success = login(email, password);
      if (!success) {
        setError("Invalid email or password. Try demo@intermatch.ai / demo123");
        setLoading(false);
        return;
      }
      navigate("/dashboard");
    } else {
      register(email, password);
      navigate("/onboarding/education");
    }
    setLoading(false);
  };

  return (
    <div
      className="min-h-screen flex flex-col"
      style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}
    >
      {/* Header */}
      <div
        className="pt-12 pb-12 px-6 relative overflow-hidden"
        style={{ background: `linear-gradient(145deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        {/* Decorative circles */}
        <div
          className="absolute top-0 right-0 w-48 h-48 rounded-full bg-white opacity-5"
          style={{ transform: "translate(30%, -30%)" }}
        />
        <div
          className="absolute bottom-0 left-0 w-32 h-32 rounded-full bg-white opacity-5"
          style={{ transform: "translate(-30%, 30%)" }}
        />

        <button
          onClick={() => navigate("/")}
          className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center mb-6 relative"
        >
          <ArrowLeft size={18} className="text-white" />
        </button>

        <div className="flex items-center gap-3 mb-5 relative">
          <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-lg">
            <Briefcase size={20} style={{ color: PRIMARY }} />
          </div>
          <span className="text-white font-bold text-lg">
            Inter<span style={{ color: "#7DF5A0" }}>Match</span>
          </span>
        </div>

        <div className="relative">
          <h1 className="text-2xl font-bold text-white mb-1">
            {mode === "login" ? "Welcome back! 👋" : "Create account 🚀"}
          </h1>
          <p className="text-blue-200 text-sm">
            {mode === "login"
              ? "Login to find your perfect internship"
              : "Join 50,000+ students finding great internships"}
          </p>
        </div>
      </div>

      {/* Form card */}
      <div className="flex-1 px-5 -mt-5">
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="bg-white rounded-3xl shadow-xl p-6"
        >
          {/* Tab switcher */}
          <div className="flex rounded-2xl bg-gray-100 p-1 mb-6">
            {(["login", "register"] as const).map((m) => (
              <button
                key={m}
                onClick={() => {
                  setMode(m);
                  setError("");
                }}
                className="flex-1 py-2.5 rounded-xl text-sm font-semibold transition-all"
                style={
                  mode === m
                    ? { backgroundColor: "white", color: PRIMARY, boxShadow: "0 2px 8px rgba(0,0,0,0.1)" }
                    : { color: "#6F6F6F" }
                }
              >
                {m === "login" ? "Login" : "Sign Up"}
              </button>
            ))}
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Email */}
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
                Email Address
              </label>
              <div className="relative">
                <Mail size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
                <input
                  type="email"
                  placeholder="your@email.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-11 pr-4 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                  style={{ fontFamily: "'Poppins', sans-serif" }}
                  onFocus={(e) => { e.target.style.borderColor = PRIMARY; e.target.style.backgroundColor = "white"; }}
                  onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; e.target.style.backgroundColor = "#F9FAFB"; }}
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
                Password
              </label>
              <div className="relative">
                <Lock size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
                <input
                  type={showPassword ? "text" : "password"}
                  placeholder="Min. 6 characters"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-11 pr-12 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                  style={{ fontFamily: "'Poppins', sans-serif" }}
                  onFocus={(e) => { e.target.style.borderColor = PRIMARY; e.target.style.backgroundColor = "white"; }}
                  onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; e.target.style.backgroundColor = "#F9FAFB"; }}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            {/* Confirm Password */}
            {mode === "register" && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
              >
                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wide block mb-2">
                  Confirm Password
                </label>
                <div className="relative">
                  <Lock size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input
                    type={showConfirm ? "text" : "password"}
                    placeholder="Re-enter password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="w-full pl-11 pr-12 py-3.5 rounded-xl border-2 border-gray-100 bg-gray-50 text-sm focus:outline-none transition-all"
                    style={{ fontFamily: "'Poppins', sans-serif" }}
                    onFocus={(e) => { e.target.style.borderColor = PRIMARY; e.target.style.backgroundColor = "white"; }}
                    onBlur={(e) => { e.target.style.borderColor = "#F3F4F6"; e.target.style.backgroundColor = "#F9FAFB"; }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400"
                  >
                    {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </motion.div>
            )}

            {error && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="p-3 rounded-xl bg-red-50 border border-red-100"
              >
                <p className="text-xs text-red-600 font-medium">{error}</p>
              </motion.div>
            )}

            {mode === "login" && (
              <div className="text-right">
                <button type="button" className="text-xs font-medium" style={{ color: PRIMARY }}>
                  Forgot password?
                </button>
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-4 rounded-2xl text-white text-sm font-bold transition-all active:scale-[0.98] disabled:opacity-60 mt-2"
              style={{
                backgroundColor: PRIMARY,
                boxShadow: "0 8px 24px rgba(5,29,218,0.25)",
              }}
            >
              {loading ? (
                <span className="flex items-center justify-center gap-2">
                  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="white" strokeWidth="4" />
                    <path className="opacity-75" fill="white" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  Processing...
                </span>
              ) : mode === "login" ? (
                "Login"
              ) : (
                "Create Account"
              )}
            </button>
          </form>

          {/* Demo credentials */}
          <div
            className="mt-4 p-3.5 rounded-xl border"
            style={{ backgroundColor: "#EBF0FF", borderColor: "#C7D3FF" }}
          >
            <div className="flex items-center gap-2 mb-1">
              <Sparkles size={12} style={{ color: PRIMARY }} />
              <span className="text-xs font-bold" style={{ color: PRIMARY }}>Quick Demo Access</span>
            </div>
            <p className="text-xs" style={{ color: "#3355E0" }}>📧 demo@intermatch.ai</p>
            <p className="text-xs" style={{ color: "#3355E0" }}>🔑 demo123</p>
          </div>

          {/* Perks of signing up */}
          {mode === "register" && (
            <div className="mt-4 space-y-2">
              {["AI-powered internship matching", "Track all your applications", "Get personalized recommendations"].map((perk) => (
                <div key={perk} className="flex items-center gap-2">
                  <CheckCircle size={13} style={{ color: TERTIARY }} />
                  <span className="text-xs text-gray-500">{perk}</span>
                </div>
              ))}
            </div>
          )}

          <p className="text-center text-xs text-gray-400 mt-5">
            By continuing, you agree to our{" "}
            <span className="font-medium" style={{ color: PRIMARY }}>Terms of Service</span> &{" "}
            <span className="font-medium" style={{ color: PRIMARY }}>Privacy Policy</span>
          </p>
        </motion.div>
      </div>
      <div className="h-8" />
    </div>
  );
}
