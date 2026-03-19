import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AdminLayout } from './components/layout/AdminLayout';
import { Dashboard } from './pages/Dashboard';
import { Users } from './pages/Users';
import { Subscriptions } from './pages/Subscriptions';
import { Revenue } from './pages/Revenue';
import { PlatformActivity } from './pages/Activity';
import { Trends } from './pages/Trends';
import { Notifications } from './pages/Notifications';
import { Support } from './pages/Support';
import { Settings } from './pages/Settings';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <ProtectedRoute>
          <Routes>
            <Route path="/" element={<AdminLayout><Dashboard /></AdminLayout>} />
            <Route path="/users" element={<AdminLayout><Users /></AdminLayout>} />
            <Route path="/subscriptions" element={<AdminLayout><Subscriptions /></AdminLayout>} />
            <Route path="/revenue" element={<AdminLayout><Revenue /></AdminLayout>} />
            <Route path="/activity" element={<AdminLayout><PlatformActivity /></AdminLayout>} />
            <Route path="/trends" element={<AdminLayout><Trends /></AdminLayout>} />
            <Route path="/notifications" element={<AdminLayout><Notifications /></AdminLayout>} />
            <Route path="/support" element={<AdminLayout><Support /></AdminLayout>} />
            <Route path="/settings" element={<AdminLayout><Settings /></AdminLayout>} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </ProtectedRoute>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
