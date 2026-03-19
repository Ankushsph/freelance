import { type ReactNode, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { LoginModal } from './LoginModal';

interface ProtectedRouteProps {
  children: ReactNode;
}

export function ProtectedRoute({ children }: ProtectedRouteProps) {
  const { isAuthenticated } = useAuth();
  const [showLogin, setShowLogin] = useState(!isAuthenticated);

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">KonnectAdmin</h1>
          <p className="text-gray-600 mb-8">Please sign in to access the admin dashboard</p>
          <button
            onClick={() => setShowLogin(true)}
            className="bg-indigo-600 text-white px-6 py-2 rounded-md hover:bg-indigo-700 transition-colors"
          >
            Sign In
          </button>
        </div>
        <LoginModal 
          isOpen={showLogin} 
          onClose={() => setShowLogin(false)} 
        />
      </div>
    );
  }

  return <>{children}</>;
}