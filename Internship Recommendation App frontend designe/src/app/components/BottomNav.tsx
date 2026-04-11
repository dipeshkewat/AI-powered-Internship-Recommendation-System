import { Home, Search, Bookmark, ClipboardList, User } from "lucide-react";
import { useNavigate, useLocation } from "react-router";
import { useUser } from "../context/UserContext";

const navItems = [
  { icon: Home, label: "Home", path: "/dashboard" },
  { icon: Search, label: "Search", path: "/search" },
  { icon: Bookmark, label: "Saved", path: "/saved" },
  { icon: ClipboardList, label: "Applied", path: "/applications" },
  { icon: User, label: "Profile", path: "/profile" },
];

const PRIMARY = "#051DDA";

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();
  const { profile } = useUser();

  return (
    <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white border-t border-gray-100 shadow-lg z-50">
      <div className="flex items-center justify-around py-2 px-2">
        {navItems.map(({ icon: Icon, label, path }) => {
          const isActive = location.pathname === path;
          return (
            <button
              key={path}
              onClick={() => navigate(path)}
              className="flex flex-col items-center gap-0.5 py-1 px-3 rounded-xl transition-all"
            >
              <div
                className="p-1.5 rounded-xl transition-all"
                style={isActive ? { backgroundColor: "#EBF0FF" } : {}}
              >
                <Icon
                  size={22}
                  style={isActive ? { color: PRIMARY } : { color: "#9CA3AF" }}
                  strokeWidth={isActive ? 2.5 : 1.8}
                />
              </div>
              <span
                className="text-[10px] font-medium"
                style={isActive ? { color: PRIMARY } : { color: "#9CA3AF" }}
              >
                {label}
              </span>
            </button>
          );
        })}
      </div>
      <div className="h-safe-area-inset-bottom" />
    </div>
  );
}
