import { useState, useEffect } from 'react';
import { Activity as ActivityIcon, CheckCircle2, XCircle, Clock } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import api from '../lib/api';

const activityData = [
  { name: 'Monday', success: 400, failed: 12, pending: 45 },
  { name: 'Tuesday', success: 300, failed: 8, pending: 30 },
  { name: 'Wednesday', success: 550, failed: 24, pending: 60 },
  { name: 'Thursday', success: 480, failed: 15, pending: 40 },
  { name: 'Friday', success: 600, failed: 30, pending: 80 },
  { name: 'Saturday', success: 200, failed: 5, pending: 15 },
  { name: 'Sunday', success: 150, failed: 3, pending: 10 },
];

const platformHealth = [
  { name: 'Instagram Graph API', status: 'Operational', latency: '124ms', uptime: '99.98%' },
  { name: 'Facebook Graph API', status: 'Operational', latency: '145ms', uptime: '99.95%' },
  { name: 'LinkedIn API v2', status: 'Degraded', latency: '850ms', uptime: '98.50%' },
  { name: 'X (Twitter) API v2', status: 'Operational', latency: '95ms', uptime: '99.99%' },
];

export function PlatformActivity() {
  const [stats, setStats] = useState<any>(null);
  
  useEffect(() => {
    const fetchActivityStats = async () => {
      try {
        const response = await api.get('/admin/stats');
        if (response.data.success) {
          setStats(response.data.data);
        }
      } catch (error) {
        console.error("Error fetching admin stats:", error);
      }
    };
    fetchActivityStats();
  }, []);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Platform Activity</h1>

      {/* Global Post Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-blue-100 rounded-lg text-blue-600"><ActivityIcon className="w-5 h-5" /></div>
            <p className="text-sm font-medium text-gray-500">Total Posts To Date</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{stats?.totalPosts !== undefined ? stats.totalPosts : '-'}</p>
        </div>
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-green-100 rounded-lg text-green-600"><CheckCircle2 className="w-5 h-5" /></div>
            <p className="text-sm font-medium text-gray-500">Successful Posts</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{stats?.successfulPosts !== undefined ? stats.successfulPosts : '-'}</p>
        </div>
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-red-100 rounded-lg text-red-600"><XCircle className="w-5 h-5" /></div>
            <p className="text-sm font-medium text-gray-500">Failed Posts</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{stats?.failedPosts !== undefined ? stats.failedPosts : '-'}</p>
        </div>
        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-orange-100 rounded-lg text-orange-600"><Clock className="w-5 h-5" /></div>
            <p className="text-sm font-medium text-gray-500">Currently Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{stats?.scheduledPosts !== undefined ? stats.scheduledPosts : '-'}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Posting Volume Chart */}
        <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-lg font-bold text-gray-900 mb-6">Posting Volume (Last 7 Days)</h2>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={activityData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#6B7280'}} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#6B7280'}} />
                <Tooltip cursor={{fill: '#f8fafc'}} />
                <Legend iconType="circle" />
                <Bar dataKey="success" name="Successful" stackId="a" fill="#10b981" radius={[0, 0, 4, 4]} />
                <Bar dataKey="pending" name="Pending" stackId="a" fill="#f59e0b" />
                <Bar dataKey="failed" name="Failed" stackId="a" fill="#ef4444" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* API Health Status */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-lg font-bold text-gray-900 mb-6">API Health Status</h2>
          <div className="space-y-6">
            {platformHealth.map((api, idx) => (
              <div key={idx} className="flex flex-col">
                <div className="flex justify-between items-center mb-1">
                  <span className="text-sm font-medium text-gray-900">{api.name}</span>
                  <span className={`text-xs font-semibold px-2 py-1 rounded-full ${
                    api.status === 'Operational' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                  }`}>
                    {api.status}
                  </span>
                </div>
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>Latency: {api.latency}</span>
                  <span>Uptime (30d): {api.uptime}</span>
                </div>
                <div className="w-full bg-gray-100 rounded-full h-1.5 mt-2">
                  <div className={`h-1.5 rounded-full ${api.status === 'Operational' ? 'bg-green-500' : 'bg-yellow-400'}`} style={{width: '100%'}}></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
