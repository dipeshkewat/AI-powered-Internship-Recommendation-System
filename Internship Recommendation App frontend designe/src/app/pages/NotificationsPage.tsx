import { useNavigate } from "react-router";
import { useUser } from "../context/UserContext";
import { ArrowLeft, Bell, Target, Briefcase, Clock, Newspaper, CheckCheck } from "lucide-react";
import { motion } from "motion/react";

const PRIMARY = "#051DDA";
const TERTIARY = "#198038";

const typeConfig = {
  match: { icon: Target, color: PRIMARY, bg: "#EBF0FF" },
  application: { icon: Briefcase, color: TERTIARY, bg: "#E8F5EC" },
  reminder: { icon: Clock, color: "#D97706", bg: "#FEF3C7" },
  news: { icon: Newspaper, color: "#0284C7", bg: "#E0F2FE" },
};

export function NotificationsPage() {
  const navigate = useNavigate();
  const { profile, markNotificationRead, markAllNotificationsRead } = useUser();

  const notifications = profile.notifications;
  const unread = notifications.filter((n) => !n.read).length;

  return (
    <div className="min-h-screen" style={{ fontFamily: "'Poppins', sans-serif", backgroundColor: "#F5F6FA" }}>
      {/* Header */}
      <div
        className="px-5 pt-12 pb-5 relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${PRIMARY} 0%, #1539F0 100%)` }}
      >
        <div className="absolute top-0 right-0 w-32 h-32 rounded-full bg-white/8" style={{ transform: "translate(40%, -40%)" }} />
        <div className="relative flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(-1)}
              className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center"
            >
              <ArrowLeft size={18} className="text-white" />
            </button>
            <div>
              <h1 className="text-xl font-bold text-white">Notifications</h1>
              {unread > 0 && (
                <p className="text-blue-200 text-xs">
                  {unread} unread notification{unread > 1 ? "s" : ""}
                </p>
              )}
            </div>
          </div>
          {unread > 0 && (
            <button
              onClick={markAllNotificationsRead}
              className="flex items-center gap-1.5 px-3 py-1.5 bg-white/20 rounded-xl text-xs font-semibold text-white border border-white/20"
            >
              <CheckCheck size={13} />
              Mark all read
            </button>
          )}
        </div>
      </div>

      <div className="px-5 pt-4">
        {notifications.length > 0 ? (
          <div className="space-y-3">
            {notifications.map((notif, idx) => {
              const config = typeConfig[notif.type];
              const Icon = config.icon;
              return (
                <motion.div
                  key={notif.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: idx * 0.05 }}
                  onClick={() => markNotificationRead(notif.id)}
                  className="bg-white rounded-2xl p-4 shadow-sm border cursor-pointer transition-all active:scale-[0.99]"
                  style={{
                    borderColor: !notif.read ? "#C7D3FF" : "#F3F4F6",
                    boxShadow: !notif.read ? "0 2px 8px rgba(5,29,218,0.08)" : undefined,
                  }}
                >
                  <div className="flex items-start gap-3">
                    <div
                      className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0"
                      style={{ backgroundColor: config.bg }}
                    >
                      <Icon size={19} style={{ color: config.color }} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <p className={`text-sm ${!notif.read ? "font-bold text-gray-900" : "font-medium text-gray-700"}`}>
                          {notif.title}
                        </p>
                        {!notif.read && (
                          <div
                            className="w-2.5 h-2.5 rounded-full shrink-0 mt-1"
                            style={{ backgroundColor: PRIMARY }}
                          />
                        )}
                      </div>
                      <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">{notif.message}</p>
                      <p className="text-[10px] text-gray-400 mt-1.5">{notif.time}</p>
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-20">
            <div
              className="w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-4"
              style={{ backgroundColor: "#EBF0FF" }}
            >
              <Bell size={36} style={{ color: PRIMARY }} />
            </div>
            <p className="text-base font-bold text-gray-800 mb-2">All caught up!</p>
            <p className="text-sm text-gray-400">No notifications at the moment.</p>
          </div>
        )}
      </div>
    </div>
  );
}
