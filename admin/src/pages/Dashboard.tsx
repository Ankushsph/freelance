import { useState, useEffect } from 'react';
import { Users, UserCheck, CreditCard, DollarSign, Calendar } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell } from 'recharts';
import api from '../lib/api';

// We keep the icon mappings in a helper function instead of a static array so we can inject dynamic data
const getKpiData = (stats: any) => [
  { title: 'Total Users', value: stats.totalUsers?.toLocaleString() || '0', icon: Users, color: 'text-blue-600', bg: 'bg-blue-100' },
  { title: 'Active Users', value: stats.activeUsers?.toLocaleString() || '0', icon: UserCheck, color: 'text-green-600', bg: 'bg-green-100' },
  { title: 'Total Subs (Mock)', value: '1,230', icon: CreditCard, color: 'text-purple-600', bg: 'bg-purple-100' },
  { title: 'Total Posts', value: stats.totalPosts?.toLocaleString() || '0', icon: Calendar, color: 'text-orange-600', bg: 'bg-orange-100' },
  { title: 'Scheduled Posts', value: stats.scheduledPosts?.toLocaleString() || '0', icon: Calendar, color: 'text-indigo-600', bg: 'bg-indigo-100' },
];

const growthData = [
  { name: 'Jan', users: 4000 }, { name: 'Feb', users: 5000 }, { name: 'Mar', users: 4800 },
  { name: 'Apr', users: 6000 }, { name: 'May', users: 7000 }, { name: 'Jun', users: 8500 },
];

const revenueData = [
  { name: 'Jan', revenue: 2400 }, { name: 'Feb', revenue: 3398 }, { name: 'Mar', revenue: 4200 },
  { name: 'Apr', revenue: 5800 }, { name: 'May', revenue: 6500 }, { name: 'Jun', revenue: 8900 },
];

// Mock fallbacks for the initial render before fetch
const initialPlatformData = [
  { name: 'Loading', value: 100, color: '#e5e7eb' },
];

const recentActivity = [
  { id: 1, user: 'John D.', action: 'Scheduled Post', platform: 'Instagram', status: 'Success', time: '10:45 AM' },
  { id: 2, user: 'Sarah K.', action: 'Upgraded Plan', platform: 'LinkedIn', status: 'Pending', time: '09:30 AM' },
  { id: 3, user: 'Mike T.', action: 'Account Created', platform: 'X', status: 'New', time: '08:15 AM' },
];

export function Dashboard() {
  const [stats, setStats] = useState<any>({
    totalUsers: 0,
    activeUsers: 0,
    totalPosts: 0,
    scheduledPosts: 0,
    successfulPosts: 0,
    failedPosts: 0
  });
  const [platformData, setPlatformData] = useState(initialPlatformData);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await api.get('/admin/stats');
        if (response.data.success) {
          setStats(response.data.data);
          setPlatformData(response.data.data.platformData || initialPlatformData);
        }
      } catch (error) {
        console.error("Error fetching admin stats:", error);
        setError("Failed to load dashboard data. Using demo data.");
        // Use demo data on error
        setStats({
          totalUsers: 1234,
          activeUsers: 856,
          totalPosts: 5678,
          scheduledPosts: 45,
          successfulPosts: 5600,
          failedPosts: 33
        });
        setPlatformData([
          { name: 'Instagram', value: 45, color: '#E1306C' },
          { name: 'Facebook', value: 30, color: '#1877F2' },
          { name: 'LinkedIn', value: 15, color: '#0A66C2' },
          { name: 'Twitter', value: 10, color: '#000000' }
        ]);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const kpis = getKpiData(stats);

  if (loading) return <div className="p-6 text-gray-500">Loading dashboard...</div>;

  return (
    <div className="space-y-6">
      {error && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">Connection Issue</h3>
              <div className="mt-2 text-sm text-yellow-700">
                <p>{error}</p>
              </div>
            </div>
          </div>
        </div>
      )}
      <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
      
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
        {kpis.map((kpi) => (
          <div key={kpi.title} className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500">{kpi.title}</p>
              <p className="text-2xl font-bold text-gray-900 mt-1">{kpi.value}</p>
            </div>
            <div className={`w-10 h-10 rounded-full ${kpi.bg} flex items-center justify-center`}>
              <kpi.icon className={`w-5 h-5 ${kpi.color}`} />
            </div>
          </div>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-lg font-bold text-gray-900 mb-4">User Growth</h2>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={growthData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" axisLine={false} tickLine={false} />
                <YAxis axisLine={false} tickLine={false} />
                <Tooltip cursor={{stroke: '#e2e8f0', strokeWidth: 2}} />
                <Line type="monotone" dataKey="users" stroke="#4f46e5" strokeWidth={3} dot={{r: 4, strokeWidth: 2}} activeDot={{r: 6}} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
        
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-lg font-bold text-gray-900 mb-4">Revenue</h2>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" axisLine={false} tickLine={false} />
                <YAxis axisLine={false} tickLine={false} />
                <Tooltip cursor={{fill: '#f8fafc'}} />
                <Bar dataKey="revenue" fill="#10b981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-lg font-bold text-gray-900 mb-4">Platform Usage</h2>
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={platformData} cx="50%" cy="50%" innerRadius={50} outerRadius={80} paddingAngle={2} dataKey="value">
                  {platformData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="grid grid-cols-2 gap-2 mt-4">
            {platformData.map((platform) => (
              <div key={platform.name} className="flex items-center gap-2 text-sm text-gray-600">
                <span className="w-3 h-3 rounded-full" style={{backgroundColor: platform.color}}></span>
                {platform.name} ({platform.value}%)
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
          <div className="p-5 border-b border-gray-100">
            <h2 className="text-lg font-bold text-gray-900">Recent Activity</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50 text-gray-500 text-sm uppercase tracking-wider">
                  <th className="p-4 font-medium">User</th>
                  <th className="p-4 font-medium">Action</th>
                  <th className="p-4 font-medium">Platform</th>
                  <th className="p-4 font-medium">Status</th>
                  <th className="p-4 font-medium">Time</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {recentActivity.map((row) => (
                  <tr key={row.id} className="text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                    <td className="p-4 font-medium text-gray-900">{row.user}</td>
                    <td className="p-4">{row.action}</td>
                    <td className="p-4">{row.platform}</td>
                    <td className="p-4 flex items-center gap-1">
                      <span className={`w-2 h-2 rounded-full ${row.status === 'Success' ? 'bg-green-500' : row.status === 'Pending' ? 'bg-orange-500' : 'bg-blue-500'}`}></span>
                      {row.status}
                    </td>
                    <td className="p-4 text-gray-500">{row.time}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
