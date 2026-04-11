import { RouterProvider } from "react-router";
import { router } from "./routes";
import { UserProvider } from "./context/UserContext";
import "../styles/fonts.css";

export default function App() {
  return (
    <UserProvider>
      <div className="w-full min-h-screen flex items-start justify-center" style={{ backgroundColor: "#1A1A2E" }}>
        <div className="w-full max-w-[430px] min-h-screen relative overflow-x-hidden shadow-2xl">
          <RouterProvider router={router} />
        </div>
      </div>
    </UserProvider>
  );
}
