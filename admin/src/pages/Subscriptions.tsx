import { useState, useEffect } from 'react';
import { CreditCard, Users, Clock, AlertTriangle } from 'lucide-react';
import axios from 'axios';

interface Subscriber {
  id: string;
  name: string;
  email: string;
  startDate: string;
  expiryDate: string;
  status: string;
}

interface SubscriptionStats {
  totalFree: number;
  totalPremium: number;
  expiredPremium: number;
  expiringSoon: number;
  recentSubscribers: Subscriber[];
}

export function Subscriptions() {
  const [stats, setStats] = useState<SubscriptionStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await axios.get('/api/admin/subscriptions');
      if (response.data.success) {
        setStats(response.data.data);
      } else {
        setError('Failed to load subscription statistics');
      }
    } catch (err) {
      setError('An error occurred while fetching data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="p-6 flex justify-center items-center h-full">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded relative">
          {error}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-3">
          <CreditCard className="w-8 h-8 text-purple-600" />
          <h1 className="text-2xl font-bold text-gray-900">Subscriptions Dashboard</h1>
        </div>
        <button className="bg-purple-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-purple-700 transition-colors">
          Export Report
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          icon={<CreditCard className="w-6 h-6 text-purple-600" />}
          title="Active Premium"
          value={stats?.totalPremium || 0}
          trend="+5.2%"
          bgColor="bg-purple-100"
        />
        <StatCard
          icon={<Users className="w-6 h-6 text-blue-600" />}
          title="Free Accounts"
          value={stats?.totalFree || 0}
          trend="+1.2%"
          bgColor="bg-blue-100"
        />
        <StatCard
          icon={<Clock className="w-6 h-6 text-orange-600" />}
          title="Expiring Soon (7d)"
          value={stats?.expiringSoon || 0}
          trend="-2.1%"
          bgColor="bg-orange-100"
        />
        <StatCard
          icon={<AlertTriangle className="w-6 h-6 text-red-600" />}
          title="Expired Premium"
          value={stats?.expiredPremium || 0}
          trend="0.0%"
          bgColor="bg-red-100"
        />
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-6 border-b border-gray-100">
          <h2 className="text-lg font-bold text-gray-900">Recent Premium Subscribers</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-y border-gray-100">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">User</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Start Date</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Expiry Date</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {stats?.recentSubscribers.map((sub) => (
                <tr key={sub.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className="text-sm font-medium text-gray-900">{sub.name}</span>
                      <span className="text-sm text-gray-500">{sub.email}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {new Date(sub.startDate).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {new Date(sub.expiryDate).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      sub.status === 'Active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {sub.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-purple-600 hover:text-purple-900 cursor-pointer font-medium">
                    Manage Plan
                  </td>
                </tr>
              ))}
              {(!stats?.recentSubscribers || stats.recentSubscribers.length === 0) && (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                    No premium subscribers found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon, title, value, trend, bgColor }: {
  icon: React.ReactNode;
  title: string;
  value: number;
  trend: string;
  bgColor: string;
}) {
  const isPositive = trend.startsWith('+');
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 hover:border-purple-100 transition-colors">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-3 rounded-lg ${bgColor}`}>
          {icon}
        </div>
        <span className={`text-sm font-medium px-2.5 py-1 rounded-full ${
          isPositive ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'
        }`}>
          {trend}
        </span>
      </div>
      <h3 className="text-gray-500 text-sm font-medium mb-1">{title}</h3>
      <p className="text-3xl font-bold text-gray-900">{value.toLocaleString()}</p>
    </div>
  );
}