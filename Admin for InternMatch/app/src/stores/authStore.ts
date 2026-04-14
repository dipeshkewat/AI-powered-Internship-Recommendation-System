import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { AdminUser, AuthState } from '@/types';

interface AuthStore extends AuthState {
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  setUser: (user: AdminUser | null) => void;
  setToken: (token: string | null) => void;
}

const mockAdmin: AdminUser = {
  id: '1',
  email: 'admin@internmatch.com',
  name: 'Super Admin',
  role: 'super_admin',
  avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
};

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,

      login: async (email: string, password: string) => {
        // Mock login - in production, this would call the FastAPI backend
        if (email === 'admin@internmatch.com' && password === 'admin123') {
          set({
            user: mockAdmin,
            token: 'mock-jwt-token-' + Date.now(),
            isAuthenticated: true,
          });
          return true;
        }
        return false;
      },

      logout: () => {
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        });
      },

      setUser: (user) => set({ user }),
      setToken: (token) => set({ token }),
    }),
    {
      name: 'auth-storage',
    }
  )
);
